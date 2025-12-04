import 'sale_line.dart';

class SaleRequest {
  final int userId;
  final int customerId;
  final List<SaleLine> lines;
  final String? comment;
  final int? clientTourneeId;
  final double? latitude;
  final double? longitude;
  final String saleType; // ORDER, BL ou RETURN

  // Champs spécifiques aux retours
  final int? originalDocumentId;
  final String? originalDocumentType; // BL ou INVOICE
  final String? returnReason;
  final String? returnCondition; // CONFORME ou NON_CONFORME

  SaleRequest({
    required this.userId,
    required this.customerId,
    required this.lines,
    required this.saleType,
    this.comment,
    this.clientTourneeId,
    this.latitude,
    this.longitude,
    this.originalDocumentId,
    this.originalDocumentType,
    this.returnReason,
    this.returnCondition,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'customerId': customerId,
      'lines': lines.map((l) => l.toJson()).toList(),
      'comment': comment,
      'clientTourneeId': clientTourneeId,
      'latitude': latitude,
      'longitude': longitude,
      'saleType': saleType,
      if (originalDocumentId != null) 'originalDocumentId': originalDocumentId,
      if (originalDocumentType != null) 'originalDocumentType': originalDocumentType,
      if (returnReason != null) 'returnReason': returnReason,
      if (returnCondition != null) 'returnCondition': returnCondition,
    };
  }
}
