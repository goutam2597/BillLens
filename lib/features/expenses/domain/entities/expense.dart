/// Expense entity for domain layer
class Expense {
  final String id;
  final String? serverId;
  final String userId;
  final String vendor;
  final double amount;
  final String currency;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final DateTime date;
  final String? paymentMethod;
  final String? clientName;
  final String? projectName;
  final String? notes;
  final String? receiptImageLocalPath;
  final String? receiptImageRemoteUrl;
  final String? receiptNumber;
  final double? aiConfidence;
  final String? aiExplanation;
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    this.serverId,
    required this.userId,
    required this.vendor,
    required this.amount,
    required this.currency,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    required this.date,
    this.paymentMethod,
    this.clientName,
    this.projectName,
    this.notes,
    this.receiptImageLocalPath,
    this.receiptImageRemoteUrl,
    this.receiptNumber,
    this.aiConfidence,
    this.aiExplanation,
    required this.syncStatus,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Expense copyWith({
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
    String? receiptNumber,
    double? aiConfidence,
    String? aiExplanation,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
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
      receiptImageLocalPath:
          receiptImageLocalPath ?? this.receiptImageLocalPath,
      receiptImageRemoteUrl:
          receiptImageRemoteUrl ?? this.receiptImageRemoteUrl,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
