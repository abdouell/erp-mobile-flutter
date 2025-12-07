import 'package:flutter/material.dart';
import 'order_item.dart';

enum OrderStatus {
  DRAFT,
  VALIDATED,
  CANCELLED,
}

/// ✅ Extension pour ajouter label et color à OrderStatus
extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.DRAFT:
        return 'Brouillon';
      case OrderStatus.VALIDATED:
        return 'Validée';
      case OrderStatus.CANCELLED:
        return 'Annulée';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.DRAFT:
        return Colors.orange;
      case OrderStatus.VALIDATED:
        return Colors.green;
      case OrderStatus.CANCELLED:
        return Colors.red;
    }
  }

  String get colorName {
    switch (this) {
      case OrderStatus.DRAFT:
        return 'orange';
      case OrderStatus.VALIDATED:
        return 'green';
      case OrderStatus.CANCELLED:
        return 'red';
    }
  }
}

class Order {
  final int? id;
  final int userId;
  final DateTime createdDate;
  final OrderStatus status;
  final List<OrderItem> orderDetails;
  final double totalAmount;
  final double? totalAmountTTC; // ✅ Total TTC du backend
  final double? totalDiscountFromBackend; // ✅ Total remises du backend
  final String? entrepriseCode;
  final int customerId;
  final String? comment; // ✅ NOUVEAU CHAMP
  final double? latitude;
  final double? longitude;

