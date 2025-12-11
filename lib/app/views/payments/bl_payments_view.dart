import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/payment_controller.dart';
import '../../models/payment.dart';

class BlPaymentsView extends GetView<PaymentController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiements - BL #${controller.order.value?.id ?? ''}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoadingList.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement des paiements...'),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => controller.loadPayments(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Résumé financier
                  _buildFinancialSummary(),
                  
                  SizedBox(height: 20),
                  
                  // Liste des paiements
                  _buildPaymentsList(),
                  
                  SizedBox(height: 20),
                  
                  // Bouton ajouter paiement
                  ElevatedButton.icon(
                    onPressed: () => controller.openAddPayment(),
                    icon: Icon(Icons.add),
                    label: Text('Ajouter un paiement'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
  
  /// Résumé financier
  Widget _buildFinancialSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé financier',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            
            _buildSummaryRow('Total BL', '${controller.totalBL.toStringAsFixed(2)} €'),
            SizedBox(height: 8),
            _buildSummaryRow('Total payé', '${controller.totalPaid.toStringAsFixed(2)} €', 
              color: Colors.green.shade600),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            _buildSummaryRow(
              'Reste à payer', 
              '${controller.remaining.toStringAsFixed(2)} €',
              isTotal: true,
              color: controller.remaining > 0 ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Liste des paiements
  Widget _buildPaymentsList() {
    return Obx(() {
      if (controller.payments.isEmpty) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.payment, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucun paiement enregistré',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      }
      
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historique des paiements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              
              ...controller.payments.map((payment) => _buildPaymentItem(payment)).toList(),
            ],
          ),
        ),
      );
    });
  }
  
  /// Item de paiement
  Widget _buildPaymentItem(Payment payment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Icône mode de paiement
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPaymentMethodColor(payment.method).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getPaymentMethodIcon(payment.method),
              color: _getPaymentMethodColor(payment.method),
              size: 20,
            ),
          ),
          
          SizedBox(width: 12),
          
          // Détails
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${payment.amount.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_formatPaymentMethod(payment.method)} - ${_formatDate(payment.paymentDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (payment.note != null && payment.note!.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    payment.note!,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Ligne de résumé
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
  
  /// Helpers
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  
  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'CASH': return 'Espèces';
      case 'CHECK': return 'Chèque';
      case 'TRANSFER': return 'Virement';
      case 'MOBILE': return 'Mobile';
      default: return method;
    }
  }
  
  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'CASH': return Icons.money;
      case 'CHECK': return Icons.receipt;
      case 'TRANSFER': return Icons.account_balance;
      case 'MOBILE': return Icons.phone_android;
      default: return Icons.payment;
    }
  }
  
  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'CASH': return Colors.green;
      case 'CHECK': return Colors.blue;
      case 'TRANSFER': return Colors.purple;
      case 'MOBILE': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
