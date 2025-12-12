import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/payment.dart';
import '../models/order.dart';
import '../services/payment_service.dart';
import 'auth_controller.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  final AuthController _authController = Get.find<AuthController>();

  // États pour la liste des paiements
  final isLoadingList = true.obs;
  final payments = <Payment>[].obs;
  final order = Rxn<Order>();

  // États pour le formulaire
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final isSubmitting = false.obs;
  final selectedMethod = 'CASH'.obs;

  final List<String> paymentMethods = ['CASH', 'CHECK', 'TRANSFER', 'MOBILE'];

  // Totaux calculés
  double get totalBL => order.value?.totalAmountTTC ?? 0.0;
  double get totalPaid => payments.fold(0.0, (sum, payment) => sum + payment.amount);
  double get remaining => totalBL - totalPaid;

  @override
  void onInit() {
    super.onInit();

    // Récupérer l'order depuis les arguments
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      order.value = args['order'] as Order?;

      if (order.value?.id != null) {
        loadPayments();
      }
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }

  /// Charger les paiements du BL
  Future<void> loadPayments() async {
    try {
      isLoadingList.value = true;

      final blId = order.value?.id;
      if (blId == null) {
        throw Exception('ID du BL manquant');
      }

      print('📋 Chargement des paiements pour BL #$blId');

      final loadedPayments = await _paymentService.getPaymentsByDocument(blId);
      payments.value = loadedPayments;

      print('✅ ${loadedPayments.length} paiements chargés');
    } catch (e) {
      print('❌ Erreur chargement paiements: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les paiements',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingList.value = false;
    }
  }

  /// Ouvrir l'écran d'ajout de paiement
  Future<void> openAddPayment() async {
    // Réinitialiser le formulaire
    amountController.clear();
    noteController.clear();
    selectedMethod.value = 'CASH';

    final result = await Get.toNamed('/add-payment', arguments: {
      'order': order.value,
    });

    // Si un paiement a été ajouté, recharger la liste
    if (result == true) {
      await loadPayments();
    }
  }

  /// Valider et soumettre le paiement
  Future<void> submitPayment() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isSubmitting.value = true;

      final currentOrder = order.value;
      final user = _authController.user.value;

      if (currentOrder == null || user == null) {
        throw Exception('Données manquantes');
      }

      print('💳 Création paiement...');
      print('📊 Order ID: ${currentOrder.id}, Client ID: ${currentOrder.customerId}, User ID: ${user.id}');
      print('💰 Amount: ${amountController.text}, Method: ${selectedMethod.value}');

      await _paymentService.createPayment(
        salesDocumentId: currentOrder.id!,
        clientId: currentOrder.customerId,
        userId: user.id,
        amount: double.parse(amountController.text),
        method: selectedMethod.value,
        note: noteController.text.isEmpty ? null : noteController.text,
      );

      print('✅ Paiement créé avec succès');
      print('🔙 Retour à la page précédente...');

      // ✅ IMPORTANT: Désactiver isSubmitting AVANT Get.back
      isSubmitting.value = false;

      // ✅ Retourner IMMÉDIATEMENT avec succès
      Get.back(result: true);

      // ✅ Afficher le snackbar APRÈS le retour (avec délai pour laisser la transition se faire)
      Future.delayed(Duration(milliseconds: 300), () {
        Get.snackbar(
          'Succès',
          'Paiement enregistré',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      });

    } catch (e, stackTrace) {
      print('❌ Erreur création paiement: $e');
      print('📍 StackTrace: $stackTrace');

      isSubmitting.value = false;

      Get.snackbar(
        'Erreur',
        'Impossible d\'enregistrer le paiement: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  /// Formater le nom du mode de paiement
  String formatPaymentMethod(String method) {
    switch (method) {
      case 'CASH': return 'Espèces';
      case 'CHECK': return 'Chèque';
      case 'TRANSFER': return 'Virement';
      case 'MOBILE': return 'Mobile';
      default: return method;
    }
  }
}
