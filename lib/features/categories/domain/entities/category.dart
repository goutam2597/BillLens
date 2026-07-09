/// Category domain entity
class Category {
  final String id;
  final String? serverId;
  final String userId;
  final String name;
  final String type; // 'business' or 'personal'
  final String icon;
  final String color;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    this.serverId,
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isBusiness => type == 'business';
  bool get isPersonal => type == 'personal';

  Category copyWith({
    String? id,
    String? serverId,
    String? userId,
    String? name,
    String? type,
    String? icon,
    String? color,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
