import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/product_model.dart';

class EditProductController extends GetxController {
  // ==================== CONTROLLERS ====================
  final partNumberController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final quantityController = TextEditingController();
  final batchNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final updatedOnController = TextEditingController();

  // ==================== OBSERVABLES ====================
  final isLoading = false.obs;
  final isInitialized = false.obs;

  // ==================== SERVICES ====================
  final ProductService _productService = ProductService();

  // ==================== PRIVATE STATE ====================
  bool _isDisposed = false;
  ProductModel? currentProduct;

  // ==================== LIFECYCLE METHODS ====================
  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
  }

  @override
  void onClose() {
    _cleanupController();
    super.onClose();
  }

  // ==================== INITIALIZATION METHODS ====================

  /// Initializes controller from route arguments
  void _initializeFromArguments() {
    try {
      final args = Get.arguments;
      print('📋 EditProductController: Received arguments type: ${args.runtimeType}');
      
      if (_isValidArguments(args)) {
        currentProduct = _extractProductFromArguments(args);
        if (currentProduct != null) {
          _populateFieldsFromProduct();
        } else {
          _handleInvalidProduct();
        }
      } else {
        _handleInvalidProduct();
      }
    } catch (e) {
      print('❌ EditProductController: Error in onInit: $e');
      _handleInvalidProduct();
    }
  }

  /// Validates if arguments are in expected format
  bool _isValidArguments(dynamic args) {
    return args != null && 
           (args is ProductModel || 
            (args is Map<String, dynamic> && args.containsKey('product')));
  }

  /// Extracts ProductModel from various argument formats
  ProductModel? _extractProductFromArguments(dynamic args) {
    if (args is ProductModel) {
      print('✅ EditProductController: Direct ProductModel received');
      return args;
    } else if (args is Map<String, dynamic>) {
      final productData = args['product'];
      if (productData is ProductModel) {
        print('✅ EditProductController: ProductModel from map received');
        return productData;
      }
    }
    return null;
  }

  /// Handles case when no valid product is found
  void _handleInvalidProduct() {
    if (!_isDisposed) {
      SafeNavigation.safeSnackbar(
        title: 'Error',
        message: 'Invalid product data. Returning to dashboard.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isDisposed) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      });
    }
  }

  /// Populates form fields with product data
  void _populateFieldsFromProduct() {
    if (currentProduct == null || _isDisposed) {
      print('❌ Cannot populate fields: product is null or controller disposed');
      return;
    }
    
    try {
      _setBasicFields();
      _setExpiryDateField();
      _setUpdatedDateField();
      
      if (!_isDisposed) {
        isInitialized.value = true;
      }
      
      print('✅ EditProductController: Fields populated successfully');
    } catch (e) {
      print('❌ Error populating fields: $e');
      _showErrorMessage('Failed to load product data. Please try again.');
    }
  }

  /// Sets basic product fields
  void _setBasicFields() {
    partNumberController.text = currentProduct!.partNumber;
    descriptionController.text = currentProduct!.description;
    locationController.text = currentProduct!.location;
    quantityController.text = currentProduct!.quantity.toString();
    batchNumberController.text = currentProduct!.batchNumber.toString();
  }

  /// Sets expiry date field with proper formatting
  void _setExpiryDateField() {
    try {
      if (currentProduct!.expiryDate.isNotEmpty) {
        // Handle both ISO (YYYY-MM-DD) and slash (DD/MM/YYYY) formats
        if (currentProduct!.expiryDate.contains('-')) {
           final dateTime = DateTime.parse(currentProduct!.expiryDate);
           expiryDateController.text = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
        } else {
           expiryDateController.text = currentProduct!.expiryDate;
        }
      } else {
        _setTomorrowAsExpiryDate();
      }
    } catch (e) {
      print('⚠️ Error parsing expiry date: $e');
      _setFallbackExpiryDate();
    }
  }

  /// Sets tomorrow as default expiry date
  void _setTomorrowAsExpiryDate() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    expiryDateController.text = "${tomorrow.day}/${tomorrow.month}/${tomorrow.year}";
  }

  /// Sets fallback expiry date using formatted date or tomorrow
  void _setFallbackExpiryDate() {
    expiryDateController.text = currentProduct!.formattedExpiryDate.isNotEmpty 
        ? currentProduct!.formattedExpiryDate 
        : _getTomorrowFormatted();
  }

  /// Gets tomorrow's date formatted as DD/MM/YYYY
  String _getTomorrowFormatted() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return "${tomorrow.day}/${tomorrow.month}/${tomorrow.year}";
  }

  /// Sets updated date field to current date
  void _setUpdatedDateField() {
    final now = DateTime.now();
    updatedOnController.text = "${now.day}/${now.month}/${now.year}";
  }

  /// Cleans up resources when controller is disposed
  void _cleanupController() {
    _isDisposed = true;
    
    try {
      _disposeAllControllers();
    } catch (e) {
      print('❌ Error disposing controllers: $e');
    }
    
    super.onClose();
  }

  /// Disposes all text controllers safely
  void _disposeAllControllers() {
    partNumberController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    quantityController.dispose();
    batchNumberController.dispose();
    expiryDateController.dispose();
    updatedOnController.dispose();
  }

  // ==================== PUBLIC METHODS ====================

  /// Shows date picker for selecting expiry date
  Future<void> selectExpiryDate(BuildContext context) async {
    if (_isDisposed) return;
    
    try {
      final initialDate = _getInitialDateForPicker();
      final picked = await _showDatePickerDialog(context, initialDate);
      
      if (picked != null && !_isDisposed) {
        _setExpiryDate(picked);
      }
    } catch (e) {
      _handleDatePickerError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // 🔄 UPDATED: UPDATE LOGIC (Handles Both APIs)
  // ---------------------------------------------------------------------------
  Future<void> updateProduct() async {
    if (_isDisposed || currentProduct == null) {
      print('❌ Cannot update: controller disposed or product is null');
      return;
    }
    
    if (!_validateAllFields()) return;

    try {
      _setLoadingState(true);
      
      final Map<String, dynamic> updateData = {
        'part_number': partNumberController.text.trim(),
        'description': descriptionController.text.trim(),
        'location': locationController.text.trim(),
        'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
        'batch_number': batchNumberController.text.trim(),
        'expiry_date': _formatDateForBackend(expiryDateController.text.trim()),
      };

      print('🔄 Updating product: $updateData');

      // 🔍 ROUTING LOGIC: Check where the product belongs
      if (currentProduct!.isBulkUploaded) {
        print('📡 Sending to NEW API (CSV Product)');
        await _productService.updateNewProduct(currentProduct!.id!, updateData);
      } else {
        print('📡 Sending to LEGACY API (Manual Product)');
        await _productService.updateProduct(currentProduct!.id!, updateData);
      }

      await _handleSuccessfulUpdate();
      
    } catch (e) {
      _handleUpdateError(e);
    } finally {
      _setLoadingState(false);
    }
  }

  // ==================== DATE HANDLING METHODS ====================

  /// Gets initial date for date picker based on current field value
  DateTime _getInitialDateForPicker() {
    DateTime initialDate = DateTime.now().add(const Duration(days: 1));
    
    try {
      if (expiryDateController.text.isNotEmpty) {
        final parsedDate = _parseDateFromField(expiryDateController.text);
        if (parsedDate != null) {
          initialDate = parsedDate;
        }
      }
    } catch (e) {
      print('⚠️ Error parsing current expiry date: $e');
    }
    
    return initialDate;
  }

  /// Parses date from DD/MM/YYYY format
  DateTime? _parseDateFromField(String dateString) {
    final parts = dateString.split('/');
    if (parts.length != 3) return null;
    
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    
    if (day == null || month == null || year == null) return null;
    
    if (_isValidDateComponents(year, month, day)) {
      return DateTime(year, month, day);
    }
    
    return null;
  }

  /// Validates date components are within acceptable ranges
  bool _isValidDateComponents(int year, int month, int day) {
    return year >= 1900 && 
           month >= 1 && month <= 12 && 
           day >= 1 && day <= 31;
  }

  /// Shows date picker dialog
  Future<DateTime?> _showDatePickerDialog(BuildContext context, DateTime initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
  }

  /// Sets the expiry date in the controller
  void _setExpiryDate(DateTime date) {
    expiryDateController.text = "${date.day}/${date.month}/${date.year}";
  }

  /// Handles errors when showing date picker
  void _handleDatePickerError(dynamic error) {
    print('❌ Error showing date picker: $error');
    if (!_isDisposed) {
      _showErrorMessage('Failed to open date picker. Please try again.');
    }
  }

  /// Formats date from DD/MM/YYYY to YYYY-MM-DD for backend
  String _formatDateForBackend(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        
        if (day != null && month != null && year != null && 
            _isValidDateComponents(year, month, day)) {
          return '${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        }
      }
    } catch (e) {
      print('❌ Error formatting date: $e');
    }
    
    return _getTomorrowBackendFormatted();
  }

  /// Gets tomorrow's date in YYYY-MM-DD format as fallback
  String _getTomorrowBackendFormatted() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
  }

  // ==================== UPDATE METHODS ====================

  /// Handles successful product update
  Future<void> _handleSuccessfulUpdate() async {
    if (_isDisposed) return;
    
    _showSuccessMessage('Product "${partNumberController.text.trim()}" updated successfully');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _updateDashboardAndNavigate();
      }
    });
  }

  /// Updates dashboard controller and navigates back
  void _updateDashboardAndNavigate() {
    try {
      final dashboardController = Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>()
          : null;
      
      if (dashboardController != null) {
        final updatedProduct = _createUpdatedProductModel();
        dashboardController.updateProductInList(updatedProduct);
        print('✅ Product updated in dashboard locally');
      } else {
        print('❌ Dashboard controller not found');
      }
    } catch (e) {
      print('❌ Error updating dashboard: $e');
    }
    
    Get.offAllNamed(AppRoutes.dashboard);
  }

  /// Creates updated ProductModel from current form data
  ProductModel _createUpdatedProductModel() {
    return currentProduct!.copyWith(
      partNumber: partNumberController.text.trim(),
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      quantity: int.tryParse(quantityController.text.trim()) ?? 0,
      batchNumber: batchNumberController.text.trim(), // Keep as string or int depending on model
      expiryDate: _formatDateForBackend(expiryDateController.text.trim()),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Handles errors during product update
  void _handleUpdateError(dynamic error) {
    print('❌ Error updating product: $error');
    
    if (!_isDisposed) {
      final errorMessage = _getErrorMessage(error);
      _showErrorMessage(errorMessage, title: 'Error');
    }
  }

  // ==================== VALIDATION METHODS ====================

  /// Validates all form fields
  bool _validateAllFields() {
    if (_isDisposed) return false;
    
    try {
      return _validateRequiredFields() && 
             _validateNumericFields() && 
             _validateExpiryDate();
    } catch (e) {
      print('❌ Error in validation: $e');
      _showValidationError('Validation error occurred. Please check your inputs.');
      return false;
    }
  }

  /// Validates required text fields
  bool _validateRequiredFields() {
    if (_isFieldEmpty(partNumberController, 'Part Number')) return false;
    if (_isFieldEmpty(descriptionController, 'Description')) return false;
    if (_isFieldEmpty(locationController, 'Location')) return false;
    if (_isFieldEmpty(quantityController, 'Quantity')) return false;
    if (_isFieldEmpty(batchNumberController, 'Batch Number')) return false;
    if (_isFieldEmpty(expiryDateController, 'Expiry Date')) return false;
    
    return true;
  }

  /// Checks if a field is empty and shows error if needed
  bool _isFieldEmpty(TextEditingController controller, String fieldName) {
    if (controller.text.trim().isEmpty) {
      _showValidationError('$fieldName is required');
      return true;
    }
    return false;
  }

  /// Validates numeric fields (quantity and batch number)
  bool _validateNumericFields() {
    if (!_validateQuantity()) return false;
    if (!_validateBatchNumber()) return false;
    return true;
  }

  /// Validates quantity field
  bool _validateQuantity() {
    final quantity = int.tryParse(quantityController.text.trim());
    if (quantity == null || quantity < 0) {
      _showValidationError('Please enter a valid quantity (0 or greater)');
      return false;
    }
    return true;
  }

  /// Validates batch number field
  bool _validateBatchNumber() {
    // Note: If batch number is alphanumeric, this validation might need adjustment
    // But keeping logic consistent with your original code
    final batchNumber = batchNumberController.text.trim();
    if (batchNumber.isEmpty) {
      _showValidationError('Please enter a valid batch number');
      return false;
    }
    return true;
  }

  /// Validates expiry date field
  bool _validateExpiryDate() {
    final dateText = expiryDateController.text.trim();
    
    final parts = dateText.split('/');
    if (parts.length != 3) {
      _showValidationError('Please enter expiry date in DD/MM/YYYY format');
      return false;
    }
    
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    
    if (day == null || month == null || year == null) {
      _showValidationError('Please enter a valid expiry date');
      return false;
    }
    
    return _validateDateRange(year, month, day);
  }

  /// Validates date range and components
  bool _validateDateRange(int year, int month, int day) {
    if (year < DateTime.now().year || year > 2030) {
      _showValidationError('Expiry year must be between ${DateTime.now().year} and 2030');
      return false;
    }
    
    if (month < 1 || month > 12) {
      _showValidationError('Month must be between 1 and 12');
      return false;
    }
    
    if (day < 1 || day > 31) {
      _showValidationError('Day must be between 1 and 31');
      return false;
    }
    
    return _validateDateNotInPast(year, month, day);
  }

  /// Validates that date is not in the past
  bool _validateDateNotInPast(int year, int month, int day) {
    try {
      final expiryDate = DateTime(year, month, day);
      if (expiryDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        _showValidationError('Expiry date cannot be in the past');
        return false;
      }
    } catch (e) {
      _showValidationError('Please enter a valid expiry date');
      return false;
    }
    
    return true;
  }

  // ==================== UTILITY METHODS ====================

  /// Sets loading state safely
  void _setLoadingState(bool loading) {
    if (!_isDisposed) {
      isLoading.value = loading;
    }
  }

  // ==================== ERROR HANDLING METHODS ====================

  /// Gets user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().replaceAll('Exception: ', '');
    
    if (errorStr.contains('timeout')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (errorStr.contains('Network') || errorStr.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('token') || errorStr.contains('authentication')) {
      return 'Authentication error. Please login again.';
    } else if (errorStr.contains('Invalid')) {
      return 'Invalid data provided. Please check your inputs.';
    } else if (errorStr.contains('server') || errorStr.contains('backend')) {
      return 'Server error. Please try again later.';
    } else {
      return errorStr.isEmpty ? 'An unexpected error occurred' : errorStr;
    }
  }

  // ==================== UI FEEDBACK METHODS ====================

  /// Shows validation error message
  void _showValidationError(String message) {
    if (!_isDisposed) {
      Get.snackbar(
        'Validation Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        colorText: Colors.orange[800],
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Shows success message
  void _showSuccessMessage(String message) {
    if (!_isDisposed) {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green[800],
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Shows error message
  void _showErrorMessage(String message, {String title = 'Error'}) {
    if (!_isDisposed) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 4),
      );
    }
  }
}