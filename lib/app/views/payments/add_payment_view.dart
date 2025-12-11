import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';

class AddPaymentView extends GetView<PaymentController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau paiement'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info BL
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BL #${controller.order.value?.id ?? ''}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Total: ${controller.order.value?.totalAmountTTC?.toStringAsFixed(2) ?? '0.00'} €',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Champ montant
              TextFormField(
                controller: controller.amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Montant *',
                  prefixText: '€ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le montant est obligatoire';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              // Dropdown mode de paiement
              DropdownButtonFormField<String>(
                value: controller.selectedMethod.value,
                decoration: InputDecoration(
                  labelText: 'Mode de paiement *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: controller.paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Row(
                      children: [
                        Icon(_getPaymentMethodIcon(method), size: 20),
                        SizedBox(width: 8),
                        Text(controller.formatPaymentMethod(method)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedMethod.value = value;
                  }
                },
              ),
              
              SizedBox(height: 16),
              
              // Champ remarque
              TextFormField(
                controller: controller.noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Remarque (optionnel)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'Ajouter une remarque...',
                ),
              ),
              
              SizedBox(height: 32),
              
              // Bouton enregistrer
              ElevatedButton(
                onPressed: controller.isSubmitting.value 
                    ? null 
                    : () => controller.submitPayment(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isSubmitting.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Enregistrer le paiement',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      )),
    );
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
}
