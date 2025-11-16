import 'sale_line.dart';

class SaleRequest {
  final int userId;
  final int customerId;
  final List<SaleLine> lines;
  final String? comment;
  final int? clientTourneeId;
  final double? latitude;
  final double? longitude;

  SaleRequest({
    required this.userId,
    required this.customerId,
    required this.lines,
    this.comment,
    this.clientTourneeId,
    this.latitude,
    this.longitude,
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
    };
  }
}
