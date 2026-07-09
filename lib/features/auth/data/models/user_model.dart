import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.serverId,
    required super.name,
    required super.email,
    super.businessName,
    required super.currency,
    super.token,
    required super.subscriptionStatus,
    super.subscriptionExpiry,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      serverId: json['server_id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      businessName: json['business_name'],
      currency: json['currency'] ?? 'USD',
      token: json['token'],
      subscriptionStatus: json['subscription_status'] ?? 'free',
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.tryParse(json['subscription_expiry'])
          : null,
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
      'name': name,
      'email': email,
      'business_name': businessName,
      'currency': currency,
      'token': token,
      'subscription_status': subscriptionStatus,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      serverId: entity.serverId,
      name: entity.name,
      email: entity.email,
      businessName: entity.businessName,
      currency: entity.currency,
      token: entity.token,
      subscriptionStatus: entity.subscriptionStatus,
      subscriptionExpiry: entity.subscriptionExpiry,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
