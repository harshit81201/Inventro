import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../modules/auth/controller/auth_controller.dart';
import 'package:path/path.dart' as path;

class ProductService {
  final String baseUrl = 'https://backend.tecsohub.com/';

  // Helper method to get auth headers with token
  Map<String, String> getAuthHeaders() {
    final authController = Get.find<AuthController>();
    final tokenValue = authController.user.value?.token;

    if (tokenValue == null || tokenValue.isEmpty) {
      throw Exception('No authentication token found. Please login again.');
    }

    final token = tokenValue.trim(); // Trim whitespace
    if (token.isEmpty) {
      // Check again after trim
      throw Exception(
        'Authentication token is empty after trimming. Please login again.',
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return headers;
  }

  // Helper method to safely parse JSON response
  Map<String, dynamic> _safeJsonDecode(String responseBody, int statusCode) {
    if (responseBody.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        return {'success': true, 'message': 'Operation completed successfully'};
      } else {
        return {
          'error': true,
          'message': 'Server returned empty response with status $statusCode',
        };
      }
    }

    // Check if response is HTML (common for server errors)
    if (responseBody.trim().toLowerCase().startsWith('<html>') ||
        responseBody.trim().toLowerCase().startsWith('<!doctype')) {
      return {
        'error': true,
        'message':
            'Server error - received HTML page instead of JSON. Backend may be down or misconfigured.',
        'html_response': responseBody.substring(
          0,
          200,
        ), // First 200 chars for debugging
      };
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        return {'data': decoded};
      } else {
        return {'message': decoded.toString()};
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Invalid response format from server',
        'parse_error': e.toString(),
      };
    }
  }

