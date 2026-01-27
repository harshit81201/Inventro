import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';

class ProductDetailDialog extends StatelessWidget {
  final dynamic product;
  final DashboardController controller;

  const ProductDetailDialog({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildStatusBadge(context),
                    const SizedBox(height: 20),
                    
                    // 1. Basic Info
                    _buildInfoCard(context, 'Basic Information', Icons.info_outline, [
                      _buildDetailRow(Icons.qr_code, "Part Number", product.partNumber),
                      _buildDetailRow(Icons.description, "Description", product.description),
                      _buildDetailRow(Icons.batch_prediction, "Batch", product.batchNumber),
                      // Show Serial/Lot if available (CSV specific)
                      if (product.serialNumber != null) 
                        _buildDetailRow(Icons.pin, "Serial No.", product.serialNumber!),
                      if (product.lotNumber != null) 
                        _buildDetailRow(Icons.layers, "Lot No.", product.lotNumber!),
                    ]),
                    
                    const SizedBox(height: 16),

                    // 2. Inventory Details
                    _buildInfoCard(context, 'Inventory', Icons.warehouse, [
                      _buildDetailRow(Icons.location_on, "Location", product.location),
                      _buildDetailRow(Icons.inventory, "Quantity", "${product.quantity}"),
                      _buildDetailRow(Icons.calendar_today, "Expiry", product.formattedExpiryDate),
                      if (product.condition != null)
                        _buildDetailRow(Icons.star_outline, "Condition", product.condition!),
                      if (product.price != null)
                        _buildDetailRow(Icons.attach_money, "Price", "\$${product.price}"),
                    ]),

                    // 3. 🌟 NEW: Distribution / CSV Extra Details
                    if (product.receiver != null || product.remark != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoCard(context, 'Distribution & Remarks', Icons.local_shipping, [
                        if (product.receiver != null)
                          _buildDetailRow(Icons.person, "Receiver", product.receiver!),
                        if (product.receiverContact != null)
                          _buildDetailRow(Icons.phone, "Contact", product.receiverContact!),
                        if (product.paymentStatus != null)
                          _buildDetailRow(Icons.payments, "Payment", product.paymentStatus!),
                        if (product.remark != null)
                          _buildDetailRow(Icons.note, "Remark", product.remark!),
                      ]),
                    ],

                    const SizedBox(height: 24),
                    
                    // 🌟 ACTIONS (Fixed Visibility)
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (Keep _buildHeader same as before)
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF4A00E0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Product Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    // Simplified status badge logic for brevity
    bool isExpired = product.isExpired;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isExpired ? Colors.red : Colors.green),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isExpired ? Icons.error : Icons.check_circle, 
               color: isExpired ? Colors.red : Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(isExpired ? "EXPIRED" : "Good Condition", 
               style: TextStyle(color: isExpired ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF4A00E0)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // 🌟 FIX: Show buttons if ID exists OR if it's a Bulk Uploaded item (assuming we mapped ID correctly)
    bool canEdit = (product.id != null && product.id != 0) || product.isBulkUploaded;

    if (!canEdit) {
      // Fallback if ID is missing
      return const Text("Actions unavailable (Invalid ID)", style: TextStyle(color: Colors.grey));
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.editProduct, arguments: product);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Edit"),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4A00E0),
              side: const BorderSide(color: Color(0xFF4A00E0)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _confirmDelete(),
            icon: const Icon(Icons.delete, size: 18, color: Colors.white),
            label: const Text("Delete", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC3545)),
          ),
        ),
      ],
    );
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: "Confirm Delete",
      middleText: "Are you sure you want to delete '${product.partNumber}'?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFDC3545),
      onConfirm: () {
        Get.back(); // Close Confirm
        Get.back(); // Close Details
        controller.deleteProduct(product); // Pass full product
      },
    );
  }
}