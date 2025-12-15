import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';
import 'package:inventro/app/utils/responsive_utils.dart';
import 'package:inventro/app/utils/safe_navigation.dart';

class DashboardActions extends StatelessWidget {
  const DashboardActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.06)),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(210),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: ResponsiveUtils.getSpacing(context, 16),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: ResponsiveUtils.isSmallScreen(context) ? 0.8 : 1.2,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
          
          // Use LayoutBuilder to adapt layout based on available space
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
              
              if (isSmallScreen) {
                // Stack buttons vertically on small screens
                return _buildVerticalLayout(context);
              } else {
                // Keep 2x2 grid on larger screens
                return _buildGridLayout(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    return Column(
      children: [
        // ROW 1: Product Actions (Add & Bulk Upload)
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context: context,
                onPressed: () => Get.toNamed(AppRoutes.addProduct),
                icon: Icons.add_box,
                label: 'Add Product',
                backgroundColor: const Color(0xFF4A00E0),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing(context, 16)),
            Expanded(
              child: _buildActionButton(
                context: context,
                // INTEGRATION: Navigate to Bulk Upload Route
                onPressed: () => Get.toNamed(AppRoutes.bulkUpload),
                icon: Icons.upload_file,
                label: 'Bulk Upload',
                backgroundColor: const Color(0xFF00897B), // Teal color for distinction
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
        
        // ROW 2: Employee Actions (Add & View)
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context: context,
                onPressed: () => Get.toNamed(AppRoutes.addEmployee),
                icon: Icons.person_add_alt_1,
                label: 'Add Employee',
                backgroundColor: const Color(0xFF00C3FF),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing(context, 16)),
            Expanded(
              child: _buildActionButton(
                context: context,
                onPressed: () => Get.toNamed(AppRoutes.employeeList),
                icon: Icons.people,
                label: 'View Employees',
                backgroundColor: const Color(0xFF8F00FF),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),

        // ROW 3: Misc / Future Features
        Row(
          children: [
            Expanded(
              child: _buildOutlinedButton(
                context: context,
                onPressed: () => SafeNavigation.safeSnackbar(
                  title: 'Coming Soon', 
                  message: 'Assign Task feature coming soon!'
                ),
                icon: Icons.assignment,
                label: 'Assign Task',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      children: [
        // 1. Add Product
        _buildActionButton(
          context: context,
          onPressed: () => Get.toNamed(AppRoutes.addProduct),
          icon: Icons.add_box,
          label: 'Add Product',
          backgroundColor: const Color(0xFF4A00E0),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),

        // 2. Bulk Upload (INTEGRATION)
        _buildActionButton(
          context: context,
          onPressed: () => Get.toNamed(AppRoutes.bulkUpload),
          icon: Icons.upload_file,
          label: 'Bulk Upload',
          backgroundColor: const Color(0xFF00897B),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),

        // 3. Add Employee
        _buildActionButton(
          context: context,
          onPressed: () => Get.toNamed(AppRoutes.addEmployee),
          icon: Icons.person_add_alt_1,
          label: 'Add Employee',
          backgroundColor: const Color(0xFF00C3FF),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),

        // 4. View Employees
        _buildActionButton(
          context: context,
          onPressed: () => Get.toNamed(AppRoutes.employeeList),
          icon: Icons.people,
          label: 'View Employees',
          backgroundColor: const Color(0xFF8F00FF),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),

        // 5. Assign Task
        _buildOutlinedButton(
          context: context,
          onPressed: () => SafeNavigation.safeSnackbar(
            title: 'Coming Soon', 
            message: 'Assign Task feature coming soon!'
          ),
          icon: Icons.assignment,
          label: 'Assign Task',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.getSpacing(context, 48),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: ResponsiveUtils.getIconSize(context, 20),
        ),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getFontSize(context, 14),
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 16)),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.getSpacing(context, 48),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: const Color(0xFF4A00E0),
          size: ResponsiveUtils.getIconSize(context, 20),
        ),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF4A00E0),
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getFontSize(context, 14),
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: const Color(0xFF4A00E0),
            width: ResponsiveUtils.isSmallScreen(context) ? 1.5 : 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 16)),
          ),
        ),
      ),
    );
  }
}