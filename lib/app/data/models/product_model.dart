import 'package:intl/intl.dart';

class ProductModel {
  final int? id;
  final String partNumber; // product_name
  final String description; // product_type
  final String location;
  final int quantity;
  final String batchNumber; // Treated as String to handle "BATCH001"
  final String expiryDate;
  final String companyId;
  final String? createdAt;
  final String? updatedAt;
  final bool isBulkUploaded;

  // 🌟 NEW CSV FIELDS
  final String? serialNumber;
  final String? lotNumber;
  final String? condition;
  final double? price;
  final String? paymentStatus;
  final String? receiver;
  final String? receiverContact;
  final String? remark;

  ProductModel({
    this.id,
    required this.partNumber,
    required this.description,
    required this.location,
    required this.quantity,
    required this.batchNumber,
    required this.expiryDate,
    required this.companyId,
    this.createdAt,
    this.updatedAt,
    this.isBulkUploaded = false,
    // Initialize new fields
    this.serialNumber,
    this.lotNumber,
    this.condition,
    this.price,
    this.paymentStatus,
    this.receiver,
    this.receiverContact,
    this.remark,
  });

  // Create ProductModel from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        // Map 'id' OR 'product_id' (handles both Legacy & New API)
        id: _safeParseInt(json['id'] ?? json['product_id']),
        partNumber: _safeParseString(json['part_number']) ?? '',
        description: _safeParseString(json['description']) ?? '',
        location: _safeParseString(json['location']) ?? '',
        quantity: _safeParseInt(json['quantity']) ?? 0,
        batchNumber: json['batch_number']?.toString() ?? '',
        expiryDate: _safeParseDate(json['expiry_date'] ?? json['expiry']),
        companyId: _safeParseString(json['company_id']) ?? '',
        createdAt: _safeParseString(json['created_at'], allowNull: true),
        updatedAt: _safeParseString(json['updated_on'] ?? json['updated_at'], allowNull: true),
        isBulkUploaded: json['is_bulk_uploaded'] ?? false,
        
