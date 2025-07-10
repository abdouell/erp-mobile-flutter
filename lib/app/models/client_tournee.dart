class ClientTournee {
  final int id;
  final int tourneeId;
  final int customerId;
  final String customerName;
  final String customerRc;
  final String customerAddress;
  final int? ordre;
  final String? commentaire;
  final bool visite;
  
  ClientTournee({
    required this.id,
    required this.tourneeId,
    required this.customerId,
    required this.customerName,
    required this.customerRc,
    required this.customerAddress,
    this.ordre,
    this.commentaire,
    this.visite = false,  // ✅ Par défaut non visité
  });
  
  factory ClientTournee.fromJson(Map<String, dynamic> json) {
    return ClientTournee(
      id: json['id'],
      tourneeId: json['tourneeId'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerRc: json['customerRc'],
      customerAddress: json['customerAddress'],
      ordre: json['ordre'],
      commentaire: json['commentaire'],
      visite: json['visite'] ?? false,  // ✅ Gestion null
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tourneeId': tourneeId,
      'customerId': customerId,
      'customerName': customerName,
      'customerRc': customerRc,
      'customerAddress': customerAddress,
      'ordre': ordre,
      'commentaire': commentaire,
      'visite': visite,
    };
  }
  
  // ✅ Helpers pour l'UI
  bool get estVisite => visite;
  bool get estNonVisite => !visite;
}