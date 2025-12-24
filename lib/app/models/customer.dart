class Customer {
  // Identifiants principaux
  final int id;
  final String customerCode;
  final String? name;
  
  // Informations d'adresse
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  
  // Informations de contact
  final String? phone1;
  final String? email;
  
  // Informations commerciales
  final String? priceListCode;
  final bool? hold;
  
  // Géolocalisation
  final double? longitude;
  final double? latitude;
  
  // Champs d'audit
  final String? createdBy;
  final DateTime? creationDate;
  final String? modifiedBy;
  final DateTime? modificationDate;
  final bool deleted;
  final DateTime? deletionTimestamp;

  Customer({
    required this.id,
    required this.customerCode,
    this.name,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.phone1,
    this.email,
    this.priceListCode,
    this.hold,
    this.longitude,
    this.latitude,
    this.createdBy,
    this.creationDate,
    this.modifiedBy,
    this.modificationDate,
    this.deleted = false,
    this.deletionTimestamp,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerCode: json['customerCode'] ?? '',
      name: json['name'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      postalCode: json['postalCode'],
      phone1: json['phone1'],
      email: json['email'],
      priceListCode: json['priceListCode'],
      hold: json['hold'],
      longitude: json['longitude']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      createdBy: json['createdBy'],
      creationDate: json['creationDate'] != null 
          ? DateTime.tryParse(json['creationDate']) 
          : null,
      modifiedBy: json['modifiedBy'],
      modificationDate: json['modificationDate'] != null 
          ? DateTime.tryParse(json['modificationDate']) 
          : null,
      deleted: json['deleted'] ?? false,
      deletionTimestamp: json['deletionTimestamp'] != null 
          ? DateTime.tryParse(json['deletionTimestamp']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerCode': customerCode,
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'phone1': phone1,
      'email': email,
      'priceListCode': priceListCode,
      'hold': hold,
      'longitude': longitude,
      'latitude': latitude,
      'createdBy': createdBy,
      'creationDate': creationDate?.toIso8601String(),
      'modifiedBy': modifiedBy,
      'modificationDate': modificationDate?.toIso8601String(),
      'deleted': deleted,
      'deletionTimestamp': deletionTimestamp?.toIso8601String(),
    };
  }

  /// HELPERS POUR L'AFFICHAGE
  
  /// Nom d'affichage principal
  String get displayName => name ?? customerCode;
  
  /// Adresse complète formatée
  String get fullAddress {
    final addressParts = <String>[];
    
    if (address?.isNotEmpty == true) addressParts.add(address!);
    if (postalCode?.isNotEmpty == true && city?.isNotEmpty == true) {
      addressParts.add('$postalCode $city');
    } else if (city?.isNotEmpty == true) {
      addressParts.add(city!);
    }
    if (country?.isNotEmpty == true) addressParts.add(country!);
    
    return addressParts.join(', ');
  }
  
  /// Téléphone principal
  String? get primaryPhone => phone1;
  
  /// Vérifie si le client a des coordonnées GPS
  bool get hasCoordinates => longitude != null && latitude != null;
  
  /// Vérifie si le client est en hold
  bool get isOnHold => hold == true;
  
  /// Vérifie si le client est actif
  bool get isActive => !deleted && !isOnHold;
  
  /// Statut d'affichage
  String get statusDisplay {
    if (deleted) return 'Supprimé';
    if (isOnHold) return 'Bloqué';
    return 'Actif';
  }
  
  /// Couleur du statut pour l'UI
  String get statusColor {
    if (deleted) return 'red';
    if (isOnHold) return 'orange';
    return 'green';
  }
  
  /// ✏️ copyWith pour modifications immutables
  Customer copyWith({
    int? id,
    String? customerCode,
    String? name,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    String? phone1,
    String? email,
    String? priceListCode,
    bool? hold,
    double? longitude,
    double? latitude,
    String? createdBy,
    DateTime? creationDate,
    String? modifiedBy,
    DateTime? modificationDate,
    bool? deleted,
    DateTime? deletionTimestamp,
  }) {
    return Customer(
      id: id ?? this.id,
      customerCode: customerCode ?? this.customerCode,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      phone1: phone1 ?? this.phone1,
      email: email ?? this.email,
      priceListCode: priceListCode ?? this.priceListCode,
      hold: hold ?? this.hold,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      createdBy: createdBy ?? this.createdBy,
      creationDate: creationDate ?? this.creationDate,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modificationDate: modificationDate ?? this.modificationDate,
      deleted: deleted ?? this.deleted,
      deletionTimestamp: deletionTimestamp ?? this.deletionTimestamp,
    );
  }

  @override
  String toString() {
    return 'Customer{id: $id, code: $customerCode, name: $displayName, city: $city, active: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}