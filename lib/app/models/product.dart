import 'dart:typed_data';
import 'product_photo_helper.dart';

class Product {
  final int id;
  final String productCode;
  final String description;
  final String productCategoryCode;
  final double salesPrice;

  // ✅ NOUVEAUX CHAMPS pour tarification client
  final double? customerPrice;      // Prix client spécifique (null si = catalogue)
  final double? discountPercent;    // % de remise (null si pas de remise)
  final bool hasPriceList;          // Indique si le client a un tarif spécial
  final bool hold;
  final int? stockMin;

  // Champs optionnels
  final String? vatCode;
  final double? vatValue;
  final String? barcode;
  final Uint8List? photo;
  final int? quantiteEnStock; // Stock disponible pour vendeur conventionnel

  Product({
    required this.id,
    required this.productCode,
    required this.description,
    required this.productCategoryCode,
    required this.salesPrice,
    this.customerPrice,
    this.discountPercent,
    this.hasPriceList = false,
    required this.hold,
    this.stockMin,
    this.vatCode,
    this.vatValue,
    this.barcode,
    this.photo,
    this.quantiteEnStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productCode: json['productCode'],
      description: json['description'],
      productCategoryCode: json['productCategoryCode'],
      salesPrice: (json['salesPrice'] ?? 0.0).toDouble(),
      customerPrice: json['customerPrice']?.toDouble(),
      discountPercent: json['discountPercent']?.toDouble(),
      hasPriceList: json['hasPriceList'] ?? false,
      hold: json['hold'] ?? false,
      stockMin: json['stockMin'],
      vatCode: json['vatCode'],
      vatValue: json['vatValue']?.toDouble(),
      barcode: json['barcode'],
      photo: json['photo'] != null ? ProductPhotoHelper.decodePhoto(json['photo']) : null,
      quantiteEnStock: json['quantiteStock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productCode': productCode,
      'description': description,
      'productCategoryCode': productCategoryCode,
      'salesPrice': salesPrice,
      'customerPrice': customerPrice,
      'discountPercent': discountPercent,
      'hasPriceList': hasPriceList,
      'hold': hold,
      'stockMin': stockMin,
      'vatCode': vatCode,
      'vatValue': vatValue,
      'barcode': barcode,
      'photo': photo?.toList(),
      'quantiteStock': quantiteEnStock, 
    };
  }

  /// Helper methods utilisés dans l'UI
  String get displayName => description;
  
  String get shortDescription {
    if (description.length <= 50) return description;
    return '${description.substring(0, 47)}...';
  }

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
  String get formattedCatalogPrice => '${salesPrice.toStringAsFixed(2)} €';

  bool get hasPhoto => photo != null && photo!.isNotEmpty;

  bool get isAvailable => !hold;

  String get categoryDisplay => productCategoryCode;

  /// NOUVEAUX HELPERS STOCK - Vérifier si le stock est disponible (pour vendeurs conventionnels)
  bool get hasStockInfo => quantiteEnStock != null;

  /// Stock disponible (0 si pas d'info)
  int get stockDisponible => quantiteEnStock ?? 0;

  /// Stock faible (< 5 unités)
  bool get isLowStock => hasStockInfo && stockDisponible > 0 && stockDisponible < 5;

  /// Stock épuisé
  bool get isOutOfStock => hasStockInfo && stockDisponible <= 0;

  /// Libellé du stock pour affichage
  String get stockLabel {
    if (!hasStockInfo) return '';
    if (isOutOfStock) return 'Rupture de stock';
    if (isLowStock) return 'Stock faible : $stockDisponible';
    return 'Stock : $stockDisponible';
  }

  /// Pour la recherche (utilisé dans ProductService)
  bool matchesSearch(String query) {
    final searchLower = query.toLowerCase();
    return productCode.toLowerCase().contains(searchLower) ||
           description.toLowerCase().contains(searchLower) ||
           (barcode?.toLowerCase().contains(searchLower) ?? false);
  }
}