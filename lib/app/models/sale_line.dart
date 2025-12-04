class SaleLine {
  final int productId;
  final int quantity;
  final String? designation;
  
  // Champs spécifiques aux retours
  final int? originalLineId;
  final String? returnReason;
  final String? returnCondition; // CONFORME ou NON_CONFORME

  SaleLine({
    required this.productId,
    required this.quantity,
    this.designation,
    this.originalLineId,
    this.returnReason,
    this.returnCondition,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'designation': designation,
      if (originalLineId != null) 'originalLineId': originalLineId,
      if (returnReason != null) 'returnReason': returnReason,
      if (returnCondition != null) 'returnCondition': returnCondition,
    };
  }

  factory SaleLine.fromJson(Map<String, dynamic> json) {
    return SaleLine(
      productId: json['productId'],
      quantity: json['quantity'],
      designation: json['designation'],
      originalLineId: json['originalLineId'],
      returnReason: json['returnReason'],
      returnCondition: json['returnCondition'],
    );
  }
}
