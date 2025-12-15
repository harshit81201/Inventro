import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/bulk_upload_controller.dart';

class DuplicateActionSelector extends GetView<BulkUploadController> {
  const DuplicateActionSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Duplicate Handling",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Obx(() => Column(
            children: [
              _buildRadioTile(
                value: 'skip',
                title: "Skip Duplicates",
                subtitle: "Existing products will be ignored",
                icon: Icons.fast_forward,
              ),
              const Divider(height: 1),
              _buildRadioTile(
                value: 'update',
                title: "Update Duplicates",
                subtitle: "Existing products will be overwritten",
                icon: Icons.update,
              ),
            ],
          )),
        ),
      ],
    );
  }

  Widget _buildRadioTile({required String value, required String title, required String subtitle, required IconData icon}) {
    final isSelected = controller.duplicateAction.value == value;
    return RadioListTile(
      value: value,
      groupValue: controller.duplicateAction.value,
      onChanged: (val) => controller.duplicateAction.value = val.toString(),
      activeColor: const Color(0xFF4A00E0),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF4A00E0) : Colors.black87,
        )
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      secondary: Icon(
        icon, 
        color: isSelected ? const Color(0xFF4A00E0) : Colors.grey[400]
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}