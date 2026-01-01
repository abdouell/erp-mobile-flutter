class PermissionDto {
  final int id;
  final String name;
  final String description;
  
  PermissionDto({
    required this.id,
    required this.name,
    required this.description,
  });
  
  factory PermissionDto.fromJson(Map<String, dynamic> json) {
    return PermissionDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
