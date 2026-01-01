import 'role_dto.dart';

class UserDto {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final RoleDto role;
  final List<String> entrepotCodes;
  final bool canAccessDashboard;
  final bool canAccessMobile;
  
  UserDto({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.entrepotCodes,
    required this.canAccessDashboard,
    required this.canAccessMobile,
  });
  
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: RoleDto.fromJson(json['role'] ?? {}),
      entrepotCodes: List<String>.from(json['entrepotCodes'] ?? []),
      canAccessDashboard: json['canAccessDashboard'] ?? false,
      canAccessMobile: json['canAccessMobile'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toJson(),
      'entrepotCodes': entrepotCodes,
      'canAccessDashboard': canAccessDashboard,
      'canAccessMobile': canAccessMobile,
    };
  }
  
  /// Get full name for UI display
  String get fullName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    return username;
  }
  
  /// Get display name (same as fullName for compatibility)
  String get displayName => fullName;
  
  /// Vérifier si user a une permission
  bool hasPermission(String permissionName) {
    if (role?.permissions == null) return false;
    return role!.permissions.any((p) => p.name == permissionName);
  }
}
