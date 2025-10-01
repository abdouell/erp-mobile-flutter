import 'statut_visite.dart';

class ClientTournee {
  final int? id;
  final int customerId;
  final String customerName;
  final String customerAddress;
  final String customerRc;
  final int? ordre;
  final StatutVisite statutVisite;
  final String? commentaire;

  // Données de check-in
  final DateTime? checkinAt;
  final double? checkinLat;
  final double? checkinLon;

  // Données de check-out
  final DateTime? checkoutAt;
  final double? checkoutLat;
  final double? checkoutLon;

  // Motif et note pour visite terminée sans commande
  final String? motifVisite;
  final String? noteVisite;

  const ClientTournee({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.customerRc,
    this.ordre,
    this.statutVisite = StatutVisite.NON_VISITE,
    this.commentaire,
    this.checkinAt,
    this.checkinLat,
    this.checkinLon,
    this.checkoutAt,
    this.checkoutLat,
    this.checkoutLon,
    this.motifVisite,
    this.noteVisite,
  });

  // Factory depuis JSON
  factory ClientTournee.fromJson(Map<String, dynamic> json) {
    return ClientTournee(
      id: json['id'],
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerRc: json['customerRc'] ?? '',
      ordre: json['ordre'],
      statutVisite: json['statutVisite'] != null 
          ? StatutVisite.fromString(json['statutVisite'])
          : StatutVisite.NON_VISITE,
      commentaire: json['commentaire'],
      checkinAt: json['checkinAt'] != null 
          ? DateTime.parse(json['checkinAt'])
          : null,
      checkinLat: json['checkinLat']?.toDouble(),
      checkinLon: json['checkinLon']?.toDouble(),
      checkoutAt: json['checkoutAt'] != null 
          ? DateTime.parse(json['checkoutAt'])
          : null,
      checkoutLat: json['checkoutLat']?.toDouble(),
      checkoutLon: json['checkoutLon']?.toDouble(),
      motifVisite: json['motifVisite'],
      noteVisite: json['noteVisite'],
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerRc': customerRc,
      'ordre': ordre,
      'statutVisite': statutVisite.serverValue,
      'commentaire': commentaire,
      'checkinAt': checkinAt?.toIso8601String(),
      'checkinLat': checkinLat,
      'checkinLon': checkinLon,
      'checkoutAt': checkoutAt?.toIso8601String(),
      'checkoutLat': checkoutLat,
      'checkoutLon': checkoutLon,
      'motifVisite': motifVisite,
      'noteVisite': noteVisite,
    };
  }

  // Méthodes utilitaires
  bool get isVisited => statutVisite.isVisited;
  bool get isInProgress => statutVisite.isInProgress;
  bool get isCompleted => statutVisite.isCompleted;

  // Durée de visite en minutes
  int? get visitDurationMinutes {
    if (checkinAt != null && checkoutAt != null) {
      return checkoutAt!.difference(checkinAt!).inMinutes;
    }
    return null;
  }

  // Formatage de la durée
  String get formattedDuration {
    final duration = visitDurationMinutes;
    if (duration == null) return '';
    
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  // Méthode copyWith pour mise à jour immutable
  ClientTournee copyWith({
    int? id,
    int? customerId,
    String? customerName,
    String? customerAddress,
    String? customerRc,
    int? ordre,
    StatutVisite? statutVisite,
    String? commentaire,
    DateTime? checkinAt,
    double? checkinLat,
    double? checkinLon,
    DateTime? checkoutAt,
    double? checkoutLat,
    double? checkoutLon,
    String? motifVisite,
    String? noteVisite,
  }) {
    return ClientTournee(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerRc: customerRc ?? this.customerRc,
      ordre: ordre ?? this.ordre,
      statutVisite: statutVisite ?? this.statutVisite,
      commentaire: commentaire ?? this.commentaire,
      checkinAt: checkinAt ?? this.checkinAt,
      checkinLat: checkinLat ?? this.checkinLat,
      checkinLon: checkinLon ?? this.checkinLon,
      checkoutAt: checkoutAt ?? this.checkoutAt,
      checkoutLat: checkoutLat ?? this.checkoutLat,
      checkoutLon: checkoutLon ?? this.checkoutLon,
      motifVisite: motifVisite ?? this.motifVisite,
      noteVisite: noteVisite ?? this.noteVisite,
    );
  }

  @override
  String toString() {
    return 'ClientTournee(id: $id, customerName: $customerName, statutVisite: $statutVisite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientTournee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}