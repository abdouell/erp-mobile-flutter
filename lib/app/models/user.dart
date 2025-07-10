import 'role.dart';

class User {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final Role? role;
  
  User({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.role,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
    );
  }
  
  
  // Nom complet
  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }
  
  // Nom d'affichage (nom complet ou username)
  String get displayName {
    final full = fullName;
    return full.isNotEmpty ? full : username;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'role': role?.toJson(),
    };
  }
  
  // Vérifier si user a une permission
  bool hasPermission(String permissionName) {
    if (role?.permissions == null) return false;
    return role!.permissions.any((p) => p.name == permissionName);
  }
}