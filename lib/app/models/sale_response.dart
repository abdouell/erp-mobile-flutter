class SaleResponse {
  final int documentId;
  final String documentType;
  final String? documentNumber;
  final String status;
  final double totalAmount;
  final int customerId;
  final int userId;
  final DateTime createdDate;
  final String? comment;

  SaleResponse({
    required this.documentId,
    required this.documentType,
    this.documentNumber,
    required this.status,
    required this.totalAmount,
    required this.customerId,
    required this.userId,
    required this.createdDate,
    this.comment,
  });

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    return SaleResponse(
      documentId: json['documentId'],
      documentType: json['documentType'],
      documentNumber: json['documentNumber'],
      status: json['status'],
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      customerId: json['customerId'],
      userId: json['userId'],
      createdDate: DateTime.parse(json['createdDate']),
      comment: json['comment'],
    );
  }
}
