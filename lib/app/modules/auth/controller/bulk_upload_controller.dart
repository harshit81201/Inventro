import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/data/models/bulk_upload_result.dart';
import 'package:inventro/app/data/services/product_service.dart';
import 'package:inventro/app/utils/safe_controller_base.dart';

class BulkUploadController extends SafeControllerBase {
  final ProductService _productService = ProductService();

  // State Variables
  final selectedFile = Rxn<File>();
  final fileName = ''.obs;
  final fileSize = ''.obs;
  final duplicateAction = 'skip'.obs; // 'skip' or 'update'
  final isLoading = false.obs;
  
  // Result State
  final uploadResult = Rxn<BulkUploadResult>();
  final isSuccess = false.obs;

  void pickCsvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        
        // Validate size (Max 10MB)
        int sizeInBytes = await file.length();
        if (sizeInBytes > 10 * 1024 * 1024) {
          showValidationError("File size must be less than 10MB");
          return;
        }

        selectedFile.value = file;
        fileName.value = result.files.single.name;
        fileSize.value = "${(sizeInBytes / 1024).toStringAsFixed(2)} KB";
        
        // Reset previous results
        isSuccess.value = false;
        uploadResult.value = null;
      }
    } catch (e) {
      showSafeSnackbar(
        title: "Error",
        message: "Failed to pick file: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void removeFile() {
    selectedFile.value = null;
    fileName.value = '';
    fileSize.value = '';
  }

  void uploadFile() async {
    if (selectedFile.value == null) {
      showValidationError("Please select a CSV file first");
      return;
    }

    isLoading.value = true;

    try {
      final response = await _productService.uploadBulkProducts(
        selectedFile.value!,
        duplicateAction.value,
      );

      // Parse result
      final result = BulkUploadResult.fromJson(response);
      uploadResult.value = result;
      isSuccess.value = true;
      
      showSafeSnackbar(
        title: "Success",
        message: "File processed successfully",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
      );

    } catch (e) {
      showSafeSnackbar(
        title: "Upload Failed",
        message: e.toString().replaceAll('Exception:', '').trim(),
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetUI() {
    removeFile();
    isSuccess.value = false;
    uploadResult.value = null;
    duplicateAction.value = 'skip';
  }
}