import 'package:flutter/material.dart';

/// About Us Header - Welcome section with app branding
class AboutUsHeader extends StatelessWidget {
  final List<Color> gradientColors;

  const AboutUsHeader({
    super.key,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 32),
        
        // App Icon/Logo
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A00E0).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(56),
            ),
            child: const Icon(
              Icons.info_outline,
              size: 48,
              color: Color(0xFF4A00E0),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Title
        const Text(
          'About Inventro',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A202C),
          ),
        ),
        
        const SizedBox(height: 12),
        
      ],
    );
  }
}