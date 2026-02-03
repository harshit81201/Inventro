import 'package:flutter/material.dart';

/// Team Members Section - Displays all team members with their roles
class TeamMembersSection extends StatelessWidget {
  const TeamMembersSection({super.key});

  // Team member data as specified in requirements
  static const List<Map<String, dynamic>> teamMembers = [
    {
      'name': 'Neha Rustagi',
      'role': 'Operation Manager',
      'icon': Icons.admin_panel_settings,
      'color': Color(0xFF4A00E0),
    },
    {
      'name': 'Ishant Kumar',
      'role': 'Backend Developer',
      'icon': Icons.storage,
      'color': Color(0xFF00C3FF),
    },
    {
      'name': 'Harshit Kumar',
      'role': 'Application Developer',
      'icon': Icons.phone_android,
      'color': Color(0xFF8F00FF),
    },
    {
      'name': 'Jitesh Rustagi',
      'role': 'Marketing Head',
      'icon': Icons.campaign,
      'color': Color(0xFFFF6B35),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A00E0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.people,
                color: Color(0xFF4A00E0),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Our Team',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'The talented individuals who make Inventro possible',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Team Members Grid
        ...teamMembers.map((member) => _buildTeamMemberCard(member)).toList(),
      ],
    );
  }

  /// Builds individual team member card
  Widget _buildTeamMemberCard(Map<String, dynamic> member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: (member['color'] as Color).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar with role icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  member['color'] as Color,
                  (member['color'] as Color).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (member['color'] as Color).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              member['icon'] as IconData,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Member info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (member['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (member['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    member['role'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: member['color'] as Color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Decorative element
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (member['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.star,
              color: member['color'] as Color,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}