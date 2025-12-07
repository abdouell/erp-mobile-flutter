import 'product.dart';

class OrderItem {
  final int? id;
  final int productId;
  final Product? product;
  final int quantity;
  final double price;
  final String designation;
  final double? discount;
  final double? lineTotalHT; // ✅ Total HT de la ligne (du backend)

  OrderItem({
    this.id,
    required this.productId,
    this.product,
    required this.quantity,
    required this.price,
    required this.designation,
    this.discount,
    this.lineTotalHT, // ✅ NOUVEAU PARAMÈTRE
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {

    // ✅ ÉTAPE 1: Parser le produit d'abord
    Product? itemProduct;
    if (json['product'] != null) {
      itemProduct = Product.fromJson(json['product']);
    }
    
    // ✅ ÉTAPE 2: Récupérer les données de base
    final int itemQuantity = (json['quantity'] as num?)?.toInt() ?? 1;
    final int itemProductId = (json['product']?['id'] as num?)?.toInt() ?? (json['productId'] as num?)?.toInt() ?? 0;
    
    // ✅ ÉTAPE 3: Récupérer le prix - PRIORITÉ AU PRODUIT
    double itemPrice = 0.0;
    
    // 1. D'abord essayer depuis le produit (source principale)
    if (itemProduct != null) {
      itemPrice = itemProduct.salesPrice;
    }
    // 2. Fallback sur le champ price direct (si existe)
    else if (json['price'] != null) {
      itemPrice = (json['price'] as num).toDouble();
    }
    
    // ✅ ÉTAPE 4: Récupérer les autres infos depuis le produit
    String itemDesignation = '';
    
    if (itemProduct != null) {
      itemDesignation = itemProduct.description;
    } else {
      // Fallback sur les champs directs
      itemDesignation = json['designation'] ?? '';
    }
    
    // ✅ ÉTAPE 5: Gestion de la remise
    double? itemDiscount;
    if (json['discount'] != null) {
      itemDiscount = (json['discount'] as num).toDouble();
    }
    
    // ✅ ÉTAPE 6: Gestion du total HT
    double? itemLineTotalHT;
    if (json['lineTotalHT'] != null) {
      itemLineTotalHT = (json['lineTotalHT'] as num).toDouble();
    }
    
    return OrderItem(
      id: json['id'] as int?,
      productId: itemProductId,
      product: itemProduct,
      quantity: itemQuantity,
      price: itemPrice,
      designation: itemDesignation,
      discount: itemDiscount,
      lineTotalHT: itemLineTotalHT, // ✅ NOUVEAU CHAMP
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product != null ? {'id': productId} : {'id': productId},
      'quantity': quantity,
      'price': price,
      'designation': designation,
      'discount': discount,
      'lineTotalHT': lineTotalHT, // ✅ NOUVEAU CHAMP
    };
  }

  /// 🛒 Factory pour créer depuis un produit
  factory OrderItem.fromProduct(Product product, int quantity) {
    return OrderItem(
      productId: product.id,
      product: product,
      quantity: quantity,
      price: product.effectivePrice,
      designation: product.description,
      discount: 0.0,
    );
  }

  /// 📊 Calculs pour l'UI
  double get subtotalBeforeDiscount => price * quantity;
  
  double get discountAmount => discount ?? 0.0;
  
  double get subtotalAfterDiscount {
    // Utiliser la valeur du backend si disponible, sinon calculer
    return lineTotalHT ?? (subtotalBeforeDiscount - discountAmount);
  }
  
  double get unitPriceAfterDiscount {
    if (quantity == 0) return 0.0;
    return subtotalAfterDiscount / quantity;
  }

  /// 💰 Formatage pour l'affichage
  String get formattedPrice => '${price.toStringAsFixed(2)} €';
  
  String get formattedSubtotal => '${subtotalAfterDiscount.toStringAsFixed(2)} €';
  
  String get formattedDiscount => '${discountAmount.toStringAsFixed(2)} €';
  
  String get quantityDisplay => '$quantity';

  /// 🏷️ Infos produit (avec fallback si product est null)
  String get productCode => product?.productCode ?? 'PROD-$productId';
  
  String get productName => product?.description ?? designation;
  
  String get productBrand => product?.brand ?? '';

  /// ✏️ copyWith pour modifications immutables
  OrderItem copyWith({
    int? id,
    int? productId,
    Product? product,
    int? quantity,
    double? price,
    String? designation,
    double? discount,
    double? lineTotalHT, // ✅ NOUVEAU PARAMÈTRE
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      designation: designation ?? this.designation,
      discount: discount ?? this.discount,
      lineTotalHT: lineTotalHT ?? this.lineTotalHT, // ✅ NOUVEAU CHAMP
    );
  }

  /// 🔢 Modification de quantité (utilisé dans le contrôleur)
  OrderItem updateQuantity(int newQuantity) {
    return copyWith(quantity: newQuantity > 0 ? newQuantity : 1);
  }

  /// 🔍 Validation
  bool get isValid => quantity > 0 && price >= 0;
  
  bool get hasDiscount => (discount ?? 0) > 0;

  @override
  String toString() {
    return 'OrderItem{productId: $productId, quantity: $quantity, price: $price, total: ${subtotalAfterDiscount.toStringAsFixed(2)}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem &&
           other.productId == productId &&
           other.quantity == quantity &&
           other.price == price;
  }

  @override
  int get hashCode => Object.hash(productId, quantity, price);
}
