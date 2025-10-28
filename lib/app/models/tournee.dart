import 'package:erp_mobile/app/models/client_tournee.dart';

class Tournee {
  final int id;
  final String nom;
  final String code;
  final DateTime date;
  final String statut;
  final int vendeurId;
  final List<ClientTournee> clients;
  
  Tournee({
    required this.id,
    required this.nom,
    required this.code,
    required this.date,
    required this.statut,
    required this.vendeurId,
    this.clients = const [],
  });
  
  // ========================================
  // FACTORY DEPUIS JSON
  // ========================================
  
  factory Tournee.fromJson(Map<String, dynamic> json) {
    return Tournee(
      id: json['id'],
      nom: json['nom'],
      code: json['code'],
      date: DateTime.parse(json['date']),
      statut: json['statut'],
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
      'statut': statut,
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
  
  bool get estPlanifiee => statut == PLANIFIEE;
  bool get estEnCours => statut == EN_COURS;
  bool get estTerminee => statut == TERMINEE;
  
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
    String? statut,
    int? vendeurId,
    List<ClientTournee>? clients,
  }) {
    return Tournee(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      code: code ?? this.code,
      date: date ?? this.date,
      statut: statut ?? this.statut,
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