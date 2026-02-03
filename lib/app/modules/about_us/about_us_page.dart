import 'package:flutter/material.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import 'widgets/about_us_header.dart';
import 'widgets/team_members_section.dart';
import 'widgets/company_attribution.dart';
import 'widgets/company_contact_section.dart';

/// About Us Page - Showcases team members and company attribution
/// Features clean design with company branding and professional layout
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // App's gradient colors for consistent theming
  static const List<Color> gradientColors = [
    Color(0xFF4A00E0),
    Color(0xFF00C3FF),
    Color(0xFF8F00FF),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(),

                // Main Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Header Section
                          AboutUsHeader(gradientColors: gradientColors),
                          const SizedBox(height: 32),

                          // Company Attribution Section (Top)
                          const CompanyAttribution(
                            position: CompanyAttributionPosition.top,
                          ),
                          const SizedBox(height: 32),

                          // Team Members Section
                          const TeamMembersSection(),
                          const SizedBox(height: 32),

                          // Company Contact Section
                          const CompanyContactSection(),
                          const SizedBox(height: 32),

                          // Company Attribution Section (Bottom)
                          const CompanyAttribution(
                            position: CompanyAttributionPosition.bottom,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the custom app bar
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => SafeNavigation.safeBack(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              tooltip: "Back",
            ),
          ),
          const Expanded(
            child: Text(
              'About Us',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 44), // Balance the back button
        ],
      ),
    );
  }
}
