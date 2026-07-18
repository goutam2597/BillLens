import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.serverId,
    required super.name,
    super.firstName,
    super.lastName,
    required super.email,
    super.phone,
    super.businessName,
    super.address,
    super.city,
    super.state,
    super.zip,
    super.avatarUrl,
    required super.currency,
    super.token,
    required super.subscriptionStatus,
    super.subscriptionExpiry,
    required super.createdAt,
    required super.updatedAt,
    super.hasPassword = true,
    super.accountStatus,
    super.blockedAt,
    super.deletionRequestedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      serverId: json['server_id']?.toString(),
      name: json['name'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'] ?? '',
      phone: json['phone'],
      businessName: json['business_name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      avatarUrl: json['avatar_url'],
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
      hasPassword: json['has_password'] == true || json['has_password'] == 1,
      accountStatus: json['account_status']?.toString(),
      blockedAt: json['blocked_at'] != null
          ? DateTime.tryParse(json['blocked_at'].toString())
          : null,
      deletionRequestedAt: json['deletion_requested_at'] != null
          ? DateTime.tryParse(json['deletion_requested_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'server_id': serverId,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'business_name': businessName,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'avatar_url': avatarUrl,
      'currency': currency,
      'token': token,
      'subscription_status': subscriptionStatus,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'has_password': hasPassword,
      'account_status': accountStatus,
      'blocked_at': blockedAt?.toIso8601String(),
      'deletion_requested_at': deletionRequestedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      serverId: entity.serverId,
      name: entity.name,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      phone: entity.phone,
      businessName: entity.businessName,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      zip: entity.zip,
      avatarUrl: entity.avatarUrl,
      currency: entity.currency,
      token: entity.token,
      subscriptionStatus: entity.subscriptionStatus,
      subscriptionExpiry: entity.subscriptionExpiry,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      hasPassword: entity.hasPassword,
      accountStatus: entity.accountStatus,
      blockedAt: entity.blockedAt,
      deletionRequestedAt: entity.deletionRequestedAt,
    );
  }
}
