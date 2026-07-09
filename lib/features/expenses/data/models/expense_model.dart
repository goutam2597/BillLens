import '../../domain/entities/expense.dart';

/// Data model for [Expense]. Extends the domain entity and adds
/// JSON / database conversion helpers.
class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    super.serverId,
    required super.userId,
    required super.vendor,
    required super.amount,
    required super.currency,
    super.categoryId,
    super.categoryName,
    super.categoryIcon,
    required super.date,
    super.paymentMethod,
    super.clientName,
    super.projectName,
    super.notes,
    super.receiptImageLocalPath,
    super.receiptImageRemoteUrl,
    super.aiConfidence,
    super.aiExplanation,
    required super.syncStatus,
    super.isDeleted = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      serverId: json['server_id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      vendor: json['vendor'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name']?.toString(),
      categoryIcon: json['category_icon']?.toString(),
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: json['payment_method']?.toString(),
      clientName: json['client_name']?.toString(),
      projectName: json['project_name']?.toString(),
      notes: json['notes']?.toString(),
      receiptImageLocalPath: json['receipt_image_local_path']?.toString(),
      receiptImageRemoteUrl: json['receipt_image_remote_url']?.toString(),
      aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
      aiExplanation: json['ai_explanation']?.toString(),
      syncStatus: json['sync_status'] ?? 'pending',
      isDeleted: json['is_deleted'] == true || json['is_deleted'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'server_id': serverId,
      'user_id': userId,
      'vendor': vendor,
      'amount': amount,
      'currency': currency,
      'category_id': categoryId,
      'category_name': categoryName,
      'category_icon': categoryIcon,
      'date': date.toIso8601String(),
      'payment_method': paymentMethod,
      'client_name': clientName,
      'project_name': projectName,
      'notes': notes,
      'receipt_image_local_path': receiptImageLocalPath,
      'receipt_image_remote_url': receiptImageRemoteUrl,
      'ai_confidence': aiConfidence,
      'ai_explanation': aiExplanation,
      'sync_status': syncStatus,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      serverId: entity.serverId,
      userId: entity.userId,
      vendor: entity.vendor,
      amount: entity.amount,
      currency: entity.currency,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryIcon: entity.categoryIcon,
      date: entity.date,
      paymentMethod: entity.paymentMethod,
      clientName: entity.clientName,
      projectName: entity.projectName,
      notes: entity.notes,
      receiptImageLocalPath: entity.receiptImageLocalPath,
      receiptImageRemoteUrl: entity.receiptImageRemoteUrl,
      aiConfidence: entity.aiConfidence,
      aiExplanation: entity.aiExplanation,
      syncStatus: entity.syncStatus,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ExpenseModel copyWithModel({
    String? id,
    String? serverId,
    String? userId,
    String? vendor,
    double? amount,
    String? currency,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    DateTime? date,
    String? paymentMethod,
    String? clientName,
    String? projectName,
    String? notes,
    String? receiptImageLocalPath,
    String? receiptImageRemoteUrl,
    double? aiConfidence,
    String? aiExplanation,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      vendor: vendor ?? this.vendor,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      clientName: clientName ?? this.clientName,
      projectName: projectName ?? this.projectName,
      notes: notes ?? this.notes,
      receiptImageLocalPath: receiptImageLocalPath ?? this.receiptImageLocalPath,
      receiptImageRemoteUrl: receiptImageRemoteUrl ?? this.receiptImageRemoteUrl,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
