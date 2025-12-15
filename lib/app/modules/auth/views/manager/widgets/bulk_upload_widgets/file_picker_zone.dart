import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/bulk_upload_controller.dart';

class FilePickerZone extends GetView<BulkUploadController> {
  const FilePickerZone({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload File",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.selectedFile.value != null) {
            return _buildSelectedFileView();
          } else {
            return _buildEmptyPickerView();
          }
        }),
      ],
    );
  }

  Widget _buildSelectedFileView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00C3FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00C3FF).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description, color: Color(0xFF00C3FF), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.fileName.value,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  controller.fileSize.value, 
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.removeFile,
            icon: const Icon(Icons.close, color: Colors.red),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyPickerView() {
    return GestureDetector(
      onTap: controller.pickCsvFile,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF4A00E0).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4A00E0).withOpacity(0.3),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A00E0).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF4A00E0)),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tap to select CSV file",
              style: TextStyle(
                color: Color(0xFF4A00E0), 
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Max size 10MB • CSV only",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}