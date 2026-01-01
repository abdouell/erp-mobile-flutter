import 'permission_dto.dart';

class RoleDto {
  final int id;
  final String name;
  final String description;
  final List<PermissionDto> permissions;
  
  RoleDto({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });
  
  factory RoleDto.fromJson(Map<String, dynamic> json) {
    return RoleDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      permissions: (json['permissions'] as List?)
          ?.map((p) => PermissionDto.fromJson(p))
          .toList() ?? [],
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
  
  /// Check if role has specific permission
  bool hasPermission(String permission) {
    return permissions.any((p) => p.name == permission);
  }
}
