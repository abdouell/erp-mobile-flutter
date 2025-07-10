import 'permission.dart';

class Role {
  final int id;
  final String? name;
  final String? description;
  final List<Permission> permissions;
  
  Role({
    required this.id,
    this.name,
    this.description,
    this.permissions = const [],
  });
  
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
              .map((p) => Permission.fromJson(p))
              .toList()
          : [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions.map((p) => p.toJson()).toList(),
    };
  }
}