        // 🌟 Map New CSV Fields
        serialNumber: _safeParseString(json['serial_number'], allowNull: true),
        lotNumber: _safeParseString(json['lot_number'], allowNull: true),
        condition: _safeParseString(json['condition'], allowNull: true),
        price: _safeParseDouble(json['price']),
        paymentStatus: _safeParseString(json['payment_status'], allowNull: true),
        receiver: _safeParseString(json['receiver'], allowNull: true),
        receiverContact: _safeParseString(json['receiver_contact'], allowNull: true),
        remark: _safeParseString(json['remark'], allowNull: true),
      );
    } catch (e) {
      print('❌ Error creating ProductModel from JSON: $e');
      rethrow;
    }
  }

  // Helper for Double (Price)
  static double? _safeParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  // Helper method to safely parse strings
  static String? _safeParseString(dynamic value, {bool allowNull = false}) {
    if (value == null) {
      if (allowNull) return null;
      return '';
    }
    return value.toString().trim();
  }

  // Helper method to safely parse integers
  static int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  // Helper method to safely parse and validate dates
  static String _safeParseDate(dynamic value) {
    if (value == null) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return tomorrow.toIso8601String().split('T')[0];
    }
    
    final dateStr = value.toString().trim();
    if (dateStr.isEmpty) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return tomorrow.toIso8601String().split('T')[0];
    }
    
    try {
      if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(dateStr)) {
        return dateStr.split('T')[0];
      }
      if (RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$').hasMatch(dateStr)) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      }
      final parsed = DateTime.parse(dateStr);
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    } catch (e) {
      print('⚠️ Warning: Could not parse date "$dateStr", using tomorrow as default');
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return tomorrow.toIso8601String().split('T')[0];
    }
  }

  // Convert ProductModel to JSON (for backend)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'part_number': partNumber,
      'description': description,
      'location': location,
      'quantity': quantity,
      'batch_number': batchNumber,
      'expiry_date': expiryDate,
      'company_id': companyId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      'is_bulk_uploaded': isBulkUploaded,
      // Add CSV fields if they exist
      if (serialNumber != null) 'serial_number': serialNumber,
      if (lotNumber != null) 'lot_number': lotNumber,
      if (condition != null) 'condition': condition,
      if (price != null) 'price': price,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (receiver != null) 'receiver': receiver,
      if (receiverContact != null) 'receiver_contact': receiverContact,
      if (remark != null) 'remark': remark,
    };
  }

  // Helper method to format expiry date
  String get formattedExpiryDate {
    try {
      if (expiryDate.isEmpty) return 'No date set';
      if (expiryDate.contains('-')) {
         final dateTime = DateTime.parse(expiryDate);
         return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      }
      return expiryDate;
    } catch (e) {
      return expiryDate.isNotEmpty ? expiryDate : 'Invalid date';
    }
  }

  // Helper method to check if product is expired
  bool get isExpired {
    try {
      if (expiryDate.isEmpty) return false;
      final dateTime = DateTime.parse(expiryDate);
      final now = DateTime.now();
      final expiryDateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final nowDateOnly = DateTime(now.year, now.month, now.day);
      return expiryDateOnly.isBefore(nowDateOnly);
    } catch (e) {
      return false;
    }
  }

  // Helper method to check if product is expiring soon
  bool get isExpiringSoon {
    try {
      if (isExpired) return false;
      final days = daysUntilExpiry;
      return days >= 0 && days <= 7;
    } catch (e) {
      return false;
    }
  }

  // Helper method to get days until expiry
  int get daysUntilExpiry {
    try {
      if (expiryDate.isEmpty) return 999;
      final dateTime = DateTime.parse(expiryDate);
      final now = DateTime.now();
      final expiryDateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final nowDateOnly = DateTime(now.year, now.month, now.day);
      return expiryDateOnly.difference(nowDateOnly).inDays;
    } catch (e) {
      return 999;
    }
  }

  // Helper method to format created_at
  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.isEmpty) return 'Date added: Not available';
    try {
      final dateTime = DateTime.parse(createdAt!);
      final formatter = DateFormat.yMMMMd().add_jm();
      return 'Added on: ${formatter.format(dateTime)}';
    } catch (e) {
      return 'Added on: ${createdAt!}';
    }
  }

  // Helper method to get expiry status
  String get expiryStatus {
    try {
      if (isExpired) return 'EXPIRED';
      final days = daysUntilExpiry;
      if (days <= 7) return 'EXPIRES SOON';
      if (days <= 30) return 'EXPIRING';
      return 'GOOD';
    } catch (e) {
      return 'UNKNOWN';
    }
  }

  // Helper method to validate the model data
  bool get isValid {
    try {
      return partNumber.isNotEmpty &&
             description.isNotEmpty &&
             location.isNotEmpty &&
             quantity >= 0 &&
             batchNumber.isNotEmpty &&
             expiryDate.isNotEmpty &&
             companyId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, partNumber: $partNumber, description: $description, quantity: $quantity, isBulkUploaded: $isBulkUploaded)';
  }

  // Create a copy of the product with updated fields
  ProductModel copyWith({
    int? id,
    String? partNumber,
    String? description,
    String? location,
    int? quantity,
    String? batchNumber,
    String? expiryDate,
    String? companyId,
    String? createdAt,
    String? updatedAt,
    bool? isBulkUploaded,
    String? serialNumber,
    String? lotNumber,
    String? condition,
    double? price,
    String? paymentStatus,
    String? receiver,
    String? receiverContact,
    String? remark,
  }) {
    return ProductModel(
      id: id ?? this.id,
      partNumber: partNumber ?? this.partNumber,
      description: description ?? this.description,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBulkUploaded: isBulkUploaded ?? this.isBulkUploaded,
      serialNumber: serialNumber ?? this.serialNumber,
      lotNumber: lotNumber ?? this.lotNumber,
      condition: condition ?? this.condition,
      price: price ?? this.price,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      receiver: receiver ?? this.receiver,
      receiverContact: receiverContact ?? this.receiverContact,
      remark: remark ?? this.remark,
    );
  }
}