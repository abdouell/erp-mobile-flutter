import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';

class CustomerPaymentsView extends StatefulWidget {
  final int customerId;
  final String customerName;

  const CustomerPaymentsView({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  _CustomerPaymentsViewState createState() => _CustomerPaymentsViewState();
}

class _CustomerPaymentsViewState extends State<CustomerPaymentsView> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  List<Payment> _payments = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final payments = await _paymentService.getPaymentsByClient(widget.customerId);

      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique paiements'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadPayments,
                child: Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_payments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aucun paiement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Ce client n\'a effectué aucun paiement',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    // Calculer le total
    final totalPaid = _payments.fold(0.0, (sum, payment) => sum + payment.amount);

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: Column(
        children: [
          // Résumé
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Text(
                  widget.customerName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Total payé: ${totalPaid.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_payments.length} paiement(s)',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Liste des paiements
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                return _buildPaymentCard(payment);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Montant et méthode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${payment.amount.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Chip(
                  label: Text(_formatPaymentMethod(payment.method)),
                  backgroundColor: _getPaymentMethodColor(payment.method).withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: _getPaymentMethodColor(payment.method),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // BL concerné
            Row(
              children: [
                Icon(Icons.local_shipping, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text(
                  'BL #${payment.salesDocumentId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy à HH:mm').format(payment.paymentDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),

            // Note si présente
            if (payment.note != null && payment.note!.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payment.note!,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'CASH':
        return 'Espèces';
      case 'CHECK':
        return 'Chèque';
      case 'TRANSFER':
        return 'Virement';
      case 'MOBILE':
        return 'Mobile';
      default:
        return method;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'CASH':
        return Colors.green;
      case 'CHECK':
        return Colors.blue;
      case 'TRANSFER':
        return Colors.purple;
      case 'MOBILE':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
