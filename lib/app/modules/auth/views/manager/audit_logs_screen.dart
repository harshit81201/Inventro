import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/audit_log_model.dart';
import '../../controller/audit_controller.dart';
import 'widgets/dashboard_widgets/dashboard_gradient_background.dart';

class AuditLogsScreen extends StatelessWidget {
  // Find the controller (it should be initialized by binding or Get.put)
  final AuditController controller = Get.put(AuditController());

  AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Audit Trail",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
          // 1. Initial Loading State
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          // 2. Empty State
          if (controller.auditLogs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text("No audit logs found", style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            );
          }

          // 3. List with Pagination
          return ListView.builder(
            // Attach the ScrollController for pagination detection
            controller: controller.scrollController,
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 20),
            // Add +1 to item count for the bottom loader
            itemCount: controller.auditLogs.length + 1,
            itemBuilder: (context, index) {
              // If we are at the very last item...
              if (index == controller.auditLogs.length) {
                // Show loader if fetching more
                return Obx(() => controller.isLoadingMore.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      )
                    : const SizedBox(height: 20)); // Or empty space if done
              }

              // Otherwise render the card
              final log = controller.auditLogs[index];
              return AuditLogCard(log: log);
            },
          );
        }),
      ),
    );
  }
}

class AuditLogCard extends StatefulWidget {
  final AuditLogModel log;

  const AuditLogCard({super.key, required this.log});

  @override
  State<AuditLogCard> createState() => _AuditLogCardState();
}

class _AuditLogCardState extends State<AuditLogCard> {
  bool _isExpanded = false;
  late List<Widget> _parsedChanges;

  @override
  void initState() {
    super.initState();
    _parsedChanges = _parseChanges(widget.log.changes);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiLine = _parsedChanges.length > 1;

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isMultiLine
              ? () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ROW ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Bubble
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _getActionColor(widget.log.actionType).withOpacity(0.15),
                      child: Icon(
                        _getActionIcon(widget.log.actionType),
                        color: _getActionColor(widget.log.actionType),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Action & Manager Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.log.actionType?.toUpperCase() ?? "UNKNOWN ACTION",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 🌟 NEW: Display Manager Name
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "By: ${widget.log.managerName ?? 'Unknown Manager'}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    if (isMultiLine)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),

                // --- CONTENT SECTION ---
                if (!isMultiLine && _parsedChanges.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildChangeContainer(_parsedChanges.first),
                ],

                if (isMultiLine && _isExpanded) ...[
                  const SizedBox(height: 12),
                  _buildChangeContainer(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _parsedChanges,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // --- FOOTER: TIMESTAMP ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.log.createdAt != null
                          ? DateFormat('MMM dd, yyyy • hh:mm a').format(widget.log.createdAt!.toLocal())
                          : "N/A",
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChangeContainer(Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: content,
    );
  }

  List<Widget> _parseChanges(String? changes) {
    if (changes == null || changes.isEmpty) {
      return [const Text("No details available", style: TextStyle(color: Colors.grey, fontSize: 13))];
    }

    try {
      // 1. Try to decode JSON string
      dynamic decoded;
      try {
        decoded = jsonDecode(changes);
      } catch (_) {
        // If not JSON, return as plain text
        return [Text(changes, style: const TextStyle(color: Colors.black87, fontSize: 13))];
      }

      if (decoded is! Map<String, dynamic>) {
        return [Text(changes, style: const TextStyle(color: Colors.black87, fontSize: 13))];
      }

      List<Widget> changeLines = [];

      decoded.forEach((key, value) {
        // Beautify Field Name (e.g., serial_number -> Serial Number)
        String fieldName = key.replaceAll('_', ' ').capitalizeFirst ?? key;

        if (value is Map && value.containsKey('old') && value.containsKey('new')) {
          // It's a structured diff {old: 'A', new: 'B'}
          final oldVal = value['old'];
          final newVal = value['new'];

          String oldStr = _formatValue(oldVal);
          String newStr = _formatValue(newVal);

          if (oldVal == null && newVal != null) {
            changeLines.add(_buildRichText("Set ", fieldName, " to ", newStr));
          } else if (oldVal != null && newVal == null) {
            changeLines.add(_buildRichText("Removed ", fieldName, " (was ", "$oldStr)"));
          } else if (oldVal.toString() != newVal.toString()) {
            changeLines.add(_buildRichText("Changed ", fieldName, " from $oldStr to ", newStr));
          }
        } else {
          // Flat key-value pair
          changeLines.add(Text("$fieldName: ${value.toString()}", style: const TextStyle(fontSize: 13, height: 1.5)));
        }
      });

      if (changeLines.isEmpty) {
        return [const Text("No visible changes", style: TextStyle(color: Colors.grey, fontSize: 13))];
      }

      return changeLines;
    } catch (e) {
      return [Text(changes, style: const TextStyle(color: Colors.black87, fontSize: 13))];
    }
  }

  Widget _buildRichText(String prefix, String field, String middle, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
          children: [
            TextSpan(text: prefix),
            TextSpan(text: field, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A00E0))),
            TextSpan(text: middle),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'Empty';
    String strValue = value.toString();
    // Check if it looks like a date
    if (strValue.length >= 10 && (strValue.contains('-') || strValue.contains('/'))) {
      try {
        final DateTime dt = DateTime.parse(strValue);
        return DateFormat('MMM dd, yyyy').format(dt);
      } catch (_) {}
    }
    return strValue;
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