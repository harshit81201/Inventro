import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/audit_log_model.dart';
import '../../modules/auth/controller/auth_controller.dart';
import 'auth_service.dart';

class AuditService {
  final String _baseUrl = 'https://backend.tecsohub.com';

  Future<List<AuditLogModel>> getCompanyAuditLogs({int skip = 0, int limit = 100}) async {
    final authService = Get.find<AuthService>();
    final authController = Get.find<AuthController>();

    // 1. Validate Token Integrity using your AuthService logic
    // This handles checking expiration and network validation if needed
    final isTokenValid = await authService.validateTokenForRequest();
    if (!isTokenValid) {
      throw Exception('Session expired or invalid. Please login again.');
    }

    final token = authController.user.value?.token;
    if (token == null) throw Exception('Authentication token not found');

    // 2. Prepare URI
    final uri = Uri.parse('$_baseUrl/audit/products').replace(queryParameters: {
      'skip': skip.toString(),
      'limit': limit.toString(),
    });

    try {
      // 3. Execute Request with Timeout
      print('📜 AuditService: Fetching logs from $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      // 4. Handle Response
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => AuditLogModel.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        await authService.handleAuthError();
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load logs: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ AuditService Error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your connection.');
      }
      rethrow;
    }
  }
}