import 'package:erp_mobile/app/models/statut_visite.dart';

class VisitStatusResponse {
  final int clientTourneeId;
  final StatutVisite statutVisite;
  final String statutLabel;
  final DateTime? checkinAt;
  final DateTime? checkoutAt;
  final int? visitDurationMinutes;
  final double? checkinLat;
  final double? checkinLon;
  final double? checkoutLat;
  final double? checkoutLon;
  final String? motifVisite;
  final String? noteVisite;

  const VisitStatusResponse({
    required this.clientTourneeId,
    required this.statutVisite,
    required this.statutLabel,
    this.checkinAt,
    this.checkoutAt,
    this.visitDurationMinutes,
    this.checkinLat,
    this.checkinLon,
    this.checkoutLat,
    this.checkoutLon,
    this.motifVisite,
    this.noteVisite,
  });

  factory VisitStatusResponse.fromJson(Map<String, dynamic> json) {
    return VisitStatusResponse(
      clientTourneeId: json['clientTourneeId'],
      statutVisite: StatutVisite.fromString(json['statutVisite']),
      statutLabel: json['statutLabel'] ?? '',
      checkinAt: json['checkinAt'] != null 
          ? DateTime.parse(json['checkinAt'])
          : null,
      checkoutAt: json['checkoutAt'] != null 
          ? DateTime.parse(json['checkoutAt'])
          : null,
      visitDurationMinutes: json['visitDurationMinutes'],
      checkinLat: json['checkinLat']?.toDouble(),
      checkinLon: json['checkinLon']?.toDouble(),
      checkoutLat: json['checkoutLat']?.toDouble(),
      checkoutLon: json['checkoutLon']?.toDouble(),
      motifVisite: json['motifVisite'],
      noteVisite: json['noteVisite'],
    );
  }

  // Durée formatée
  String get formattedDuration {
    if (visitDurationMinutes == null) return '';
    
    final hours = visitDurationMinutes! ~/ 60;
    final minutes = visitDurationMinutes! % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }
}