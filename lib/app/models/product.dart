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

  // ✅ NOUVEAUX CHAMPS pour tarification client
  final double? customerPrice;      // Prix client spécifique (null si = catalogue)
  final double? discountPercent;    // % de remise (null si pas de remise)
  final bool hasPriceList;          // Indique si le client a un tarif spécial

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
  final int? quantiteEnStock; //Stock disponible pour vendeur conventionnel


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
    this.customerPrice,
    this.discountPercent,
    this.hasPriceList = false,
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
    this.quantiteEnStock,
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
      customerPrice: json['customerPrice']?.toDouble(),
      discountPercent: json['discountPercent']?.toDouble(),
      hasPriceList: json['hasPriceList'] ?? false,
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
      quantiteEnStock: json['quantiteStock'],
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
      'customerPrice': customerPrice,
      'discountPercent': discountPercent,
      'hasPriceList': hasPriceList,
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
      'quantiteStock': quantiteEnStock, 
    };
  }

  /// 🎯 Helper methods utilisés dans l'UI
  String get displayName => description;
  
  String get shortDescription {
    if (description.length <= 50) return description;
    return '${description.substring(0, 47)}...';
  }
  
  String get formattedPrice => '${salesPrice.toStringAsFixed(2)} €';

  // ✅HELPERS TARIFICATION CLIENT

  /// Prix réel à payer (client ou catalogue)
  double get effectivePrice => customerPrice ?? salesPrice;

  /// Prix formaté pour affichage
  String get formattedEffectivePrice => '${effectivePrice.toStringAsFixed(2)} €';

  /// Vérifier s'il y a une remise à afficher
  bool get hasDiscount => hasPriceList && 
                          customerPrice != null && 
                          customerPrice! < salesPrice &&
                          discountPercent != null;

  /// Formater le % de remise pour affichage
  String get formattedDiscount => hasDiscount 
      ? '-${discountPercent!.toStringAsFixed(1)}%'
      : '';

  /// Prix catalogue formaté (pour affichage barré)
  String get formattedCatalogPrice => formattedPrice;
  
  bool get hasPhoto => photo != null && photo!.isNotEmpty;
  
  bool get isAvailable => !hold;
  
  String get categoryDisplay => productCategoryCode;

    /// 📦 NOUVEAUX HELPERS STOCK - Vérifier si le stock est disponible (pour vendeurs conventionnels)
  bool get hasStockInfo => quantiteEnStock != null;

  /// 📦 Stock disponible (0 si pas d'info)
  int get stockDisponible => quantiteEnStock ?? 0;

  /// ⚠️ Stock faible (< 5 unités)
  bool get isLowStock => hasStockInfo && stockDisponible > 0 && stockDisponible < 5;

  /// 🔴 Stock épuisé
  bool get isOutOfStock => hasStockInfo && stockDisponible <= 0;

  /// 📊 Libellé du stock pour affichage
  String get stockLabel {
    if (!hasStockInfo) return '';
    if (isOutOfStock) return 'Rupture de stock';
    if (isLowStock) return 'Stock faible : $stockDisponible';
    return 'Stock : $stockDisponible';
  }
  
  /// 🔍 Pour la recherche (utilisé dans ProductService)
  bool matchesSearch(String query) {
    final searchLower = query.toLowerCase();
    return productCode.toLowerCase().contains(searchLower) ||
           description.toLowerCase().contains(searchLower) ||
           brand.toLowerCase().contains(searchLower) ||
           (barcode?.toLowerCase().contains(searchLower) ?? false);
  }



}