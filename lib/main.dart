import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';
import 'package:inventro/app/routes/app_pages.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';
import 'package:inventro/app/data/services/session_recovery_service.dart';

import 'app/data/services/auth_service.dart';

void main() {
  // Initialize controllers and services
  Get.put(AuthService());
  Get.put(AuthController());
  Get.put(DashboardController(), permanent: true); // Permanent to keep it alive across sessions
  Get.put(SessionRecoveryService()); // Initialize session recovery service
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inventro App',
      initialRoute: AppRoutes.splash, 
      getPages: AppPages.pages,       
      debugShowCheckedModeBanner: false,
      // Add app lifecycle observer to handle session recovery
      builder: (context, child) {
        return AppLifecycleObserver(child: child!);
      },
    );
  }
}

/// Widget to observe app lifecycle events and handle session recovery
class AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  
  const AppLifecycleObserver({super.key, required this.child});

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver> with WidgetsBindingObserver {
  final SessionRecoveryService _sessionService = Get.find<SessionRecoveryService>();
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize session tracking when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionService.initializeSessionTracking();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Record that the app is becoming inactive
        _sessionService.recordUserActivity();
        break;
    }
  }

  /// Handles app resuming from background
  void _handleAppResumed() async {
    print('📱 App resumed from background');
    
    try {
      // Calculate how long the app was in background
      if (_pausedTime != null) {
        final backgroundDuration = DateTime.now().difference(_pausedTime!);
        final backgroundHours = backgroundDuration.inHours;
        final backgroundMinutes = backgroundDuration.inMinutes;
        
        print('🕐 App was in background for ${backgroundHours}h ${backgroundMinutes % 60}m');
        
        // FIXED: More conservative session validation - only validate for very long background periods
        // This prevents false session expiration messages from brief network issues
        if (backgroundHours >= 6) { // Increased from 1 hour to 6 hours
          print('🔄 Long background period detected (>6h), validating session...');
          
          // Show loading indicator while validating
          _showSessionValidationDialog();
          
          final isSessionValid = await _sessionService.validateAndRecoverSession();
          
          // Hide loading indicator
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          
          if (isSessionValid) {
            print('✅ Session validated successfully');
            // Refresh data if user is on dashboard
            _refreshDashboardIfNeeded();
          } else {
            print('❌ Session validation failed - user will be redirected to login');
          }
        } else {
          print('✅ Short background period (<6h), no validation needed');
          // Still refresh data for good UX
          _refreshDashboardIfNeeded();
        }
      }
      
      // Record activity and reset pause time
      await _sessionService.recordUserActivity();
      _pausedTime = null;
      
    } catch (e) {
      print('❌ Error handling app resume: $e');
      // Hide loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  /// Handles app going to background
  void _handleAppPaused() {
    print('📱 App paused/backgrounded');
    _pausedTime = DateTime.now();
    _sessionService.recordUserActivity();
  }

  /// Shows a loading dialog during session validation
  void _showSessionValidationDialog() {
    Get.dialog(
      PopScope(
        canPop: false, // Prevent dismissing
        child: const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Validating session...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Refreshes dashboard data if user is currently on dashboard
  void _refreshDashboardIfNeeded() {
    try {
      // Check if user is on dashboard route
      final currentRoute = Get.currentRoute;
      if (currentRoute == '/dashboard' || currentRoute.contains('dashboard')) {
        print('🔄 User on dashboard, refreshing data...');
        
        // Check if dashboard controller exists before using it
        if (Get.isRegistered<DashboardController>()) {
          final dashboardController = Get.find<DashboardController>();
          dashboardController.refreshProducts();
          
          // Show brief success message
          Get.snackbar(
            'Data Refreshed',
            'Your data has been updated',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green[800],
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      }
    } catch (e) {
      print('⚠️ Error refreshing dashboard: $e');
      // Non-critical error, don't show to user
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}