  Order({
    this.id,
    required this.userId,
    required this.createdDate,
    required this.status,
    required this.orderDetails,
    required this.totalAmount,
    this.totalAmountTTC, // ✅ NOUVEAU PARAMÈTRE
    this.totalDiscountFromBackend, // ✅ NOUVEAU PARAMÈTRE
    this.entrepriseCode,
    required this.customerId,
    this.comment, // ✅ NOUVEAU PARAMÈTRE
    this.latitude,
    this.longitude,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Gestion robuste de la date de création qui peut être null ou absente
    final dynamic createdDateValue = json['createdDate'];
    DateTime parsedCreatedDate;

    if (createdDateValue is String && createdDateValue.isNotEmpty) {
      parsedCreatedDate = DateTime.parse(createdDateValue);
    } else {
      // Fallback : si le backend renvoie une date null/absente, on prend la date courante
      parsedCreatedDate = DateTime.now();
    }

    return Order(
      id: json['id'] as int?,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      createdDate: parsedCreatedDate,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.DRAFT,
      ),
      orderDetails: json['orderDetails'] != null
          ? (json['orderDetails'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : [],
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      totalAmountTTC: json['totalAmountTTC']?.toDouble(), // ✅ NOUVEAU CHAMP
      totalDiscountFromBackend: json['totalDiscount']?.toDouble(), // ✅ NOUVEAU CHAMP
      entrepriseCode: json['entrepriseCode'],
      customerId: (json['customerId'] as num?)?.toInt() ?? 0,
      comment: json['comment'], // ✅ NOUVEAU CHAMP
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdDate': createdDate.toIso8601String().split('T')[0],
      'status': status.name,
      'orderDetails': orderDetails.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'totalAmountTTC': totalAmountTTC, // ✅ NOUVEAU CHAMP
      'totalDiscount': totalDiscountFromBackend, // ✅ NOUVEAU CHAMP
      'entrepriseCode': entrepriseCode,
      'customerId': customerId,
      'comment': comment, // ✅ NOUVEAU CHAMP
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// 🏗️ Factory pour créer une nouvelle commande
  factory Order.create({
    required int userId,
    required int customerId,
    String? entrepriseCode,
    String? comment,
    double? latitude,
    double? longitude,
  }) {
    return Order(
      userId: userId,
      createdDate: DateTime.now(),
      status: OrderStatus.DRAFT,
      orderDetails: [],
      totalAmount: 0.0,
      totalAmountTTC: null,
      totalDiscountFromBackend: null,
      entrepriseCode: entrepriseCode,
      customerId: customerId,
      comment: comment,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// 📊 Calculs et statistiques
  int get itemCount => orderDetails.length;

  int get totalQuantity => orderDetails.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalBeforeDiscount {
    return orderDetails.fold(0.0, (sum, item) => sum + item.subtotalBeforeDiscount);
  }

  double get totalDiscount {
    // Utiliser la valeur du backend si disponible, sinon calculer
    return totalDiscountFromBackend ?? orderDetails.fold(0.0, (sum, item) => sum + item.discountAmount);
  }

  double get calculatedTotal => subtotalBeforeDiscount - totalDiscount;

  /// 💰 Formatage pour l'affichage
  String get formattedTotal => '${totalAmount.toStringAsFixed(2)} €';

  String get formattedTotalTTC => '${(totalAmountTTC ?? totalAmount).toStringAsFixed(2)} €';

  String get formattedSubtotal => '${subtotalBeforeDiscount.toStringAsFixed(2)} €';

  String get formattedDiscount => '${totalDiscount.toStringAsFixed(2)} €';

  /// 📅 Formatage de date
  String get formattedDate {
    final now = DateTime.now();
    if (createdDate.year == now.year &&
        createdDate.month == now.month &&
        createdDate.day == now.day) {
      return 'Aujourd\'hui';
    }
    return '${createdDate.day}/${createdDate.month}/${createdDate.year}';
  }

  /// 🏷️ Statut helpers
  bool get isDraft => status == OrderStatus.DRAFT;
  bool get isValidated => status == OrderStatus.VALIDATED;
  bool get isCancelled => status == OrderStatus.CANCELLED;

  bool get canEdit => isDraft;
  bool get canValidate => isDraft && orderDetails.isNotEmpty;

  String get statusDisplay {
    switch (status) {
      case OrderStatus.DRAFT:
        return 'Brouillon';
      case OrderStatus.VALIDATED:
        return 'Validée';
      case OrderStatus.CANCELLED:
        return 'Annulée';
    }
  }

  /// 🎨 Couleurs pour l'UI
  String get statusColor {
    switch (status) {
      case OrderStatus.DRAFT:
        return 'orange';
      case OrderStatus.VALIDATED:
        return 'green';
      case OrderStatus.CANCELLED:
        return 'red';
    }
  }

  /// 💬 Helpers pour les commentaires
  bool get hasComment => comment?.isNotEmpty == true;

  String get displayComment => comment ?? '';

  String get commentPreview {
    if (!hasComment) return '';
    if (comment!.length <= 50) return comment!;
    return '${comment!.substring(0, 47)}...';
  }

  /// ✏️ copyWith pour modifications immutables
  Order copyWith({
    int? id,
    int? userId,
    DateTime? createdDate,
    OrderStatus? status,
    List<OrderItem>? orderDetails,
    double? totalAmount,
    double? totalAmountTTC, // ✅ NOUVEAU PARAMÈTRE
    double? totalDiscountFromBackend, // ✅ NOUVEAU PARAMÈTRE
    String? entrepriseCode,
    int? customerId,
    String? comment, // ✅ NOUVEAU PARAMÈTRE
    double? latitude,
    double? longitude,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
      orderDetails: orderDetails ?? this.orderDetails,
      totalAmount: totalAmount ?? this.totalAmount,
      totalAmountTTC: totalAmountTTC ?? this.totalAmountTTC, // ✅ NOUVEAU CHAMP
      totalDiscountFromBackend: totalDiscountFromBackend ?? this.totalDiscountFromBackend, // ✅ NOUVEAU CHAMP
      entrepriseCode: entrepriseCode ?? this.entrepriseCode,
      customerId: customerId ?? this.customerId,
      comment: comment ?? this.comment, // ✅ NOUVEAU CHAMP
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// 🔍 Utilitaires de base
  bool get isEmpty => orderDetails.isEmpty;
  bool get isNotEmpty => orderDetails.isNotEmpty;

  /// ✅ Validation
  bool get isValid => 
      customerId > 0 && 
      userId > 0 && 
      orderDetails.isNotEmpty &&
      orderDetails.every((item) => item.isValid);

  @override
  String toString() {
    return 'Order{id: $id, customerId: $customerId, status: $status, items: ${orderDetails.length}, total: ${totalAmount.toStringAsFixed(2)}, comment: ${hasComment ? '"$commentPreview"' : 'none'}}';
  }
}