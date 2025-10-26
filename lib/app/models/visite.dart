import 'statut_visite.dart';

class Visite {
  final int? id;
  final int clientTourneeId;
  final StatutVisite statutVisite;
  
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

  const Visite({
    this.id,
    required this.clientTourneeId,
    this.statutVisite = StatutVisite.NON_VISITE,
    this.checkinAt,
    this.checkinLat,
    this.checkinLon,
    this.checkoutAt,
    this.checkoutLat,
    this.checkoutLon,
    this.motifVisite,
    this.noteVisite,
  });

  // Factory depuis JSON (backend → Flutter)
  factory Visite.fromJson(Map<String, dynamic> json) {
    return Visite(
      id: json['id'],
      clientTourneeId: json['clientTourneeId'] ?? 0,
      statutVisite: json['statutVisite'] != null 
          ? StatutVisite.fromString(json['statutVisite'])
          : StatutVisite.NON_VISITE,
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

  // Conversion vers JSON (Flutter → backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientTourneeId': clientTourneeId,
      'statutVisite': statutVisite.serverValue,
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

  // ========================================
  // MÉTHODES UTILITAIRES
  // ========================================

  /// La visite a-t-elle été démarrée ?
  bool get isVisited => statutVisite.isVisited;
  
  /// La visite est-elle en cours ?
  bool get isInProgress => statutVisite.isInProgress;
  
  /// La visite est-elle terminée ?
  bool get isCompleted => statutVisite.isCompleted;

  /// Durée de visite en minutes
  int? get visitDurationMinutes {
    if (checkinAt != null && checkoutAt != null) {
      return checkoutAt!.difference(checkinAt!).inMinutes;
    }
    return null;
  }

  /// Formatage de la durée pour l'affichage
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

  /// Temps écoulé depuis le check-in (pour visite en cours)
  Duration? get elapsedSinceCheckin {
    if (checkinAt == null) return null;
    return DateTime.now().difference(checkinAt!);
  }

  /// Formatage du temps écoulé
  String get formattedElapsedTime {
    final elapsed = elapsedSinceCheckin;
    if (elapsed == null) return '';
    
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  /// A-t-on des coordonnées GPS pour le check-in ?
  bool get hasCheckinLocation => checkinLat != null && checkinLon != null;
  
  /// A-t-on des coordonnées GPS pour le check-out ?
  bool get hasCheckoutLocation => checkoutLat != null && checkoutLon != null;

  /// La visite s'est-elle terminée avec une commande ?
  bool get hasOrder => statutVisite == StatutVisite.COMMANDE_CREEE;

  /// La visite s'est-elle terminée sans commande ?
  bool get hasNoSale => statutVisite == StatutVisite.VISITE_TERMINEE;

  /// Y a-t-il un motif de visite ?
  bool get hasMotif => motifVisite != null && motifVisite!.isNotEmpty;

  /// Y a-t-il une note ?
  bool get hasNote => noteVisite != null && noteVisite!.isNotEmpty;

  // ========================================
  // COPYWIDTH POUR IMMUTABILITÉ
  // ========================================

  Visite copyWith({
    int? id,
    int? clientTourneeId,
    StatutVisite? statutVisite,
    DateTime? checkinAt,
    double? checkinLat,
    double? checkinLon,
    DateTime? checkoutAt,
    double? checkoutLat,
    double? checkoutLon,
    String? motifVisite,
    String? noteVisite,
  }) {
    return Visite(
      id: id ?? this.id,
      clientTourneeId: clientTourneeId ?? this.clientTourneeId,
      statutVisite: statutVisite ?? this.statutVisite,
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

  // ========================================
  // MÉTHODES STANDARD
  // ========================================

  @override
  String toString() {
    return 'Visite(id: $id, clientTourneeId: $clientTourneeId, statutVisite: $statutVisite, '
           'checkinAt: $checkinAt, checkoutAt: $checkoutAt, duration: $formattedDuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Visite && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}