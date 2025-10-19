class Vendeur {
  final int id;
  final String code;
  final String nom;
  final String prenom;
  final String? email;
  final String? telephone;
  final int userId;
  final String? typeVendeur;      // ✅ NOUVEAU
  final String? emplacementCode;  // ✅ NOUVEAU
  
  Vendeur({
    required this.id,
    required this.code,
    required this.nom,
    required this.prenom,
    this.email,
    this.telephone,
    required this.userId,
    this.typeVendeur,           // ✅ NOUVEAU
    this.emplacementCode,       // ✅ NOUVEAU
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
      typeVendeur: json['typeVendeur'],           // ✅ NOUVEAU
      emplacementCode: json['emplacementCode'],   // ✅ NOUVEAU
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
  
  // ✅ NOUVEAU : Vérifier si c'est un vendeur conventionnel
  bool get isConventionnel => typeVendeur == 'CONVENTIONNEL';
  
  // ✅ NOUVEAU : Vérifier si c'est un vendeur prévente
  bool get isPrevente => typeVendeur == 'PREVENTE';
  
  // ✅ NOUVEAU : Vérifier si c'est un livreur
  bool get isLivreur => typeVendeur == 'LIVREUR';
  
  // ✅ NOUVEAU : Vérifier si le vendeur a un emplacement
  bool get hasEmplacement => emplacementCode != null && emplacementCode!.isNotEmpty;
}