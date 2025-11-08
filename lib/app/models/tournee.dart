import 'package:erp_mobile/app/models/client_tournee.dart';

class Tournee {
  final int id;
  final String nom;
  final String code;
  final DateTime date;
  final DateTime? affectationDate;
  final String? affectationStatut;
  final int vendeurId;
  final List<ClientTournee> clients;
  
  Tournee({
    required this.id,
    required this.nom,
    required this.code,
    required this.date,
    this.affectationDate,
    this.affectationStatut,
    required this.vendeurId,
    this.clients = const [],
  });
  
  // ========================================
  // FACTORY DEPUIS JSON
  // ========================================
  
  factory Tournee.fromJson(Map<String, dynamic> json) {
    final String? affectationDateStr = json['affectationDate'] as String?;
    final String? dateStr = json['date'] as String?;
    final DateTime? parsedAffectation = (affectationDateStr != null && affectationDateStr.isNotEmpty)
        ? DateTime.parse(affectationDateStr)
        : null;
    final DateTime parsedDate = parsedAffectation
        ?? ((dateStr != null && dateStr.isNotEmpty) ? DateTime.parse(dateStr) : DateTime.now());

    return Tournee(
      id: json['id'],
      nom: json['nom'],
      code: json['code'],
      date: parsedDate,
      affectationDate: parsedAffectation,
      affectationStatut: json['affectationStatut'] as String?,
      vendeurId: json['vendeurId'],
      clients: json['clients'] != null
          ? (json['clients'] as List)
              .map((clientJson) => ClientTournee.fromJson(clientJson))
              .toList()
          : [],
    );
  }
  
  // ========================================
  // CONVERSION VERS JSON
  // ========================================
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'code': code,
      'date': date.toIso8601String(),
      if (affectationDate != null) 'affectationDate': affectationDate!.toIso8601String(),
      if (affectationStatut != null) 'affectationStatut': affectationStatut,
      'vendeurId': vendeurId,
      'clients': clients.map((c) => c.toJson()).toList(),
    };
  }
  
  // ========================================
  // CONSTANTES DE STATUT
  // ========================================
  
  static const String PLANIFIEE = 'PLANIFIEE';
  static const String EN_COURS = 'EN_COURS';
  static const String TERMINEE = 'TERMINEE';
  
  // ========================================
  // HELPERS DE STATUT
  // ========================================
  
  String get _statutCourant => affectationStatut ?? PLANIFIEE;
  bool get estPlanifiee => _statutCourant == PLANIFIEE;
  bool get estEnCours => _statutCourant == EN_COURS;
  bool get estTerminee => _statutCourant == TERMINEE;
  
  // ========================================
  // STATISTIQUES - CLIENTS
  // ========================================
  
  /// Nombre total de clients dans la tournée
  int get nombreClients => clients.length;
  
  /// Nombre de clients ayant au moins une visite démarrée
  int get clientsVisites => clients.where((c) => c.isVisited).length;
  
  /// Nombre de clients non encore visités (statut NON_VISITE)
  int get clientsNonVisites => clients.where((c) => !c.isVisited).length;
  
  /// Nombre de clients avec visite en cours
  int get clientsEnCours => clients.where((c) => c.isInProgress).length;
  
  /// Nombre de clients avec visite terminée
  int get clientsTermines => clients.where((c) => c.isCompleted).length;
  
  /// Nombre de clients ayant généré au moins une commande
  int get clientsAvecCommande => clients.where((c) => c.hasOrderCreated).length;
  
  // ========================================
  // STATISTIQUES - VISITES
  // ========================================
  
  /// Nombre total de visites dans la tournée (toutes visites confondues)
  int get nombreTotalVisites {
    return clients.fold(0, (sum, c) => sum + c.visites.length);
  }
  
  /// Nombre total de commandes créées dans la tournée
  int get nombreCommandes {
    return clients.fold(0, (sum, client) => sum + client.orderCount);
  }
  
  /// Nombre de visites sans vente
  int get nombreVisitesSansVente {
    return clients.fold(0, (sum, client) => sum + client.visitesSansVente.length);
  }
  
  /// Liste de tous les clients avec visite en cours
  List<ClientTournee> get clientsAvecVisiteEnCours {
    return clients.where((c) => c.hasVisitInProgress).toList();
  }
  
  // ========================================
  // PROGRESSION ET POURCENTAGES
  // ========================================
  
  /// Progression en pourcentage (basée sur les clients visités)
  double get progressionPourcentage {
    if (nombreClients == 0) return 0.0;
    return (clientsVisites / nombreClients) * 100;
  }
  
  /// Taux de conversion (clients avec commande / clients visités)
  double get tauxConversion {
    if (clientsVisites == 0) return 0.0;
    return (clientsAvecCommande / clientsVisites) * 100;
  }
  
  /// Taux de complétion (clients terminés / clients totaux)
  double get tauxCompletion {
    if (nombreClients == 0) return 0.0;
    return (clientsTermines / nombreClients) * 100;
  }
  
  // ========================================
  // VALIDATIONS
  // ========================================
  
  /// La tournée peut-elle être clôturée ?
  /// (aucun client en cours de visite)
  bool get peutEtreCloturee {
    return clientsEnCours == 0;
  }
  
  /// Y a-t-il des clients en cours de visite ?
  bool get aDesClientsEnCours {
    return clientsEnCours > 0;
  }
  
  /// Tous les clients ont-ils été visités ?
  bool get tousClientsVisites {
    return clientsNonVisites == 0;
  }
  
  // ========================================
  // HELPERS UTILES
  // ========================================
  
  /// Obtenir un résumé textuel de la progression
  String get progressionText {
    return '$clientsVisites/$nombreClients clients visités';
  }
  
  /// Obtenir un résumé des commandes
  String get commandesText {
    return '$nombreCommandes commande${nombreCommandes > 1 ? 's' : ''}';
  }
  
  // ========================================
  // COPYWIDTH
  // ========================================
  
  Tournee copyWith({
    int? id,
    String? nom,
    String? code,
    DateTime? date,
    DateTime? affectationDate,
    String? affectationStatut,
    int? vendeurId,
    List<ClientTournee>? clients,
  }) {
    return Tournee(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      code: code ?? this.code,
      date: date ?? this.date,
      affectationDate: affectationDate ?? this.affectationDate,
      affectationStatut: affectationStatut ?? this.affectationStatut,
      vendeurId: vendeurId ?? this.vendeurId,
      clients: clients ?? this.clients,
    );
  }
  
  // ========================================
  // MÉTHODES STANDARD
  // ========================================
  
  //@override
  //String toString() {
    //return 'Tournee(id: $id, nom: $nom, date: $date, statut: $statut, '
      //     'clients: $nombreClients, visites: $nombreTotalVisites, '
        //   'commandes: $nombreCommandes)';
  //}
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tournee && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}