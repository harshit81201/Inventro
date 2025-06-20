import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../controller/dashboard_controller.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/welcome_card.dart';
import 'widgets/dashboard_actions.dart';
import 'widgets/dashboard_stat_cards.dart';
import 'widgets/product_grid.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final DashboardController dashboardController = Get.put(DashboardController());
    
    // Modern gradient matching other screens
    const List<Color> gradientColors = [
      Color(0xFF4A00E0),
      Color(0xFF00C3FF),
      Color(0xFF8F00FF),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with logo and profile
                DashboardHeader(authController: authController),
                const SizedBox(height: 24),
                
                // Welcome Card
                WelcomeCard(authController: authController),
                const SizedBox(height: 24),
                
                // Quick Actions
                const DashboardActions(),
                const SizedBox(height: 24),
                
                // Statistics Cards
                DashboardStatCards(dashboardController: dashboardController),
                const SizedBox(height: 24),
                
                // Inventory Section
                ProductGrid(dashboardController: dashboardController),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}