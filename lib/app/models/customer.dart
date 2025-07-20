class Customer {
  // Identifiants principaux
  final int id;
  final String customerCode;
  final String? name;
  final String? name2;
  final String? rc;
  final String? fiscalId;
  
  // Codes de classification
  final String? partnerIdTypeCode;
  final String? partnerCategoryCode;
  final String? salesChannelCode;
  final String? partnerStatusCode;
  final String? geoAreaCode;
  final String? itineraryCode;
  final int? rank;
  final String? partnerClusterCode;
  
  // Informations d'adresse
  final String? address;
  final String? postalCode;
  final String? city;
  final String? country;
  
  // Informations de contact
  final String? phone1;
  final String? phone2;
  final String? fax;
  final String? email;
  final String? webAddress;
  
  // Informations commerciales
  final String? currencyCode;
  final String? paymentTermCode;
  final String? priceListCode;
  final String? vatExo;
  final double? creditLimit;
  final double? creditBalance;
  final bool? hold;
  final String? holdReason;
  final String? branchCode;
  
  // Géolocalisation
  final double? longitude;
  final double? latitude;
  
  // Champs utilisateur
  final String? userField1;
  final String? userField2;
  
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
    this.name2,
    this.rc,
    this.fiscalId,
    this.partnerIdTypeCode,
    this.partnerCategoryCode,
    this.salesChannelCode,
    this.partnerStatusCode,
    this.geoAreaCode,
    this.itineraryCode,
    this.rank,
    this.partnerClusterCode,
    this.address,
    this.postalCode,
    this.city,
    this.country,
    this.phone1,
    this.phone2,
    this.fax,
    this.email,
    this.webAddress,
    this.currencyCode,
    this.paymentTermCode,
    this.priceListCode,
    this.vatExo,
    this.creditLimit,
    this.creditBalance,
    this.hold,
    this.holdReason,
    this.branchCode,
    this.longitude,
    this.latitude,
    this.userField1,
    this.userField2,
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
      name2: json['name2'],
      rc: json['rc'],
      fiscalId: json['fiscalId'],
      partnerIdTypeCode: json['partnerIdTypeCode'],
      partnerCategoryCode: json['partnerCategoryCode'],
      salesChannelCode: json['salesChannelCode'],
      partnerStatusCode: json['partnerStatusCode'],
      geoAreaCode: json['geoAreaCode'],
      itineraryCode: json['itineraryCode'],
      rank: json['rank'],
      partnerClusterCode: json['partnerClusterCode'],
      address: json['address'],
      postalCode: json['postalCode'],
      city: json['city'],
      country: json['country'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      fax: json['fax'],
      email: json['email'],
      webAddress: json['webAddress'],
      currencyCode: json['currencyCode'],
      paymentTermCode: json['paymentTermCode'],
      priceListCode: json['priceListCode'],
      vatExo: json['vatExo'],
      creditLimit: json['creditLimit']?.toDouble(),
      creditBalance: json['creditBalance']?.toDouble(),
      hold: json['hold'],
      holdReason: json['holdReason'],
      branchCode: json['branchCode'],
      longitude: json['longitude']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      userField1: json['userField1'],
      userField2: json['userField2'],
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
      'name2': name2,
      'rc': rc,
      'fiscalId': fiscalId,
      'partnerIdTypeCode': partnerIdTypeCode,
      'partnerCategoryCode': partnerCategoryCode,
      'salesChannelCode': salesChannelCode,
      'partnerStatusCode': partnerStatusCode,
      'geoAreaCode': geoAreaCode,
      'itineraryCode': itineraryCode,
      'rank': rank,
      'partnerClusterCode': partnerClusterCode,
      'address': address,
      'postalCode': postalCode,
      'city': city,
      'country': country,
      'phone1': phone1,
      'phone2': phone2,
      'fax': fax,
      'email': email,
      'webAddress': webAddress,
      'currencyCode': currencyCode,
      'paymentTermCode': paymentTermCode,
      'priceListCode': priceListCode,
      'vatExo': vatExo,
      'creditLimit': creditLimit,
      'creditBalance': creditBalance,
      'hold': hold,
      'holdReason': holdReason,
      'branchCode': branchCode,
      'longitude': longitude,
      'latitude': latitude,
      'userField1': userField1,
      'userField2': userField2,
      'createdBy': createdBy,
      'creationDate': creationDate?.toIso8601String(),
      'modifiedBy': modifiedBy,
      'modificationDate': modificationDate?.toIso8601String(),
      'deleted': deleted,
      'deletionTimestamp': deletionTimestamp?.toIso8601String(),
    };
  }

  /// 📱 HELPERS POUR L'AFFICHAGE
  
  /// Nom d'affichage principal
  String get displayName => name ?? name2 ?? customerCode;
  
  /// Nom complet (name + name2 si disponible)
  String get fullName {
    if (name != null && name2 != null) {
      return '$name $name2';
    }
    return displayName;
  }
  
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
  String? get primaryPhone => phone1?.isNotEmpty == true ? phone1 : phone2;
  
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
  
  /// Limite de crédit formatée
  String get formattedCreditLimit {
    if (creditLimit == null) return 'N/A';
    return '${creditLimit!.toStringAsFixed(2)} ${currencyCode ?? '€'}';
  }
  
  /// Solde de crédit formaté
  String get formattedCreditBalance {
    if (creditBalance == null) return 'N/A';
    return '${creditBalance!.toStringAsFixed(2)} ${currencyCode ?? '€'}';
  }
  
  /// ✏️ copyWith pour modifications immutables
  Customer copyWith({
    int? id,
    String? customerCode,
    String? name,
    String? name2,
    String? rc,
    String? fiscalId,
    String? partnerIdTypeCode,
    String? partnerCategoryCode,
    String? salesChannelCode,
    String? partnerStatusCode,
    String? geoAreaCode,
    String? itineraryCode,
    int? rank,
    String? partnerClusterCode,
    String? address,
    String? postalCode,
    String? city,
    String? country,
    String? phone1,
    String? phone2,
    String? fax,
    String? email,
    String? webAddress,
    String? currencyCode,
    String? paymentTermCode,
    String? priceListCode,
    String? vatExo,
    double? creditLimit,
    double? creditBalance,
    bool? hold,
    String? holdReason,
    String? branchCode,
    double? longitude,
    double? latitude,
    String? userField1,
    String? userField2,
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
      name2: name2 ?? this.name2,
      rc: rc ?? this.rc,
      fiscalId: fiscalId ?? this.fiscalId,
      partnerIdTypeCode: partnerIdTypeCode ?? this.partnerIdTypeCode,
      partnerCategoryCode: partnerCategoryCode ?? this.partnerCategoryCode,
      salesChannelCode: salesChannelCode ?? this.salesChannelCode,
      partnerStatusCode: partnerStatusCode ?? this.partnerStatusCode,
      geoAreaCode: geoAreaCode ?? this.geoAreaCode,
      itineraryCode: itineraryCode ?? this.itineraryCode,
      rank: rank ?? this.rank,
      partnerClusterCode: partnerClusterCode ?? this.partnerClusterCode,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      country: country ?? this.country,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      fax: fax ?? this.fax,
      email: email ?? this.email,
      webAddress: webAddress ?? this.webAddress,
      currencyCode: currencyCode ?? this.currencyCode,
      paymentTermCode: paymentTermCode ?? this.paymentTermCode,
      priceListCode: priceListCode ?? this.priceListCode,
      vatExo: vatExo ?? this.vatExo,
      creditLimit: creditLimit ?? this.creditLimit,
      creditBalance: creditBalance ?? this.creditBalance,
      hold: hold ?? this.hold,
      holdReason: holdReason ?? this.holdReason,
      branchCode: branchCode ?? this.branchCode,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      userField1: userField1 ?? this.userField1,
      userField2: userField2 ?? this.userField2,
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