import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../controller/dashboard_controller.dart';
import 'widgets/dashboard_widgets/unified_dashboard_card.dart';
import 'widgets/dashboard_widgets/dashboard_actions.dart';
import 'widgets/dashboard_widgets/dashboard_stat_cards.dart';
import 'widgets/product_widgets/product_grid.dart';
import 'widgets/dashboard_widgets/dashboard_gradient_background.dart';
import 'widgets/dashboard_widgets/dashboard_scrollable_content.dart';
import 'widgets/dashboard_widgets/dashboard_section_divider.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final DashboardController dashboardController = Get.find<DashboardController>();
    
    // Check and reinitialize when returning to dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardController.checkAndReinitialize();
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: DashboardGradientBackground(
          child: DashboardScrollableContent(
            children: [
              // Unified Header and Welcome Card
              UnifiedDashboardCard(authController: authController),
              const DashboardSectionDivider(),
              
              // Quick Actions (Now contains the "Audit Logs" button)
              const DashboardActions(),
              const DashboardSectionDivider(),
              
              // Statistics Cards
              DashboardStatCards(dashboardController: dashboardController),
              const DashboardSectionDivider(),
              
              // Inventory Section
              ProductGrid(dashboardController: dashboardController),
              const DashboardSectionDivider(customHeight: 32),
            ],
          ),
        ),
      ),
    );
  }
}