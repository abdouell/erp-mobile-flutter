
class Customer {
  final int id;
  final String customerCode;
  final String? name;
  final String? rc;
  
  Customer({
    required this.id,
    required this.customerCode,
    this.name,
    this.rc,
  });
  
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerCode: json['customerCode'],
      name: json['name'],
      rc: json['rc'],
    );
  }
  
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerCode': customerCode,
      'name': name,
      'rc': rc,
    };
  }
  
}