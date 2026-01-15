import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/bulk_upload_controller.dart';
import 'glass_card.dart';

class InstructionSection extends GetView<BulkUploadController> {
  const InstructionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A00E0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb_outline, color: Color(0xFF4A00E0)),
              ),
              const SizedBox(width: 12),
              const Text(
                "How it works",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(1, "Download the sample CSV format."),
          _buildInstructionStep(2, "Fill in your product details."),
          _buildInstructionStep(3, "Upload to bulk create products."),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              // ⚡️ UPDATED: Now calls the download method
              onPressed: () => controller.downloadSampleFile(),
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text("Download Sample CSV"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4A00E0),
                side: const BorderSide(color: Color(0xFF4A00E0)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A00E0)),
          ),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}