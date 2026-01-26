import 'package:flutter/material.dart';

/// Reusable gradient background component for dashboard screens
class DashboardGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? customColors;

  const DashboardGradientBackground({
    super.key,
    required this.child,
    this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    // Default gradient colors matching the app theme
    const List<Color> defaultGradientColors = [
      Color(0xFF4A00E0),
      Color(0xFF00C3FF),
      Color(0xFF8F00FF),
    ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: customColors ?? defaultGradientColors,
        ),
      ),
      child: child,
    );
  }
}