import 'dart:convert';

class BulkUploadResult {
  final int id;
  final String status;
  final int totalRecords;
  final int successfulRecords;
  final int failedRecords;
  final int skippedRecords;
  final int updatedRecords;
  final List<String> errorDetails;

  BulkUploadResult({
    required this.id,
    required this.status,
    required this.totalRecords,
    required this.successfulRecords,
    required this.failedRecords,
    required this.skippedRecords,
    required this.updatedRecords,
    required this.errorDetails,
  });

  factory BulkUploadResult.fromJson(Map<String, dynamic> json) {
    // Parse error_details which comes as a JSON string within the JSON
    List<String> parsedErrors = [];
    if (json['error_details'] != null) {
      try {
        if (json['error_details'] is String) {
          final decoded = jsonDecode(json['error_details']);
          if (decoded is List) {
            parsedErrors = List<String>.from(decoded);
          }
        } else if (json['error_details'] is List) {
          parsedErrors = List<String>.from(json['error_details']);
        }
      } catch (e) {
        parsedErrors = ["Error parsing error details"];
      }
    }

    return BulkUploadResult(
      id: json['id'] ?? 0,
      status: json['upload_status'] ?? 'unknown',
      totalRecords: json['total_records'] ?? 0,
      successfulRecords: json['successful_records'] ?? 0,
      failedRecords: json['failed_records'] ?? 0,
      skippedRecords: json['skipped_records'] ?? 0,
      updatedRecords: json['updated_records'] ?? 0,
      errorDetails: parsedErrors,
    );
  }
}