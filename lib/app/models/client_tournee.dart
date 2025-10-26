import 'statut_visite.dart';
import 'visite.dart';

class ClientTournee {
  final int? id;
  final int customerId;
  final String customerName;
  final String customerAddress;
  final String customerRc;
  final int? ordre;
  final String? commentaire;

  // ✅ NOUVEAU : Liste des visites pour ce client
  final List<Visite> visites;

  const ClientTournee({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.customerRc,
    this.ordre,
    this.commentaire,
    this.visites = const [],
  });

  // ========================================
  // FACTORY DEPUIS JSON
  // ========================================

  factory ClientTournee.fromJson(Map<String, dynamic> json) {
    // Parser la liste de visites si elle existe
    final List<Visite> parsedVisites = [];
    if (json['visites'] != null && json['visites'] is List) {
      parsedVisites.addAll(
        (json['visites'] as List)
            .map((visiteJson) => Visite.fromJson(visiteJson))
            .toList()
      );
    }

    return ClientTournee(
      id: json['id'],
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerRc: json['customerRc'] ?? '',
      ordre: json['ordre'],
      commentaire: json['commentaire'],
      visites: parsedVisites,
    );
  }

  // ========================================
  // CONVERSION VERS JSON
  // ========================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerRc': customerRc,
      'ordre': ordre,
      'commentaire': commentaire,
      'visites': visites.map((v) => v.toJson()).toList(),
    };
  }

  // ========================================
  // GETTERS POUR LA VISITE COURANTE
  // ========================================

  /// Obtenir la visite courante (la dernière de la liste)
  Visite? get currentVisite {
    if (visites.isEmpty) return null;
    return visites.last;
  }

  /// Obtenir le statut de la visite courante
  /// Si aucune visite, retourne NON_VISITE
  StatutVisite get statutVisite {
    return currentVisite?.statutVisite ?? StatutVisite.NON_VISITE;
  }

  /// Date/heure de check-in de la visite courante
  DateTime? get checkinAt => currentVisite?.checkinAt;
  
  /// Coordonnées GPS du check-in
  double? get checkinLat => currentVisite?.checkinLat;
  double? get checkinLon => currentVisite?.checkinLon;

  /// Date/heure de check-out de la visite courante
  DateTime? get checkoutAt => currentVisite?.checkoutAt;
  
  /// Coordonnées GPS du check-out
  double? get checkoutLat => currentVisite?.checkoutLat;
  double? get checkoutLon => currentVisite?.checkoutLon;

  /// Motif de visite (pour visite sans vente)
  String? get motifVisite => currentVisite?.motifVisite;
  
  /// Note de visite
  String? get noteVisite => currentVisite?.noteVisite;

  // ========================================
  // MÉTHODES UTILITAIRES - VISITE COURANTE
  // ========================================

  /// La visite courante a-t-elle été démarrée ?
  bool get isVisited => currentVisite?.isVisited ?? false;
  
  /// La visite courante est-elle en cours ?
  bool get isInProgress => currentVisite?.isInProgress ?? false;
  
  /// La visite courante est-elle terminée ?
  bool get isCompleted => currentVisite?.isCompleted ?? false;

  /// Durée de la visite courante en minutes
  int? get visitDurationMinutes => currentVisite?.visitDurationMinutes;

  /// Formatage de la durée de la visite courante
  String get formattedDuration => currentVisite?.formattedDuration ?? '';

  // ========================================
  // MÉTHODES UTILITAIRES - HISTORIQUE
  // ========================================

  /// Y a-t-il au moins une visite ?
  bool get hasVisits => visites.isNotEmpty;

  /// Nombre total de visites
  int get visitCount => visites.length;

  /// Y a-t-il une visite en cours ?
  bool get hasVisitInProgress {
    return visites.any((v) => v.isInProgress);
  }

  /// Nombre de visites terminées
  int get completedVisitsCount {
    return visites.where((v) => v.isCompleted).length;
  }

  /// Liste des visites terminées
  List<Visite> get completedVisites {
    return visites.where((v) => v.isCompleted).toList();
  }

  /// Liste des visites avec commande
  List<Visite> get visitesAvecCommande {
    return visites.where((v) => v.hasOrder).toList();
  }

  /// Liste des visites sans vente
  List<Visite> get visitesSansVente {
    return visites.where((v) => v.hasNoSale).toList();
  }

  /// Y a-t-il au moins une commande créée ?
  bool get hasOrderCreated {
    return visites.any((v) => v.hasOrder);
  }

  /// Nombre total de commandes créées pour ce client
  int get orderCount {
    return visitesAvecCommande.length;
  }

  /// Durée totale de toutes les visites (en minutes)
  int get totalVisitDuration {
    return visites.fold(0, (sum, v) => sum + (v.visitDurationMinutes ?? 0));
  }

  /// Durée moyenne des visites (en minutes)
  double get averageVisitDuration {
    if (completedVisitsCount == 0) return 0.0;
    return totalVisitDuration / completedVisitsCount;
  }

  // ========================================
  // MÉTHODE COPYWIDTH
  // ========================================

  ClientTournee copyWith({
    int? id,
    int? customerId,
    String? customerName,
    String? customerAddress,
    String? customerRc,
    int? ordre,
    String? commentaire,
    List<Visite>? visites,
  }) {
    return ClientTournee(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerRc: customerRc ?? this.customerRc,
      ordre: ordre ?? this.ordre,
      commentaire: commentaire ?? this.commentaire,
      visites: visites ?? this.visites,
    );
  }

  // ========================================
  // MÉTHODES STANDARD
  // ========================================

  @override
  String toString() {
    return 'ClientTournee(id: $id, customerName: $customerName, '
           'visites: ${visites.length}, statutVisite: $statutVisite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientTournee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}