/// User domain entity
class UserEntity {
  final String id;
  final String? serverId;
  final String name;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String? businessName;
  final String? address;
  final String? city;
  final String? state;
  final String? zip;
  final String? avatarUrl;
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
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    this.businessName,
    this.address,
    this.city,
    this.state,
    this.zip,
    this.avatarUrl,
    required this.currency,
    this.token,
    required this.subscriptionStatus,
    this.subscriptionExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPremium => subscriptionStatus == 'premium';
  bool get isFree => subscriptionStatus == 'free';

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      return '$firstName ${lastName ?? ''}'.trim();
    }
    return name.isNotEmpty ? name : email.split('@').first;
  }

  String get initials {
    final first = firstName ?? name.split(' ').first;
    final last = lastName ?? (name.split(' ').length > 1 ? name.split(' ').last : '');
    if (last.isNotEmpty) return '${first[0]}${last[0]}'.toUpperCase();
    return first[0].toUpperCase();
  }

  UserEntity copyWith({
    String? id,
    String? serverId,
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? businessName,
    String? address,
    String? city,
    String? state,
    String? zip,
    String? avatarUrl,
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
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
