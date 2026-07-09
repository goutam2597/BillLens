/// User domain entity
class UserEntity {
  final String id;
  final String? serverId;
  final String name;
  final String email;
  final String? businessName;
  final String currency;
  final String? token;
  final String subscriptionStatus;
  final DateTime? subscriptionExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    this.serverId,
    required this.name,
    required this.email,
    this.businessName,
    required this.currency,
    this.token,
    required this.subscriptionStatus,
    this.subscriptionExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPremium => subscriptionStatus == 'premium';
  bool get isFree => subscriptionStatus == 'free';

  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  UserEntity copyWith({
    String? id,
    String? serverId,
    String? name,
    String? email,
    String? businessName,
    String? currency,
    String? token,
    String? subscriptionStatus,
    DateTime? subscriptionExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      currency: currency ?? this.currency,
      token: token ?? this.token,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
