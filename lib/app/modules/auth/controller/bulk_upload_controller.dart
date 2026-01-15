import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // Import this
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
    // 1. Define the CSV Content with ALL parameters (Required + Optional)
    // We use snake_case headers to match the API documentation requirements.
    const String csvContent = 
        "product_name,product_type,quantity,location,serial_number,batch_number,lot_number,expiry,condition,price,payment_status,receiver,receiver_contact,remark\n"
        "iPhone 14,Smartphone,10,Warehouse A,SN001,BATCH001,LOT001,2025-12-31,New,999.99,Paid,John Doe,1234567890,Premium stock item";

    try {
      if (Platform.isAndroid) {
        // Request storage permission on Android
        var status = await Permission.storage.request();
        // On Android 11+ (SDK 30+), storage permission might be restricted, 
        // but we can often write to app directories or use Manage External Storage if strictly needed.
        // For simplicity, we check if we can write.
        if (status.isDenied) {
           // Try to request manage external storage if on Android 11+ and strictly needed,
           // or just show error. For now, let's proceed to try writing to public downloads.
        }
      }

      // 2. Get the Directory
      Directory? directory;
      if (Platform.isAndroid) {
        // Targeted path for Android Downloads
        directory = Directory('/storage/emulated/0/Download');
        // Fallback if that path doesn't exist
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        // iOS/Other
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        // 3. Create the File
        final String path = "${directory.path}/inventro_sample_upload.csv";
        final File file = File(path);
        
        // 4. Write Content
        await file.writeAsString(csvContent);

        // 5. Feedback
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

  // ... (Keep existing pickCsvFile, removeFile, uploadFile, resetUI methods as they were)
  
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