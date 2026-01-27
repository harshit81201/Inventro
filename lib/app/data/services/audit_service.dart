import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/audit_log_model.dart';
import '../../modules/auth/controller/auth_controller.dart';
import 'auth_service.dart';

class AuditService {
  final String _baseUrl = 'https://backend.tecsohub.com';

  Future<Map<String, String>> _getAuthHeaders() async {
    final authService = Get.find<AuthService>();
    final authController = Get.find<AuthController>();

    // Validate Token
    final isTokenValid = await authService.validateTokenForRequest();
    if (!isTokenValid) {
      throw Exception('Session expired or invalid. Please login again.');
    }

    final token = authController.user.value?.token;
    if (token == null) throw Exception('Authentication token not found');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
    };
  }

  // 1. Fetch Legacy Audits (Existing)
  Future<List<AuditLogModel>> getLegacyAuditLogs({int skip = 0, int limit = 100}) async {
    return _fetchLogs('/audit/products', skip, limit);
  }

  // 2. Fetch New Audits (CSV Products) - 🌟 NEW
  Future<List<AuditLogModel>> getNewProductAuditLogs({int skip = 0, int limit = 100}) async {
    // Note: Endpoint from your screenshot is /audit/new-products
    return _fetchLogs('/audit/new-products', skip, limit);
  }

  // Helper method to fetch from any audit endpoint
  Future<List<AuditLogModel>> _fetchLogs(String endpointPath, int skip, int limit) async {
    final headers = await _getAuthHeaders();
    
    // Construct Query Parameters
    final queryParams = {
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    // Construct URI using path.join to avoid double slashes
    final uri = Uri.parse('$_baseUrl$endpointPath').replace(queryParameters: queryParams);

    try {
      print('📜 AuditService: Fetching logs from $uri');
      
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => AuditLogModel.fromJson(e)).toList();
      } else {
        print('❌ Failed log fetch: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load logs: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ AuditService Error ($endpointPath): $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out.');
      }
      rethrow;
    }
  }
}