class Vendeur {
  final int id;
  final String code;
  final String nom;
  final String prenom;
  final String? email;
  final String? telephone;
  final int userId;
  
  Vendeur({
    required this.id,
    required this.code,
    required this.nom,
    required this.prenom,
    this.email,
    this.telephone,
    required this.userId,
  });
  
  // Convertir JSON backend → Vendeur Flutter
  factory Vendeur.fromJson(Map<String, dynamic> json) {
    return Vendeur(
      id: json['id'],
      code: json['code'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      userId: json['userId'],
    );
  }
  
  // Nom complet pour affichage
  String get nomComplet => '$prenom $nom';
  
  // Initiales pour avatar
  String get initiales {
    final p = prenom.isNotEmpty ? prenom[0] : '';
    final n = nom.isNotEmpty ? nom[0] : '';
    return '$p$n'.toUpperCase();
  }
}