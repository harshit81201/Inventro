import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/bulk_upload_controller.dart';
import '../../../../../../utils/responsive_utils.dart';
import 'glass_card.dart';

class UploadResultView extends GetView<BulkUploadController> {
  const UploadResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final result = controller.uploadResult.value!;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.05)),
      child: GlassCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              "Processing Complete",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Text("Your inventory has been updated.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            
            // ROW 1: Total & Success
            Row(
              children: [
                _buildStatCard("Total", result.totalRecords.toString(), Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard("Success", result.successfulRecords.toString(), Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            
            // ROW 2: Skipped & Updated
            Row(
              children: [
                 _buildStatCard("Skipped", result.skippedRecords.toString(), Colors.orange),
                 const SizedBox(width: 12),
                 _buildStatCard("Updated", result.updatedRecords.toString(), const Color(0xFF00C3FF)),
              ],
            ),
            
            if (result.failedRecords > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard("Failed", result.failedRecords.toString(), Colors.red),
                  const Spacer(),
                ],
              ),
              
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft, 
                child: Text("Error Details:", style: TextStyle(fontWeight: FontWeight.bold))
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.errorDetails.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text("• $e", style: const TextStyle(color: Colors.red, fontSize: 13)),
                  )).toList(),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.resetUI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0xFF4A00E0).withOpacity(0.4),
                ),
                child: const Text("Upload Another File", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value, 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(fontSize: 13, color: color.withOpacity(0.8), fontWeight: FontWeight.w600)
            ),
          ],
        ),
      ),
    );
  }
}