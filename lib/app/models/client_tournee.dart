class ClientTournee {
  final int? id;
  final int customerId;
  final String customerName;
  final String customerAddress;
  final String customerRc;
  final int ordre;
  final String? commentaire;
  final bool visite; // ✅ Champ pour le statut de visite

  ClientTournee({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.customerRc,
    required this.ordre,
    this.commentaire,
    required this.visite,
  });

  factory ClientTournee.fromJson(Map<String, dynamic> json) {
    return ClientTournee(
      id: json['id'],
      customerId: int.parse(json['customerId'].toString()),
      customerName: json['customerName'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerRc: json['customerRc'] ?? '',
      ordre: json['ordre'] ?? 0,
      commentaire: json['commentaire'],
      visite: json['visite'] ?? false, // ✅ Par défaut false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId.toString(),
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerRc': customerRc,
      'ordre': ordre,
      'commentaire': commentaire,
      'visite': visite,
    };
  }

  /// ✅ Méthode copyWith nécessaire pour la mise à jour d'état
  ClientTournee copyWith({
    int? id,
    int? customerId,
    String? customerName,
    String? customerAddress,
    String? customerRc,
    int? ordre,
    String? commentaire,
    bool? visite,
  }) {
    return ClientTournee(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerRc: customerRc ?? this.customerRc,
      ordre: ordre ?? this.ordre,
      commentaire: commentaire ?? this.commentaire,
      visite: visite ?? this.visite, // ✅ Important pour _markClientAsVisited
    );
  }

  @override
  String toString() {
    return 'ClientTournee{id: $id, customerName: $customerName, visite: $visite}';
  }
}