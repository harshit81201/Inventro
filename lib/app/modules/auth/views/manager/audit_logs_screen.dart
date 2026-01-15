import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/audit_log_model.dart';
import '../../controller/audit_controller.dart';
import 'widgets/dashboard_widgets/dashboard_gradient_background.dart';

class AuditLogsScreen extends StatelessWidget {
  final AuditController controller = Get.put(AuditController());

  AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Audit Trail", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // Standard back button since we removed the drawer
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.refreshLogs(),
          )
        ],
      ),
      body: DashboardGradientBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white)
            );
          }

          if (controller.auditLogs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text(
                    "No audit logs found", 
                    style: TextStyle(color: Colors.white, fontSize: 18)
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            // Padding to clear the AppBar + StatusBar
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 20),
            itemCount: controller.auditLogs.length,
            itemBuilder: (context, index) {
              final log = controller.auditLogs[index];
              return _buildAuditCard(log);
            },
          );
        }),
      ),
    );
  }

  Widget _buildAuditCard(AuditLogModel log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Glassmorphism style
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getActionColor(log.actionType).withOpacity(0.1),
          child: Icon(
            _getActionIcon(log.actionType), 
            color: _getActionColor(log.actionType), 
            size: 20
          ),
        ),
        title: Text(
          log.actionType ?? "Unknown Action",
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 14, 
            color: Colors.black87
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              log.changes ?? "No details available",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  log.createdAt != null 
                      ? DateFormat('MMM dd • hh:mm a').format(log.createdAt!)
                      : "N/A",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(String? action) {
    if (action == null) return Colors.grey;
    final act = action.toUpperCase();
    if (act.contains('CREATE')) return const Color(0xFF00C853); // Green
    if (act.contains('UPDATE')) return const Color(0xFFFFAB00); // Amber
    if (act.contains('DELETE')) return const Color(0xFFD50000); // Red
    return const Color(0xFF2962FF); // Blue
  }

  IconData _getActionIcon(String? action) {
    if (action == null) return Icons.info;
    final act = action.toUpperCase();
    if (act.contains('CREATE')) return Icons.add_circle_outline;
    if (act.contains('UPDATE')) return Icons.edit_note;
    if (act.contains('DELETE')) return Icons.delete_outline;
    return Icons.info_outline;
  }
}