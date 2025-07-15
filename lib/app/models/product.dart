import 'dart:typed_data';

class Product {
  final int id;
  final String productCode;
  final String description;
  final int rank;
  final String companyCode;
  final String productPageCode;
  final String productCategoryCode;
  final String productTypeCode;
  final String? supplierCode;
  final double salesPrice;
  final String vatCode;
  final bool hold;
  final String rangeCode;
  final String familyCode;
  final String brand;
  final String activityCode;
  final String managementUnit;
  final int? stockMin;
  
  // Champs optionnels
  final String? longDescription;
  final String? barcode;
  final String? page;
  final String? fournisseur;
  final double? discount;
  final double? salesPacking;
  final double? weight;
  final double? volume;
  final bool? weightManaged;
  final double? weightPrecision;
  final Uint8List? photo;
  final bool? freeProduct;
  final double? colisageCarton;

  Product({
    required this.id,
    required this.productCode,
    required this.description,
    required this.rank,
    required this.companyCode,
    required this.productPageCode,
    required this.productCategoryCode,
    required this.productTypeCode,
    this.supplierCode,
    required this.salesPrice,
    required this.vatCode,
    required this.hold,
    required this.rangeCode,
    required this.familyCode,
    required this.brand,
    required this.activityCode,
    required this.managementUnit,
    this.stockMin,
    this.longDescription,
    this.barcode,
    this.page,
    this.fournisseur,
    this.discount,
    this.salesPacking,
    this.weight,
    this.volume,
    this.weightManaged,
    this.weightPrecision,
    this.photo,
    this.freeProduct,
    this.colisageCarton,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productCode: json['productCode'],
      description: json['description'],
      rank: json['rank'],
      companyCode: json['companyCode'],
      productPageCode: json['productPageCode'],
      productCategoryCode: json['productCategoryCode'],
      productTypeCode: json['productTypeCode'],
      supplierCode: json['supplierCode'],
      salesPrice: (json['salesPrice'] ?? 0.0).toDouble(),
      vatCode: json['vatCode'],
      hold: json['hold'] ?? false,
      rangeCode: json['rangeCode'],
      familyCode: json['familyCode'],
      brand: json['brand'],
      activityCode: json['activityCode'],
      managementUnit: json['managementUnit'],
      stockMin: json['stockMin'],
      longDescription: json['longDescription'],
      barcode: json['barcode'],
      page: json['page'],
      fournisseur: json['fournisseur'],
      discount: json['discount']?.toDouble(),
      salesPacking: json['salesPacking']?.toDouble(),
      weight: json['weight']?.toDouble(),
      volume: json['volume']?.toDouble(),
      weightManaged: json['weightManaged'],
      weightPrecision: json['weightPrecision']?.toDouble(),
      photo: json['photo'] != null ? Uint8List.fromList(List<int>.from(json['photo'])) : null,
      freeProduct: json['freeProduct'],
      colisageCarton: json['colisageCarton']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productCode': productCode,
      'description': description,
      'rank': rank,
      'companyCode': companyCode,
      'productPageCode': productPageCode,
      'productCategoryCode': productCategoryCode,
      'productTypeCode': productTypeCode,
      'supplierCode': supplierCode,
      'salesPrice': salesPrice,
      'vatCode': vatCode,
      'hold': hold,
      'rangeCode': rangeCode,
      'familyCode': familyCode,
      'brand': brand,
      'activityCode': activityCode,
      'managementUnit': managementUnit,
      'stockMin': stockMin,
      'longDescription': longDescription,
      'barcode': barcode,
      'page': page,
      'fournisseur': fournisseur,
      'discount': discount,
      'salesPacking': salesPacking,
      'weight': weight,
      'volume': volume,
      'weightManaged': weightManaged,
      'weightPrecision': weightPrecision,
      'photo': photo?.toList(),
      'freeProduct': freeProduct,
      'colisageCarton': colisageCarton,
    };
  }

  /// 🎯 Helper methods utilisés dans l'UI
  String get displayName => description;
  
  String get shortDescription {
    if (description.length <= 50) return description;
    return '${description.substring(0, 47)}...';
  }
  
  String get formattedPrice => '${salesPrice.toStringAsFixed(2)} €';
  
  bool get hasPhoto => photo != null && photo!.isNotEmpty;
  
  bool get isAvailable => !hold;
  
  String get categoryDisplay => productCategoryCode;
  
  /// 🔍 Pour la recherche (utilisé dans ProductService)
  bool matchesSearch(String query) {
    final searchLower = query.toLowerCase();
    return productCode.toLowerCase().contains(searchLower) ||
           description.toLowerCase().contains(searchLower) ||
           brand.toLowerCase().contains(searchLower) ||
           (barcode?.toLowerCase().contains(searchLower) ?? false);
  }
}