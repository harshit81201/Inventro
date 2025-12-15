import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/bulk_upload_controller.dart';
import 'package:inventro/app/utils/responsive_utils.dart';
import 'widgets/dashboard_widgets/dashboard_gradient_background.dart';
import 'widgets/bulk_upload_widgets/glass_card.dart';
import 'widgets/bulk_upload_widgets/instruction_section.dart';
import 'widgets/bulk_upload_widgets/duplicate_action_selector.dart';
import 'widgets/bulk_upload_widgets/file_picker_zone.dart';
import 'widgets/bulk_upload_widgets/upload_result_view.dart';

class BulkUploadScreen extends GetView<BulkUploadController> {
  const BulkUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Bulk Product Upload',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: DashboardGradientBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isSuccess.value && controller.uploadResult.value != null) {
              return const UploadResultView();
            }
            return _buildUploadForm(context);
          }),
        ),
      ),
    );
  }

  Widget _buildUploadForm(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.05)),
      child: Column(
        children: [
          // 1. INSTRUCTIONS
          const InstructionSection(),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),

          // 2. MAIN FORM CARD
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DuplicateActionSelector(),
                const SizedBox(height: 24),
                const FilePickerZone(),
                const SizedBox(height: 32),
                _buildUploadButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : controller.uploadFile,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A00E0),
        disabledBackgroundColor: Colors.grey[300],
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: controller.isLoading.value ? 0 : 4,
        shadowColor: const Color(0xFF4A00E0).withOpacity(0.3),
      ),
      child: controller.isLoading.value
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Upload Inventory",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    ));
  }
}