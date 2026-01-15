class AuditLogModel {
  final int? id;
  final int? productId;
  final String? actionType;
  final String? changes;
  final int? changedBy;
  final String? companyId;
  final String? productUniqueId;
  final DateTime? createdAt;

  AuditLogModel({
    this.id,
    this.productId,
    this.actionType,
    this.changes,
    this.changedBy,
    this.companyId,
    this.productUniqueId,
    this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'],
      productId: json['product_id'],
      actionType: json['action_type'],
      changes: json['changes'],
      changedBy: json['changed_by'],
      companyId: json['company_id'],
      productUniqueId: json['product_unique_id'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
}