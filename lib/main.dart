import 'package:erp_mobile/app/controllers/order_details_controller.dart';
import 'package:erp_mobile/app/controllers/order_list_controller.dart';
import 'package:erp_mobile/app/services/customer_service.dart';
import 'package:erp_mobile/app/views/client/clients_view.dart';
import 'package:erp_mobile/app/views/order/order_details_view.dart';
import 'package:erp_mobile/app/views/order/order_list_view.dart';
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
import 'app/controllers/auth_controller.dart';
import 'app/controllers/tournee_controller.dart';
import 'app/controllers/order_controller.dart';

void main() async {
  // Initialisation GetStorage
  await GetStorage.init();
  
  // ✅ SERVICES - Injection globale complète
  Get.put(ApiService());
  Get.put(TourneeService());
  Get.put(ProductService());
  Get.put(OrderService());
  Get.put(CustomerService());
  
  // ✅ CONTROLLERS - Injection globale des controllers persistants uniquement
  Get.put(AuthController());
  Get.put(TourneeController());
  Get.put(OrderController());
  // ❌ SUPPRIMÉ: Get.put(OrdersListController()); 
  // ❌ SUPPRIMÉ: Get.put(OrderDetailsController());
  // Ces contrôleurs seront créés à la demande via les bindings
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ERP Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        
        // ✅ Thème amélioré pour les commandes
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        
        // ✅ CORRECTION: CardTheme → CardThemeData
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // ✅ Styles pour les boutons
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
      
      // ✅ Routes complètes avec système de commandes
      initialRoute: '/',
      getPages: [
        // Routes existantes
        GetPage(name: '/', page: () => LoginView()),
        GetPage(name: '/tournee', page: () => TourneeView()),
        GetPage(name: '/clients', page: () => ClientsView()),
        
        // ✅ Nouvelles routes commandes
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
        
        // ✅ ROUTE LISTE COMMANDES avec binding
        GetPage(
          name: '/orders',
          page: () => OrdersListView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<OrdersListController>(() => OrdersListController());
          }),
          transition: Transition.rightToLeft,
          transitionDuration: Duration(milliseconds: 300),
        ),
        
        // ✅ ROUTE DÉTAILS COMMANDES avec paramètre et binding
        GetPage(
          name: '/order-details/:id',
          page: () => OrderDetailsView(),
          binding: BindingsBuilder(() {
            Get.lazyPut<OrderDetailsController>(() => OrderDetailsController());
          }),
          transition: Transition.rightToLeft,
          transitionDuration: Duration(milliseconds: 300),
        ),
      ],
      
      // ✅ Configuration globale
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
      
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
    );
  }
}