  // Helper method to safely parse JSON array response
  List<Map<String, dynamic>> _safeJsonDecodeArray(
    String responseBody,
    int statusCode,
  ) {
    if (responseBody.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      } else if (decoded is Map<String, dynamic>) {
        return [decoded];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ADD PRODUCT - Following your requirements
  Future<Map<String, dynamic>> addProduct(
    Map<String, dynamic> productData,
  ) async {
    try {
      final endpoint = path.join(baseUrl, 'products/');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      // Get manager's company ID from auth controller
      final authController = Get.find<AuthController>();
      final managerCompanyId = authController.user.value?.companyId ??
          authController.user.value?.company?.id;

      if (managerCompanyId == null) {
        throw Exception('Manager company ID not found. Please login again.');
      }

      // Capture local date-time
      final createdAt = DateTime.now().toIso8601String();

      // Create payload matching your requirements
      final payload = {
        "part_number": productData['part_number'],
        "description": productData['description'],
        "location": productData['location'],
        "quantity": productData['quantity'],
        "batch_number": productData['batch_number'],
        "expiry_date": productData['expiry_date'], // Expected format: "YYYY-MM-DD"
        "company_id": managerCompanyId,
        "created_at": createdAt,
      };

      final authHeaders = getAuthHeaders();
      final requestHeaders = {
        ...authHeaders,
        'Content-Type': 'application/json',
      };

      final response = await http
          .post(
            uri,
            headers: requestHeaders,
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check your internet connection',
              );
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _safeJsonDecode(
          response.body,
          response.statusCode,
        );
        if (responseData['error'] == true) {
          throw Exception(responseData['message'] ?? 'Failed to add product');
        }
        return responseData;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(
          errorData['message'] ??
              errorData['detail'] ??
              'Failed to add product (${response.statusCode})',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Network connection error. Please check your internet connection.',
      );
    } on FormatException {
      throw Exception(
        'Invalid server response format. Please try again later.',
      );
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // GET ALL PRODUCTS
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      print('🔄 Starting product fetch...');

      // Use centralized auth headers method
      final authHeaders = getAuthHeaders();
      print('✅ Token retrieved and validated');

      final endpoint = path.join(baseUrl, 'products/');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      print('🌐 Endpoint: $uri');

      final requestHeaders = {
        ...authHeaders,
        'Content-Type': 'application/json',
      };

      // Log token for debugging (first 20 chars only for security)
      final token = authHeaders['Authorization']?.replaceAll('Bearer ', '') ?? '';
      print('🔑 Token preview: ${token.length > 20 ? token.substring(0, 20) + '...' : token}');

      final response = await http
          .get(
            uri,
            headers: requestHeaders,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check your internet connection',
              );
            },
          );

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📝 Response Body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');

      if (response.statusCode == 200) {
        final products = _safeJsonDecodeArray(response.body, response.statusCode);
        print('✅ Successfully parsed ${products.length} products');
        return products;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        final errorMessage = errorData['message'] ??
            errorData['detail'] ??
            errorData['error'] ??
            'Failed to fetch products (${response.statusCode})';

        print('❌ API Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      print('❌ Network Error: ${e.message}');
      throw Exception(
        'Network connection error. Please check your internet connection.',
      );
    } on FormatException catch (e) {
      print('❌ JSON Parse Error: ${e.message}');
      throw Exception(
        'Invalid server response format. Please try again later.',
      );
    } catch (e) {
      print('❌ Unexpected Error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // GET PRODUCT BY ID
  Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final endpoint = path.join(baseUrl, 'products', productId.toString());
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      final response = await http
          .get(uri, headers: getAuthHeaders())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check your internet connection',
              );
            },
          );

      if (response.statusCode == 200) {
        final responseData = _safeJsonDecode(
          response.body,
          response.statusCode,
        );
        if (responseData['error'] == true) {
          throw Exception(responseData['message'] ?? 'Failed to fetch product');
        }
        return responseData;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(
          errorData['message'] ??
              errorData['detail'] ??
              'Failed to fetch product (${response.statusCode})',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Network connection error. Please check your internet connection.',
      );
    } on FormatException {
      throw Exception(
        'Invalid server response format. Please try again later.',
      );
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // UPDATE PRODUCT
  Future<Map<String, dynamic>> updateProduct(
    int productId,
    Map<String, dynamic> productData,
  ) async {
    try {
      final endpoint = path.join(baseUrl, 'products', productId.toString());
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      // Log the incoming data for debugging
      print('🔄 ProductService: Updating product $productId with data: $productData');

      // Transform data to match backend schema - FIX: Use the date as-is since it's already formatted
      final transformedData = {
        "part_number": productData['part_number'],
        "description": productData['description'],
        "location": productData['location'],
        "quantity": productData['quantity'],
        "batch_number": productData['batch_number'], // Keep as received
        "expiry_date": productData['expiry_date'], // Use the already formatted date
      };

      print('🔄 ProductService: Transformed data for backend: $transformedData');

      final authHeaders = getAuthHeaders();
      final requestHeaders = {
        ...authHeaders,
        'Content-Type': 'application/json',
      };

      final response = await http
          .put(
            uri,
            headers: requestHeaders,
            body: jsonEncode(transformedData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check your internet connection',
              );
            },
          );

      print('📊 ProductService: Update response status: ${response.statusCode}');
      print('📝 ProductService: Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = _safeJsonDecode(
          response.body,
          response.statusCode,
        );
        if (responseData['error'] == true) {
          throw Exception(
            responseData['message'] ?? 'Failed to update product',
          );
        }
        print('✅ ProductService: Product updated successfully');
        return responseData;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        print('❌ ProductService: Update failed with error: $errorData');
        throw Exception(
          errorData['message'] ??
              errorData['detail'] ??
              'Failed to update product (${response.statusCode})',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Network connection error. Please check your internet connection.',
      );
    } on FormatException {
      throw Exception(
        'Invalid server response format. Please try again later.',
      );
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // DELETE PRODUCT
  Future<bool> deleteProduct(int productId) async {
    try {
      final endpoint = path.join(baseUrl, 'products', productId.toString());
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      final response = await http
          .delete(uri, headers: getAuthHeaders())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check your internet connection',
              );
            },
          );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 202) {
        // For delete operations, empty response is often expected
        return true;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(
          errorData['message'] ??
              errorData['detail'] ??
              'Failed to delete product (${response.statusCode})',
        );
      }
    } on http.ClientException catch (e) {
      print('❌ Delete Network Error: ${e.message}');
      throw Exception(
        'Network connection error. Please check your internet connection.',
      );
    } on FormatException catch (e) {
      print('❌ Delete JSON Parse Error: ${e.message}');
      throw Exception(
        'Invalid server response format. Please try again later.',
      );
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Helper method to format date for backend (ISO 8601 format)
  String _formatDateForBackend(String dateString) {
    try {
      // Parse date string (expected format: "dd/mm/yyyy")
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final dateTime = DateTime(year, month, day);
        return dateTime.toIso8601String();
      }

      // If parsing fails, return current date
      return DateTime.now().toIso8601String();
    } catch (e) {
      // If any error occurs, return current date
      return DateTime.now().toIso8601String();
    }
  }

  // Helper method to format date from backend for display
  String formatDateForDisplay(String isoDateString) {
    try {
      final dateTime = DateTime.parse(isoDateString);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return isoDateString;
    }
  }

  // Helper method to validate backend connection and authentication
  Future<Map<String, dynamic>> testBackendConnection() async {
    try {
      final endpoint = path.join(baseUrl, 'products/');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      final response = await http
          .get(uri, headers: getAuthHeaders())
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      return {
        'status_code': response.statusCode,
        'success': response.statusCode < 400,
        'body': response.body,
        'headers': response.headers,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}