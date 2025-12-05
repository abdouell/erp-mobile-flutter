import 'package:flutter/material.dart';

class SalesDocumentHistory {
  final int id;
  final String documentType; // "ORDER" ou "BL"
  final String? documentNumber;
  final String status;
  final DateTime documentDate;
  final double totalAmount;
  final int customerId;
  final String customerName;
  final int userId;
  final String? comment;
  final bool canEdit;
  final bool canCancel;
  final bool canDownloadPdf;

  SalesDocumentHistory({
    required this.id,
    required this.documentType,
    this.documentNumber,
    required this.status,
    required this.documentDate,
    required this.totalAmount,
    required this.customerId,
    required this.customerName,
    required this.userId,
    this.comment,
    required this.canEdit,
    required this.canCancel,
    required this.canDownloadPdf,
  });

  factory SalesDocumentHistory.fromJson(Map<String, dynamic> json) {
    return SalesDocumentHistory(
      id: json['id'],
      documentType: json['documentType'],
      documentNumber: json['documentNumber'],
      status: json['status'],
      documentDate: DateTime.parse(json['documentDate']),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      customerId: json['customerId'],
      customerName: json['customerName'] ?? 'Client inconnu',
      userId: json['userId'],
      comment: json['comment'],
      canEdit: json['canEdit'] ?? false,
      canCancel: json['canCancel'] ?? false,
      canDownloadPdf: json['canDownloadPdf'] ?? true,
    );
  }

  Color get statusColor {
    switch (status) {
      case 'DRAFT':
        return Colors.orange;
      case 'VALIDATED':
        return Colors.blue;
      case 'POSTED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (documentType) {
      case 'BL':
        return Icons.local_shipping;
      case 'CREDIT_NOTE':
        return Icons.receipt_long;
      case 'RETURN_REQUEST':
        return Icons.assignment_return;
      case 'INVOICE':
        return Icons.receipt;
      case 'ORDER':
      default:
        return Icons.shopping_cart;
    }
  }

  String get typeLabel {
    switch (documentType) {
      case 'BL':
        return 'Bon de livraison';
      case 'CREDIT_NOTE':
        return 'Avoir';
      case 'RETURN_REQUEST':
        return 'Demande de retour';
      case 'INVOICE':
        return 'Facture';
      case 'ORDER':
      default:
        return 'Commande';
    }
  }
}
