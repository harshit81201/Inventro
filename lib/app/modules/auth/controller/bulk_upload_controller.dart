import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:inventro/app/data/models/bulk_upload_result.dart';
import 'package:inventro/app/data/services/product_service.dart';
import 'package:inventro/app/utils/safe_controller_base.dart';

class BulkUploadController extends SafeControllerBase {
  final ProductService _productService = ProductService();

  // State Variables
  final selectedFile = Rxn<File>();
  final fileName = ''.obs;
  final fileSize = ''.obs;
  final duplicateAction = 'skip'.obs;
  final isLoading = false.obs;
  
  // Result State
  final uploadResult = Rxn<BulkUploadResult>();
  final isSuccess = false.obs;

  // ---------------------------------------------------------------------------
  // 📥 DOWNLOAD SAMPLE CSV LOGIC
  // ---------------------------------------------------------------------------
  Future<void> downloadSampleFile() async {
    // Standard CSV content matching backend requirements
    const String csvContent = 
        "product_name,product_type,quantity,location,serial_number,batch_number,lot_number,expiry,condition,price,payment_status,receiver,receiver_contact,remark\n"
        "iPhone 14,Smartphone,10,Warehouse A,SN001,BATCH001,LOT001,2025-12-31,New,999.99,Paid,John Doe,1234567890,Premium stock item";

    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (status.isDenied) {
          print("Storage permission denied, attempting scoped storage write...");
        }
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final String path = "${directory.path}/inventro_sample_upload.csv";
        final File file = File(path);
        
        await file.writeAsString(csvContent);

        showSafeSnackbar(
          title: "Download Complete",
          message: "Saved to: $path",
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print("Download Error: $e");
      showSafeSnackbar(
        title: "Download Failed",
        message: "Could not save file. Please check permissions.",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 📂 FILE PICKER LOGIC
  // ---------------------------------------------------------------------------
  void pickCsvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        
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

  // ---------------------------------------------------------------------------
  // 🚀 UPLOAD LOGIC (Direct Upload - No Sanitization)
  // ---------------------------------------------------------------------------
  void uploadFile() async {
    if (selectedFile.value == null) {
      showValidationError("Please select a CSV file first");
      return;
    }

    isLoading.value = true;

    try {
      // Direct upload: We send the file exactly as chosen by the user.
      // The backend now handles type coercion (e.g., '123' -> "123").
      final response = await _productService.uploadBulkProducts(
        selectedFile.value!,
        duplicateAction.value,
      );

      // Parse the response
      BulkUploadResult result = BulkUploadResult.fromJson(response);
      
      // ✨ HUMAN LANGUAGE FIX: Clean up error messages before displaying
      if (result.failedRecords > 0 && result.errorDetails.isNotEmpty) {
        final cleanedErrors = _cleanErrorMessages(result.errorDetails);
        
        // Create a new result object with cleaned errors (since fields are final)
        result = BulkUploadResult(
          id: result.id,
          status: result.status,
          totalRecords: result.totalRecords,
          successfulRecords: result.successfulRecords,
          failedRecords: result.failedRecords,
          skippedRecords: result.skippedRecords,
          updatedRecords: result.updatedRecords,
          errorDetails: cleanedErrors,
        );
      }

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
        message: _cleanSingleErrorMessage(e.toString()),
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 5),
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

  // ---------------------------------------------------------------------------
  // 🧹 ERROR CLEANING UTILITIES (For "Human Language" UI)
  // ---------------------------------------------------------------------------
  
  /// Cleans a list of backend error strings to be more user-friendly
  List<String> _cleanErrorMessages(List<String> errors) {
    return errors.map((e) => _cleanSingleErrorMessage(e)).toList();
  }

  /// Removes technical jargon (URLs, internal codes) from error strings
  String _cleanSingleErrorMessage(String error) {
    // Remove "Exception:" prefix if present
    String cleaned = error.replaceAll('Exception:', '');

    // Remove Pydantic URLs (e.g., "For further information visit https://...")
    cleaned = cleaned.replaceAll(RegExp(r'For further information visit https://\S+'), '');

    // Remove technical type indicators (e.g., "[type=string_type, input_value=...]")
    cleaned = cleaned.replaceAll(RegExp(r'\[.*?\]'), '');

    // Remove specific validation codes if they appear messy (optional)
    cleaned = cleaned.replaceAll('CSVProductRow', 'Row Data');

    return cleaned.trim();
  }
}