
import 'package:erp_mobile/app/models/client_tournee.dart';

class Tournee {
  final int id;
  final DateTime date;
  final String statut;
  final int vendeurId;
  final List<ClientTournee> clients;  // ✅ Ajout liste clients
  
  Tournee({
    required this.id,
    required this.date,
    required this.statut,
    required this.vendeurId,
    this.clients = const [],  // ✅ Liste par défaut
  });
  
  // Convertir JSON backend → Tournee Flutter
  factory Tournee.fromJson(Map<String, dynamic> json) {
    return Tournee(
      id: json['id'],
      date: DateTime.parse(json['date']),
      statut: json['statut'],
      vendeurId: json['vendeurId'],
      // ✅ Parser la liste clients depuis le JSON
      clients: json['clients'] != null
          ? (json['clients'] as List)
              .map((clientJson) => ClientTournee.fromJson(clientJson))
              .toList()
          : [],
    );
  }
  
  // Statuts possibles
  static const String PLANIFIEE = 'PLANIFIEE';
  static const String EN_COURS = 'EN_COURS';
  static const String TERMINEE = 'TERMINEE';
  
  // Helper methods
  bool get estPlanifiee => statut == PLANIFIEE;
  bool get estEnCours => statut == EN_COURS;
  bool get estTerminee => statut == TERMINEE;
  
  // ✅ Nouveaux helpers pour les clients
  int get nombreClients => clients.length;
  int get clientsVisites => clients.where((c) => c.visite).length;
  int get clientsNonVisites => clients.where((c) => !c.visite).length;
  
  // Progression en pourcentage
  double get progressionPourcentage {
    if (nombreClients == 0) return 0.0;
    return (clientsVisites / nombreClients) * 100;
  }
}