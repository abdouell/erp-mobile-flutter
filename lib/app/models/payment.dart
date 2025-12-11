class Payment {
  final int id;
  final double amount;
  final DateTime paymentDate;
  final String method;
  final String? note;
  final int salesDocumentId;
  final int clientId;
  final int userId;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.method,
    this.note,
    required this.salesDocumentId,
    required this.clientId,
    required this.userId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
      method: json['method'],
      note: json['note'],
      salesDocumentId: json['salesDocument']?['id'] ?? json['salesDocumentId'],
      clientId: json['client']?['id'] ?? json['clientId'],
      userId: json['user']?['id'] ?? json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'method': method,
      'note': note,
      'salesDocumentId': salesDocumentId,
      'clientId': clientId,
      'userId': userId,
    };
  }
}
