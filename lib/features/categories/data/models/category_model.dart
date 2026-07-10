import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    super.serverId,
    required super.userId,
    required super.name,
    required super.type,
    required super.icon,
    required super.color,
    required super.syncStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      serverId: json['server_id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'business',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#2563EB',
      syncStatus: json['sync_status'] ?? 'pending',
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
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'sync_status': syncStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      serverId: entity.serverId,
      userId: entity.userId,
      name: entity.name,
      type: entity.type,
      icon: entity.icon,
      color: entity.color,
      syncStatus: entity.syncStatus,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  CategoryModel copyWithModel({
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
    return CategoryModel(
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
}
