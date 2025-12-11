import 'package:erp_mobile/app/controllers/order_details_controller.dart';
import 'package:erp_mobile/app/controllers/order_list_controller.dart';
import 'package:erp_mobile/app/controllers/payment_controller.dart';
import 'package:erp_mobile/app/services/customer_service.dart';
import 'package:erp_mobile/app/services/sales_service.dart';

import 'package:erp_mobile/app/views/client/clients_view.dart';
import 'package:erp_mobile/app/views/client/client_detail_view.dart';
import 'package:erp_mobile/app/views/order/order_details_view.dart';
import 'package:erp_mobile/app/views/order/order_list_view.dart';
import 'package:erp_mobile/app/views/order/sales_history_view.dart';
import 'package:erp_mobile/app/views/payments/bl_payments_view.dart';
import 'package:erp_mobile/app/views/payments/add_payment_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/views/auth/login_view.dart';
import 'app/views/tournee/tournee_view.dart';
import 'app/views/order/order_create_view.dart';
import 'app/views/order/order_confirmation_view.dart';
import 'app/services/api_service.dart';
import 'app/services/tournee_service.dart';
import 'app/services/product_service.dart';
import 'app/services/order_service.dart';
import 'app/services/location_service.dart';

import 'app/controllers/auth_controller.dart';
import 'app/controllers/tournee_controller.dart';
import 'app/controllers/order_controller.dart';

void main() async {
  // Initialisation GetStorage
  await GetStorage.init();
  
  // SERVICES - Injection globale complète
  Get.put(ApiService());
  Get.put(SalesService());
  Get.put(TourneeService());
  Get.put(ProductService());
  Get.put(OrderService());
  Get.put(CustomerService());
  Get.put(LocationService());
  
  // CONTROLLERS - Injection globale des controllers persistants uniquement
  Get.put(AuthController());
  Get.put(TourneeController());
  Get.put(OrderController());

  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return Center(
    child: Container(
      constraints: BoxConstraints(maxWidth: 430),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: GetMaterialApp(
        title: 'DistriMob',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        
        // Thème amélioré pour les commandes
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        
        // CORRECTION: CardTheme → CardThemeData
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Styles pour les boutons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      
      // Routes complètes avec système de commandes
      initialRoute: '/',
      getPages: [
        // Routes existantes
        GetPage(name: '/', page: () => LoginView()),
        GetPage(name: '/tournee', page: () => TourneeView()),
        GetPage(name: '/clients', page: () => ClientsView()),
        
        // Route détail client
        GetPage(
          name: '/client-details',
          page: () => ClientDetailView(),
          transition: Transition.rightToLeft,
          transitionDuration: Duration(milliseconds: 300),
        ),
        
        // Nouvelles routes commandes
        GetPage(
          name: '/order-create',
          page: () => OrderCreateView(),
          transition: Transition.rightToLeft,
          transitionDuration: Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/order-confirmation',
          page: () => OrderConfirmationView(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(milliseconds: 500),
        ),
        
        // ROUTE LISTE COMMANDES avec binding
        GetPage(
          name: '/orders',
          page: () => OrdersListView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<OrdersListController>(() => OrdersListController());
          }),
          transition: Transition.rightToLeft,
          transitionDuration: Duration(milliseconds: 300),
        ),
        
        // ROUTE DÉTAILS COMMANDES avec paramètre et binding
        GetPage(
          name: '/order-details/:id',
          page: () => OrderDetailsView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<OrderDetailsController>(() => OrderDetailsController());
          }),
          transition: Transition.rightToLeft,
          transitionDuration: Duration(milliseconds: 300),
        ),

        // ROUTE HISTORIQUE VENTES UNIFIÉ (ORDER + BL)
        GetPage(
          name: '/sales-history',
          page: () => const SalesHistoryView(),
          transition: Transition.rightToLeft,
          transitionDuration: Duration(milliseconds: 300),
        ),
        
        // ROUTES PAIEMENTS
        GetPage(
          name: '/bl-payments',
          page: () => BlPaymentsView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<PaymentController>(() => PaymentController());
          }),
          transition: Transition.rightToLeft,
          transitionDuration: Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/add-payment',
          page: () => AddPaymentView(),
          transition: Transition.rightToLeft,
          transitionDuration: Duration(milliseconds: 300),
        ),
      ],
      
      // Configuration globale
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
      
      // Gestion d'erreurs globale
      // ✅ Gestion d'erreurs globale
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => Scaffold(
          appBar: AppBar(title: Text('Page non trouvée')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Page non trouvée',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Route: ${Get.currentRoute}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed('/'),
                  child: Text('Retour à l\'accueil'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    ),
  );
}
}