class SaleLine {
  final int productId;
  final int quantity;
  final String? designation;

  SaleLine({
    required this.productId,
    required this.quantity,
    this.designation,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'designation': designation,
    };
  }

  factory SaleLine.fromJson(Map<String, dynamic> json) {
    return SaleLine(
      productId: json['productId'],
      quantity: json['quantity'],
      designation: json['designation'],
    );
  }
}
