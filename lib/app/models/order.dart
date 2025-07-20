import 'order_item.dart';

enum OrderStatus {
  DRAFT,
  VALIDATED,
  CANCELLED,
}

class Order {
  final int? id;
  final int userId;
  final DateTime createdDate;
  final OrderStatus status;
  final List<OrderItem> orderDetails;
  final double totalAmount;
  final String? entrepriseCode;
  final int customerId;

  Order({
    this.id,
    required this.userId,
    required this.createdDate,
    required this.status,
    required this.orderDetails,
    required this.totalAmount,
    this.entrepriseCode,
    required this.customerId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      createdDate: DateTime.parse(json['createdDate']),
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
      entrepriseCode: json['entrepriseCode'],
      customerId: json['customerId'],
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
      'entrepriseCode': entrepriseCode,
      'customerId': customerId,
    };
  }

  /// 🏗️ Factory pour créer une nouvelle commande
  factory Order.create({
    required int userId,
    required int customerId,
    String? entrepriseCode,
  }) {
    return Order(
      userId: userId,
      createdDate: DateTime.now(),
      status: OrderStatus.DRAFT,
      orderDetails: [],
      totalAmount: 0.0,
      entrepriseCode: entrepriseCode,
      customerId: customerId,
    );
  }

  /// 📊 Calculs et statistiques
  int get itemCount => orderDetails.length;
  
  int get totalQuantity => orderDetails.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotalBeforeDiscount {
    return orderDetails.fold(0.0, (sum, item) => sum + item.subtotalBeforeDiscount);
  }
  
  double get totalDiscount {
    return orderDetails.fold(0.0, (sum, item) => sum + item.discountAmount);
  }
  
  double get calculatedTotal => subtotalBeforeDiscount - totalDiscount;

  /// 💰 Formatage pour l'affichage
  String get formattedTotal => '${totalAmount.toStringAsFixed(2)} €';
  
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

  /// ✏️ copyWith pour modifications immutables
  Order copyWith({
    int? id,
    int? userId,
    DateTime? createdDate,
    OrderStatus? status,
    List<OrderItem>? orderDetails,
    double? totalAmount,
    String? entrepriseCode,
    int? customerId,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
      orderDetails: orderDetails ?? this.orderDetails,
      totalAmount: totalAmount ?? this.totalAmount,
      entrepriseCode: entrepriseCode ?? this.entrepriseCode,
      customerId: customerId ?? this.customerId,
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
    return 'Order{id: $id, customerId: $customerId, status: $status, items: ${orderDetails.length}, total: ${totalAmount.toStringAsFixed(2)}}';
  }
}