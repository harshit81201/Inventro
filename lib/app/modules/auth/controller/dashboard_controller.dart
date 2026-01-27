import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/product_model.dart';

class DashboardController extends GetxController {
  // ==================== OBSERVABLES ====================
  final isLoading = false.obs;
  final products = <ProductModel>[].obs;
  final filteredProducts = <ProductModel>[].obs;
  final searchQuery = ''.obs;
  final errorMessage = ''.obs;
  final hasError = false.obs;
  final isInitialized = false.obs;

  // ==================== CONTROLLERS & SERVICES ====================
  final searchController = TextEditingController();
  final ProductService _productService = ProductService();

  // ==================== PRIVATE STATE ====================
  bool _isDisposed = false;
  bool _isInitializing = false;

  // ==================== LIFECYCLE METHODS ====================
  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
    _initializeController();
  }

  @override
  void onClose() {
    _cleanupController();
    super.onClose();
  }

  // ==================== INITIALIZATION METHODS ====================
  
  /// Sets up the search controller listener
  void _setupSearchListener() {
    searchController.addListener(_onSearchChanged);
  }

  /// Initializes the controller with products
  Future<void> _initializeController() async {
    if (_isInitializing || _isDisposed) return;
    
    _isInitializing = true;
    
    try {
      await fetchProducts();
      if (!_isDisposed) {
        isInitialized.value = true;
      }
    } catch (e) {
      print('❌ Failed to initialize products: $e');
      if (!_isDisposed) {
        isInitialized.value = true; // Mark as initialized to show error state
      }
    } finally {
      _isInitializing = false;
    }
  }

  /// Cleans up resources when controller is disposed
  void _cleanupController() {
    _isDisposed = true;
    
    try {
      searchController.removeListener(_onSearchChanged);
      searchController.dispose();
    } catch (e) {
      print('Error disposing search controller: $e');
    }
  }

  // ==================== PUBLIC METHODS ====================

  /// Checks if controller needs reinitialization and handles it
  void checkAndReinitialize() {
    if (_isDisposed) return;
    
    if (!isInitialized.value && !isLoading.value && !_isInitializing) {
      print('🔄 DashboardController: Reinitializing on return to dashboard');
      _initializeController();
    } else if (isInitialized.value && products.isEmpty) {
      print('🔄 DashboardController: Refreshing empty product list');
      refreshProducts();
    }
  }

  /// Refreshes products (called after adding/updating/deleting products)
  Future<void> refreshProducts() async {
    if (_isDisposed || isLoading.value) {
      print('🔄 DashboardController: Refresh already in progress, skipping...');
      return;
    }
    
    print('🔄 DashboardController: Refreshing products...');
    await fetchProducts();
  }

  /// Retries fetching products after an error
  Future<void> retryFetch() async {
    if (_isDisposed) return;
    
    print('🔄 DashboardController: Retrying product fetch...');
    _clearError();
    await fetchProducts();
  }

  /// Clears search input and filters
  void clearSearch() {
    if (_isDisposed) return;
    
    try {
      searchController.clear();
      searchQuery.value = '';
      _filterProducts();
    } catch (e) {
      print('❌ Error clearing search: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 🗑️ UPDATED DELETE LOGIC (Handles CSV & Legacy)
  // ---------------------------------------------------------------------------
  /// Deletes a product by checking its type (Legacy or CSV)
  Future<void> deleteProduct(ProductModel product) async {
    if (_isDisposed) return;
    
    try {
      _setLoadingState(true);
      
      // Check the flag we added to ProductModel to decide which API to call
      if (product.isBulkUploaded) {
        print('🗑️ Deleting CSV Product (ID: ${product.id}) via New API');
        await _productService.deleteNewProduct(product.id!);
      } else {
        print('🗑️ Deleting Legacy Product (ID: ${product.id}) via Old API');
        await _productService.deleteProduct(product.id!);
      }
      
      _removeProductFromLists(product.id!);
      _showSuccessMessage('Product deleted successfully');
      
    } catch (e) {
      print('❌ Error deleting product: $e');
      _showErrorMessage('Failed to delete product: ${_getErrorMessage(e)}');
    } finally {
      _setLoadingState(false);
    }
  }

  /// Updates a product in the local list
  void updateProductInList(ProductModel updatedProduct) {
    if (_isDisposed) return;
    
    try {
      final index = products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        products[index] = updatedProduct;
        products.refresh();
        _filterProducts();
        print('✅ DashboardController: Product updated - ${updatedProduct.partNumber}');
      } else {
        print('❌ DashboardController: Product not found for update - ID: ${updatedProduct.id}');
      }
    } catch (e) {
      print('❌ Error updating product in list: $e');
    }
  }

  /// Adds a new product to the local list
  void addProductToList(ProductModel newProduct) {
    if (_isDisposed) return;
    
    try {
      products.add(newProduct);
      products.refresh();
      _filterProducts();
      print('✅ DashboardController: Product added - ${newProduct.partNumber}');
    } catch (e) {
      print('❌ Error adding product to list: $e');
    }
  }

  /// Tests backend connection for debugging
  Future<void> testBackendConnection() async {
    if (_isDisposed) return;
    
    try {
      _showInfoMessage('Testing Connection', 'Checking backend connectivity...');
      await _productService.getProducts();
      _showSuccessMessage('Backend is reachable', title: 'Connection Successful');
    } catch (e) {
      _showErrorMessage('Unable to reach backend: ${_getErrorMessage(e)}', title: 'Connection Failed');
    }
  }

  // ==================== PRODUCT FETCHING METHODS ====================

  /// Main method to fetch products from the API
  Future<void> fetchProducts() async {
    if (_isDisposed) return;
    
    try {
      _prepareForFetch();
      await _validateAuthentication();
      
      final productList = await _productService.getProducts();
      if (_isDisposed) return;

      final validProducts = _processProductData(productList);
      _updateProductLists(validProducts);
      
    } catch (e) {
      _handleFetchError(e);
    } finally {
      _setLoadingState(false);
    }
  }

  /// Prepares the controller state for fetching
  void _prepareForFetch() {
    _clearError();
    _setLoadingState(true);
    print('🔄 DashboardController: Starting product fetch...');
  }

  /// Validates user authentication before making API requests
  Future<void> _validateAuthentication() async {
    final authController = Get.find<AuthController>();
    
    if (authController.user.value?.token == null) {
      throw Exception('No authentication token found. Please login again.');
    }

    await _waitForTokenValidation(authController);
    
    if (authController.user.value?.token == null) {
      throw Exception('Session expired. Please login again.');
    }
  }

  /// Waits for token validation to complete with timeout
  Future<void> _waitForTokenValidation(AuthController authController) async {
    if (!authController.isTokenValidating.value) return;

    print('🔄 DashboardController: Waiting for token validation...');
    
    const maxTimeoutMs = 10000; // 10 seconds
    const checkIntervalMs = 100;
    int timeoutCounter = 0;
    
    while (authController.isTokenValidating.value && 
           !_isDisposed && 
           timeoutCounter < (maxTimeoutMs ~/ checkIntervalMs)) {
      await Future.delayed(const Duration(milliseconds: checkIntervalMs));
      timeoutCounter++;
    }
    
    if (timeoutCounter >= (maxTimeoutMs ~/ checkIntervalMs)) {
      print('⚠️ DashboardController: Token validation timeout, proceeding...');
    }
  }

  /// Processes raw product data into ProductModel objects
  List<ProductModel> _processProductData(List<Map<String, dynamic>> productList) {
    final validProducts = <ProductModel>[];
    
    for (final productJson in productList) {
      try {
        if (_isValidProductData(productJson)) {
          final product = ProductModel.fromJson(productJson);
          validProducts.add(product);
        } else {
          print('⚠️ DashboardController: Skipping invalid product data');
        }
      } catch (e) {
        print('⚠️ DashboardController: Error parsing product: $e');
      }
    }
    
    return validProducts;
  }

  /// Updates the product lists with new data
  void _updateProductLists(List<ProductModel> validProducts) {
    if (!_isDisposed) {
      products.value = validProducts;
      _filterProducts();
      print('✅ DashboardController: Successfully loaded ${validProducts.length} products');
    }
  }

  /// Handles errors that occur during product fetching
  void _handleFetchError(dynamic error) {
    print('❌ DashboardController: Error fetching products: $error');
    
    if (!_isDisposed) {
      final errorMsg = _getErrorMessage(error);
      _setError(errorMsg);
      _showErrorMessage(errorMsg, title: 'Error Loading Products');
      _scheduleRetryPrompt(errorMsg);
    }
  }

  // ==================== VALIDATION METHODS ====================

  /// Validates if product data contains required fields
  bool _isValidProductData(Map<String, dynamic> data) {
    try {
      return data.containsKey('part_number') &&
             data.containsKey('description') &&
             data.containsKey('location') &&
             data.containsKey('quantity') &&
             data.containsKey('batch_number') &&
             data.containsKey('expiry_date');
    } catch (e) {
      return false;
    }
  }

  // ==================== FILTERING METHODS ====================

  /// Handles search query changes
  void _onSearchChanged() {
    if (_isDisposed) return;
    
    searchQuery.value = searchController.text;
    _filterProducts();
  }

  /// Filters products based on current search query
  void _filterProducts() {
    if (_isDisposed) return;
    
    try {
      if (searchQuery.value.isEmpty) {
        filteredProducts.value = products.toList();
      } else {
        filteredProducts.value = _getFilteredProducts();
      }
    } catch (e) {
      print('❌ Error filtering products: $e');
      filteredProducts.value = products.toList(); // Fallback
    }
  }

  /// Gets products that match the current search query
  List<ProductModel> _getFilteredProducts() {
    final query = searchQuery.value.toLowerCase();
    
    return products.where((product) {
      return product.partNumber.toLowerCase().contains(query) ||
             product.description.toLowerCase().contains(query) ||
             product.location.toLowerCase().contains(query) ||
             product.batchNumber.toString().contains(query);
    }).toList();
  }

  // ==================== COMPUTED PROPERTIES ====================

  /// Gets products that are expired
  List<ProductModel> get expiredProducts {
    try {
      return products.where((product) {
        try {
          return product.isExpired;
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      print('❌ Error getting expired products: $e');
      return [];
    }
  }

  /// Gets products that are expiring soon (within 7 days, excluding already expired)
  List<ProductModel> get expiringProducts {
    try {
      return products.where((product) {
        try {
          // Only include products that are:
          // 1. Not expired
          // 2. Expiring within 7 days (0-7 days inclusive)
          return !product.isExpired && 
                 product.daysUntilExpiry >= 0 && 
                 product.daysUntilExpiry <= 7;
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      print('❌ Error getting expiring products: $e');
      return [];
    }
  }

  /// Gets products with low stock (quantity ≤ 1)
  List<ProductModel> get lowStockProducts {
    try {
      return products.where((product) {
        try {
          return product.quantity <= 1;
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      print('❌ Error getting low stock products: $e');
      return [];
    }
  }

  // ==================== INVENTORY FILTER METHODS ====================

  /// Gets filtered products by type for bottom sheet display
  List<ProductModel> getFilteredProductsByType(String filterType) {
    switch (filterType.toLowerCase()) {
      case 'total':
        return products.toList();
      case 'low_stock':
        return lowStockProducts;
      case 'expiring':
        return expiringProducts;
      case 'expired':
        return expiredProducts;
      default:
        return products.toList();
    }
  }

  /// Shows filtered products in a bottom sheet
  void showFilteredProductsBottomSheet(String filterType, String title) {
    if (_isDisposed) return;
    
    try {
      final filteredList = getFilteredProductsByType(filterType);
      
      // Dynamically load the bottom sheet
      Get.bottomSheet(
        _buildInventoryBottomSheet(filteredList, title, filterType),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
      );
    } catch (e) {
      print('❌ Error showing filtered products bottom sheet: $e');
      _showErrorMessage('Unable to show filtered products');
    }
  }

  /// Builds the inventory bottom sheet widget
  Widget _buildInventoryBottomSheet(List<ProductModel> products, String title, String filterType) {
    // Note: Ideally, this should be in a separate widget file, but included here based on your request
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${products.length} items',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              
              // List (Placeholder)
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ListTile(
                      title: Text(p.partNumber),
                      subtitle: Text(p.description),
                      trailing: Text('Qty: ${p.quantity}'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== STATE MANAGEMENT HELPERS ====================

  /// Sets the loading state safely
  void _setLoadingState(bool loading) {
    if (!_isDisposed) {
      isLoading.value = loading;
    }
  }

  /// Sets error state with message
  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
  }

  /// Clears error state
  void _clearError() {
    if (_isDisposed) return;
    
    hasError.value = false;
    errorMessage.value = '';
  }

  /// Removes a product from both product lists
  void _removeProductFromLists(int productId) {
    products.removeWhere((product) => product.id == productId);
    _filterProducts(); // This will update filteredProducts
  }

  // ==================== ERROR HANDLING HELPERS ====================

  /// Gets user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().replaceAll('Exception: ', '');
    
    if (errorStr.contains('timeout')) {
      return 'Request timed out. Please check your internet connection.';
    } else if (errorStr.contains('Network') || errorStr.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('login again')) {
      return 'Your session has expired. Please login again.';
    } else if (errorStr.contains('Invalid response format')) {
      return 'Server returned invalid data. Please try again.';
    } else if (errorStr.contains('server') || errorStr.contains('Server')) {
      return 'Server error. Please try again later.';
    } else if (errorStr.contains('Connection refused')) {
      return 'Cannot connect to server. Please check your internet connection.';
    } else {
      return errorStr.isEmpty ? 'Unknown error occurred. Please try again.' : errorStr;
    }
  }

  /// Schedules a retry prompt for non-authentication errors
  void _scheduleRetryPrompt(String errorMessage) {
    if (errorMessage.contains('login again')) return;
    
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isDisposed && hasError.value) {
        _showInfoMessage('Retry Available', 'Pull down to refresh or try again later');
      }
    });
  }

  // ==================== UI FEEDBACK HELPERS ====================

  /// Shows success message to user
  void _showSuccessMessage(String message, {String title = 'Success'}) {
    if (_isDisposed) return;
    
    SafeNavigation.safeSnackbar(
      title: title,
      message: message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.1),
      colorText: Colors.green[800],
      duration: const Duration(seconds: 2),
    );
  }

  /// Shows error message to user
  void _showErrorMessage(String message, {String title = 'Error'}) {
    if (_isDisposed) return;
    
    SafeNavigation.safeSnackbar(
      title: title,
      message: message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.1),
      colorText: Colors.red[800],
      duration: const Duration(seconds: 4),
    );
  }

  /// Shows info message to user
  void _showInfoMessage(String title, String message) {
    if (_isDisposed) return;
    
    SafeNavigation.safeSnackbar(
      title: title,
      message: message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      colorText: Colors.blue[800],
      duration: const Duration(seconds: 2),
    );
  }
}