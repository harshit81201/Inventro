import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';
import 'package:inventro/app/utils/responsive_utils.dart';
import 'product_detail_dialog.dart';

class ProductGrid extends StatelessWidget {
  final DashboardController dashboardController;

  const ProductGrid({
    super.key,
    required this.dashboardController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.06)),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(210),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: ResponsiveUtils.getSpacing(context, 16),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
          _buildSearchBar(context),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
          _buildProductList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
        
        if (isSmallScreen) {
          // Stack vertically on small screens
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your Products',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildRefreshButton(context),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
              _buildProductCounter(context),
            ],
          );
        } else {
          // Keep horizontal layout for larger screens
          return Row(
            children: [
              // FIXED: Wrapped in Flexible to prevent overflow
              Flexible(
                child: Text(
                  'Your Products',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis, // Added overflow handling
                  maxLines: 1,
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
              
              // Prevent counter from shrinking too much or causing overflow
              _buildProductCounter(context),
              
              const Spacer(),
              _buildRefreshButton(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildProductCounter(BuildContext context) {
    return Obx(() {
      // Only show counter when initialized to avoid showing incorrect counts
      if (!dashboardController.isInitialized.value) {
        return const SizedBox.shrink();
      }
      
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getPadding(context, factor: 0.02),
          vertical: ResponsiveUtils.getSpacing(context, 4),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF4A00E0).withOpacity(0.1),
          borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
          border: Border.all(color: const Color(0xFF4A00E0).withOpacity(0.3)),
        ),
        child: Text(
          '${dashboardController.products.length} total • ${dashboardController.filteredProducts.length} shown',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 12),
            color: const Color(0xFF4A00E0),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }

  Widget _buildRefreshButton(BuildContext context) {
    return Obx(() => dashboardController.isLoading.value 
      ? SizedBox(
          width: ResponsiveUtils.getSpacing(context, 20),
          height: ResponsiveUtils.getSpacing(context, 20),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A00E0)),
          ),
        )
      : Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: ResponsiveUtils.getSpacing(context, 8),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.refresh, 
              color: const Color(0xFF4A00E0),
              size: ResponsiveUtils.getIconSize(context, 20),
            ),
            tooltip: 'Refresh Products',
            onPressed: dashboardController.refreshProducts,
            constraints: BoxConstraints(
              minWidth: ResponsiveUtils.getSpacing(context, 36),
              minHeight: ResponsiveUtils.getSpacing(context, 36),
            ),
          ),
        ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Obx(() {
      // Only show search bar when initialized and has products
      if (!dashboardController.isInitialized.value) {
        return const SizedBox.shrink();
      }
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: ResponsiveUtils.getSpacing(context, 8),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: dashboardController.searchController,
          decoration: InputDecoration(
            hintText: ResponsiveUtils.isSmallScreen(context) 
              ? 'Search products...'
              : 'Search products by part number, description, location...',
            hintStyle: TextStyle(
              color: Colors.grey[400], 
              fontSize: ResponsiveUtils.getFontSize(context, 14),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: const Color(0xFF4A00E0),
              size: ResponsiveUtils.getIconSize(context, 20),
            ),
            suffixIcon: Obx(() => dashboardController.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear, 
                      color: Colors.grey[400], 
                      size: ResponsiveUtils.getIconSize(context, 20),
                    ),
                    onPressed: dashboardController.clearSearch,
                  )
                : const SizedBox.shrink()),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getPadding(context, factor: 0.04),
              vertical: ResponsiveUtils.getSpacing(context, 12),
            ),
          ),
          style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14)),
        ),
      );
    });
  }

  Widget _buildProductList(BuildContext context) {
    return Obx(() {
      // Show loading spinner for initial load when not initialized
      if (!dashboardController.isInitialized.value) {
        return Container(
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 40)),
          child: const Center(
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A00E0)),
                ),
                SizedBox(height: 16),
                Text(
                  'Initializing dashboard...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      // Show loading overlay for refresh operations
      if (dashboardController.isLoading.value && dashboardController.products.isNotEmpty) {
        return Stack(
          children: [
            _buildProductContent(context),
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 20)),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A00E0)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Refreshing...'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }
      
      return _buildProductContent(context);
    });
  }

  Widget _buildProductContent(BuildContext context) {
    // Show error state with retry option
    if (dashboardController.hasError.value && dashboardController.products.isEmpty) {
      return _buildErrorState(context);
    }
    
    // Show empty state when no products but no error
    if (dashboardController.products.isEmpty) {
      return _buildEmptyState(context);
    }

    // Show no search results state
    if (dashboardController.filteredProducts.isEmpty && dashboardController.searchQuery.value.isNotEmpty) {
      return _buildNoResultsState(context);
    }
    
    // Show filtered products list with responsive layout
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveUtils.isLargeScreen(context) && constraints.maxWidth > 600) {
          // Use grid layout for larger screens
          return _buildGridView(context);
        } else {
          // Use list layout for smaller screens
          return _buildListView(context);
        }
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dashboardController.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = dashboardController.filteredProducts[index];
        return _buildProductCard(context, product, index);
      },
    );
  }

  Widget _buildGridView(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: ResponsiveUtils.getSpacing(context, 16),
        mainAxisSpacing: ResponsiveUtils.getSpacing(context, 16),
      ),
      itemCount: dashboardController.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = dashboardController.filteredProducts[index];
        return _buildProductCard(context, product, index, isGrid: true);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product, int index, {bool isGrid = false}) {
    // Safely get product properties with null checks
    bool isExpired = false;
    bool isExpiringSoon = false;
    Color statusColor = const Color(0xFF6C757D);
    
    try {
      isExpired = product?.isExpired ?? false;
      final daysUntilExpiry = product?.daysUntilExpiry ?? 999;
      // Updated logic: expiring soon = within 7 days and not expired
      isExpiringSoon = daysUntilExpiry <= 7 && daysUntilExpiry >= 0 && !isExpired;
      
      // Determine status color based on expiry and stock
      if (isExpired) {
        statusColor = const Color(0xFFDC3545); // Red for expired
      } else if (isExpiringSoon) {
        statusColor = const Color(0xFFFFC107); // Amber for expiring soon (within 7 days)
      } else if (product?.quantity != null && product.quantity <= 1) {
        statusColor = const Color(0xFF800020); // Dark red for low stock
      } else {
        statusColor = const Color(0xFF28A745); // Green for good condition
      }
    } catch (e) {
      print('⚠️ Error processing product status: $e');
      // Fallback values are already set above
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: isGrid ? 0 : ResponsiveUtils.getSpacing(context, 16)),
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.05)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 16)),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: ResponsiveUtils.getSpacing(context, 8),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showProductDetails(context, product),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(context, product, statusColor, isGrid),
            SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
            _buildProductDetails(context, product),
            if (isExpired || isExpiringSoon) ...[
              SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
              _buildStatusBadge(context, product, statusColor, isExpired),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, dynamic product, Color statusColor, bool isGrid) {
    // Safely get product properties
    final partNumber = product?.partNumber?.toString() ?? 'Unknown';
    final description = product?.description?.toString() ?? 'No description';
    final quantity = product?.quantity?.toString() ?? '0';
    
    return Row(
      children: [
        Container(
          width: ResponsiveUtils.getSpacing(context, isGrid ? 40 : 50),
          height: ResponsiveUtils.getSpacing(context, isGrid ? 40 : 50),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
          ),
          child: Center(
            child: Text(
              partNumber.isNotEmpty 
                ? partNumber.substring(0, 1).toUpperCase()
                : 'P',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.getFontSize(context, isGrid ? 16 : 20),
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                partNumber,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getFontSize(context, isGrid ? 14 : 18),
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
              Text(
                description,
                style: TextStyle(
                  color: const Color(0xFF6C757D), 
                  fontSize: ResponsiveUtils.getFontSize(context, isGrid ? 12 : 14),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: isGrid ? 1 : 2,
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.getSpacing(context, 8),
            horizontal: ResponsiveUtils.getSpacing(context, 12),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.2),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
            border: Border.all(color: const Color(0xFF2196F3)),
          ),
          child: Text(
            'Qty: $quantity',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2196F3),
              fontSize: ResponsiveUtils.getFontSize(context, 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails(BuildContext context, dynamic product) {
    // Safely get product properties
    final location = product?.location?.toString() ?? 'Unknown location';
    final formattedExpiryDate = product?.formattedExpiryDate?.toString() ?? 'No date';
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on, 
                size: ResponsiveUtils.getIconSize(context, 16), 
                color: Colors.grey[600],
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, 4)),
              Flexible(
                child: Text(
                  'Location: $location',
                  style: TextStyle(
                    color: Colors.grey[600], 
                    fontSize: ResponsiveUtils.getFontSize(context, 12),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
          Row(
            children: [
              Icon(
                Icons.schedule, 
                size: ResponsiveUtils.getIconSize(context, 16), 
                color: Colors.grey[600],
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, 4)),
              Flexible(
                child: Text(
                  'Expires: $formattedExpiryDate',
                  style: TextStyle(
                    color: Colors.grey[600], 
                    fontSize: ResponsiveUtils.getFontSize(context, 12),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, dynamic product, Color statusColor, bool isExpired) {
    final daysUntilExpiry = product?.daysUntilExpiry ?? 999;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getSpacing(context, 8),
        horizontal: ResponsiveUtils.getSpacing(context, 12),
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 8)),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.error : Icons.warning,
            color: statusColor,
            size: ResponsiveUtils.getIconSize(context, 16),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
          Flexible(
            child: Text(
              isExpired 
                ? 'EXPIRED'
                : 'Expires in $daysUntilExpiry days',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.getFontSize(context, 12),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 40)),
      child: Column(
        children: [
          Icon(
            Icons.error_outline, 
            size: ResponsiveUtils.getSpacing(context, 64), 
            color: Colors.red[400],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
          Text(
            'Failed to Load Products',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 18), 
              color: Colors.red[600], 
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
          Text(
            dashboardController.errorMessage.value.isNotEmpty 
              ? dashboardController.errorMessage.value
              : 'Unable to connect to server. Please check your internet connection.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveUtils.getFontSize(context, 14),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
          Wrap(
            spacing: ResponsiveUtils.getSpacing(context, 12),
            runSpacing: ResponsiveUtils.getSpacing(context, 12),
            children: [
              ElevatedButton.icon(
                onPressed: dashboardController.retryFetch,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getSpacing(context, 24), 
                    vertical: ResponsiveUtils.getSpacing(context, 12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: dashboardController.testBackendConnection,
                icon: const Icon(Icons.network_check),
                label: const Text('Test Connection'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A00E0),
                  side: const BorderSide(color: Color(0xFF4A00E0)),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getSpacing(context, 24), 
                    vertical: ResponsiveUtils.getSpacing(context, 12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 40)),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined, 
            size: ResponsiveUtils.getSpacing(context, 64), 
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 18), 
              color: Colors.grey[600], 
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
          Text(
            'Add your first product to get started',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: ResponsiveUtils.getFontSize(context, 14),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
          ElevatedButton.icon(
            onPressed: dashboardController.refreshProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A00E0),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getSpacing(context, 24), 
                vertical: ResponsiveUtils.getSpacing(context, 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 40)),
      child: Column(
        children: [
          Icon(
            Icons.search_off, 
            size: ResponsiveUtils.getSpacing(context, 64), 
            color: Colors.orange[400],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A202C),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
          Obx(() => Text(
            'No products match "${dashboardController.searchQuery.value}"',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 14),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          )),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
          ElevatedButton.icon(
            onPressed: dashboardController.clearSearch,
            icon: const Icon(Icons.clear),
            label: const Text('Clear Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A00E0),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getSpacing(context, 24), 
                vertical: ResponsiveUtils.getSpacing(context, 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(BuildContext context, product) {
    try {
      if (product != null) {
        Get.dialog(
          ProductDetailDialog(
            product: product,
            controller: dashboardController,
          ),
        );
      }
    } catch (e) {
      print('⚠️ Error showing product details: $e');
      Get.snackbar(
        'Error',
        'Unable to show product details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
      );
    }
  }
}