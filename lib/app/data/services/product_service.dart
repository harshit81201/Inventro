import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../modules/auth/controller/auth_controller.dart';
import 'package:path/path.dart' as path;
import '../services/auth_service.dart';

class ProductService {
  final String baseUrl = 'https://backend.tecsohub.com/';
  final AuthService _authService = AuthService();

  // Enhanced helper method to get auth headers with CONSERVATIVE validation
  Future<Map<String, String>> getAuthHeaders() async {
    final authController = Get.find<AuthController>();
    final tokenValue = authController.user.value?.token;

    if (tokenValue == null || tokenValue.isEmpty) {
      throw Exception('No authentication token found. Please login again.');
    }

    final token = tokenValue.trim();
    if (token.isEmpty) {
      throw Exception('Authentication token is empty after trimming. Please login again.');
    }

    final tokenAgeMinutes = (await _authService.getTokenAgeInSeconds()) / 60;
    if (tokenAgeMinutes >= 5) {
      final isValid = await _authService.validateTokenForRequest();
      if (!isValid) {
        throw Exception('Authentication failed. Please login again.');
      }
    } else {
      print('🔄 ProductService: Using fresh token without validation (${tokenAgeMinutes.toStringAsFixed(1)} min old)');
    }

    return {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Safe JSON Decode Helper
  Map<String, dynamic> _safeJsonDecode(String responseBody, int statusCode) {
    if (responseBody.isEmpty) {
      return statusCode >= 200 && statusCode < 300
          ? {'success': true, 'message': 'Operation completed successfully'}
          : {'error': true, 'message': 'Server returned empty response with status $statusCode'};
    }
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'data': decoded};
      return {'message': decoded.toString()};
    } catch (e) {
      return {
        'error': true,
        'message': 'Invalid response format',
        'parse_error': e.toString(),
        'raw_response': responseBody.length > 500 ? '${responseBody.substring(0, 500)}...' : responseBody,
      };
    }
  }

