class Permission {
  final int id;
  final String? name;
  final String? description;
  
  Permission({
    required this.id,
    this.name,
    this.description,
  });
  
  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'],
      name: json['name'],
      description: json['description'],
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