  // Safe JSON Array Decode Helper
  List<Map<String, dynamic>> _safeJsonDecodeArray(String responseBody, int statusCode) {
    if (responseBody.isEmpty) return [];
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is List) return decoded.cast<Map<String, dynamic>>();
      if (decoded is Map<String, dynamic>) return [decoded];
      return [];
    } catch (e) {
      print('❌ JSON Parse Error for array: $e');
      return [];
    }
  }

  // HTTP Error Handler
  Exception _handleHttpError(http.Response response, String operation) {
    final statusCode = response.statusCode;
    try {
      final errorData = _safeJsonDecode(response.body, statusCode);
      final errorMessage = errorData['message'] ?? errorData['detail'] ?? errorData['error'];

      switch (statusCode) {
        case 401:
          _authService.handleAuthError();
          return Exception('Authentication failed. Please login again.');
        case 403:
          return Exception('Access denied. No permission.');
        case 404:
          return Exception('Resource not found.');
        case 422:
          return Exception(errorMessage ?? 'Invalid data provided.');
        case 429:
          return Exception('Too many requests. Wait a moment.');
        case 500:
          return Exception('Server error. Try again later.');
        default:
          return Exception(errorMessage ?? 'Failed to $operation (HTTP $statusCode)');
      }
    } catch (e) {
      return Exception('Server error: HTTP $statusCode');
    }
  }

  // ---------------------------------------------------------------------------
  // 🔍 NEW: FETCH BULK UPLOADED PRODUCTS
  // ---------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getNewProducts() async {
    try {
      print('🔍 ProductService: Fetching NEW products (Bulk Uploaded)...');
      final endpoint = path.join(baseUrl, 'new-products/');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      final authHeaders = await getAuthHeaders();

      final response = await http.get(uri, headers: authHeaders).timeout(const Duration(seconds: 30));

      print('🔍 New Products Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final list = _safeJsonDecodeArray(response.body, response.statusCode);
        print('✅ Found ${list.length} new products.');
        return list;
      } else {
        print('⚠️ Failed to fetch new products: HTTP ${response.statusCode}');
        return []; // Return empty list instead of crashing, so legacy products still load
      }
    } catch (e) {
      print('⚠️ Error fetching new products: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // 🔄 UPDATED: GET ALL PRODUCTS (MERGES LEGACY + NEW)
  // ---------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      print('🔄 ProductService: Starting COMBINED product fetch...');

      // 1. Prepare Request for Legacy Products
      final authHeaders = await getAuthHeaders();
      final legacyUri = Uri.parse(path.join(baseUrl, 'products/').replaceAll('\\', '/'));

      print('🌐 Requesting Legacy: $legacyUri');

      // 2. Execute Requests in Parallel
      final legacyFuture = http.get(legacyUri, headers: authHeaders);
      final newProductsFuture = getNewProducts(); // Call the method defined above

      final responses = await Future.wait([
        legacyFuture,
        newProductsFuture
      ]);

      final legacyResponse = responses[0] as http.Response;
      final newProductsList = responses[1] as List<Map<String, dynamic>>;

      List<Map<String, dynamic>> combinedList = [];

      // 3. Process Legacy Response (Primary Source)
      print('📊 Legacy Response Code: ${legacyResponse.statusCode}');
      if (legacyResponse.statusCode == 200) {
        final legacyList = _safeJsonDecodeArray(legacyResponse.body, legacyResponse.statusCode);
        combinedList.addAll(legacyList);
        print('✅ Loaded ${legacyList.length} legacy products.');
      } else {
        // If legacy fails, we consider it a critical error
        throw _handleHttpError(legacyResponse, 'fetch products');
      }

      // 4. Map & Merge New Products
      if (newProductsList.isNotEmpty) {
        print('🔄 Merging ${newProductsList.length} new products into main list...');
        for (var newProduct in newProductsList) {
          // Normalize the "New Product" structure to match the "Legacy Product" model
          // This ensures the UI works without needing changes
          combinedList.add({
            "id": newProduct['product_id'] ?? 0, // Generated ID
            "part_number": newProduct['product_name'] ?? "Unknown Name", // Map Name -> Part Number (Header)
            "description": newProduct['product_type'] ?? "", // Map Type -> Description (Subtitle)
            "location": newProduct['location'] ?? "Unknown",
            "quantity": newProduct['quantity'] ?? 0,
            "batch_number": newProduct['batch_number'] ?? "",
            "expiry_date": newProduct['expiry'],
            "is_bulk_uploaded": true, // Flag for debugging/UI if needed
            "created_at": newProduct['created_at'],
          });
        }
      }

      print('✅ ProductService: Total merged count: ${combinedList.length}');
      return combinedList;

    } on http.ClientException {
      print('❌ ProductService: Network Error');
      throw Exception('Network connection error. Please check your internet connection.');
    } catch (e) {
      print('❌ ProductService: Unexpected Error: $e');
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ADD PRODUCT (Legacy)
  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> productData) async {
    try {
      final endpoint = path.join(baseUrl, 'products/');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      print('🔄 ProductService: Adding product...');

      final authController = Get.find<AuthController>();
      final managerCompanyId = authController.user.value?.companyId ?? authController.user.value?.company?.id;

      if (managerCompanyId == null) throw Exception('Manager company ID not found.');

      final payload = {
        "part_number": productData['part_number'],
        "description": productData['description'],
        "location": productData['location'],
        "quantity": productData['quantity'],
        "batch_number": productData['batch_number'],
        "expiry_date": productData['expiry_date'],
        "company_id": managerCompanyId,
        "created_at": DateTime.now().toIso8601String(),
      };

      final authHeaders = await getAuthHeaders();
      final response = await http.post(
          uri, headers: {...authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode(payload)
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _safeJsonDecode(response.body, response.statusCode);
        if (data['error'] == true) throw Exception(data['message']);
        return data;
      } else {
        throw _handleHttpError(response, 'add product');
      }
    } catch (e) {
      rethrow;
    }
  }

  // BULK UPLOAD (New Endpoint)
  Future<Map<String, dynamic>> uploadBulkProducts(File file, String duplicateAction) async {
    try {
      final endpoint = path.join(baseUrl, 'new-products/bulk-upload');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      print('🔄 ProductService: Starting Bulk Upload...');

      final authHeaders = await getAuthHeaders();
      final token = authHeaders['Authorization']!.replaceAll('Bearer ', '');

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({'Authorization': 'Bearer $token', 'accept': 'application/json'});
      request.fields['duplicate_action'] = duplicateAction;

      var multipartFile = await http.MultipartFile.fromPath(
        'file', file.path,
        contentType: MediaType('text', 'csv'),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Upload timed out.'),
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 ProductService: Upload Response Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _safeJsonDecode(response.body, response.statusCode);
      } else {
        throw _handleHttpError(response, 'upload bulk file');
      }
    } on SocketException {
      throw Exception('Network connection error.');
    } catch (e) {
      print('❌ Bulk Upload Error: $e');
      rethrow;
    }
  }

  // GET PRODUCT BY ID (Legacy)
  Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final uri = Uri.parse(path.join(baseUrl, 'products', productId.toString()).replaceAll('\\', '/'));
      final authHeaders = await getAuthHeaders();
      final response = await http.get(uri, headers: authHeaders);

      if (response.statusCode == 200) {
        return _safeJsonDecode(response.body, response.statusCode);
      } else {
        throw _handleHttpError(response, 'fetch product');
      }
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE PRODUCT (Legacy)
  Future<Map<String, dynamic>> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      final uri = Uri.parse(path.join(baseUrl, 'products', productId.toString()).replaceAll('\\', '/'));
      final authHeaders = await getAuthHeaders();
      
      final payload = {
        "part_number": productData['part_number'],
        "description": productData['description'],
        "location": productData['location'],
        "quantity": productData['quantity'],
        "batch_number": productData['batch_number'],
        "expiry_date": productData['expiry_date'],
      };

      final response = await http.put(
          uri, headers: {...authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode(payload)
      );

      if (response.statusCode == 200) {
        return _safeJsonDecode(response.body, response.statusCode);
      } else {
        throw _handleHttpError(response, 'update product');
      }
    } catch (e) {
      rethrow;
    }
  }

  // DELETE PRODUCT (Legacy)
  Future<bool> deleteProduct(int productId) async {
    try {
      final uri = Uri.parse(path.join(baseUrl, 'products', productId.toString()).replaceAll('\\', '/'));
      final authHeaders = await getAuthHeaders();
      final response = await http.delete(uri, headers: authHeaders);

      if ([200, 202, 204].contains(response.statusCode)) {
        return true;
      } else {
        throw _handleHttpError(response, 'delete product');
      }
    } catch (e) {
      rethrow;
    }
  }

  String formatDateForDisplay(String isoDateString) {
    try {
      final dateTime = DateTime.parse(isoDateString);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return isoDateString;
    }
  }

  Future<Map<String, dynamic>> testBackendConnection() async {
    try {
      final uri = Uri.parse(path.join(baseUrl, 'products/').replaceAll('\\', '/'));
      final authHeaders = await getAuthHeaders();
      final response = await http.get(uri, headers: authHeaders).timeout(const Duration(seconds: 10));
      return {
        'status_code': response.statusCode,
        'success': response.statusCode < 400,
        'body': response.body,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}