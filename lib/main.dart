import 'package:erp_mobile/app/views/client/clients_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/views/auth/login_view.dart';
import 'app/views/tournee/tournee_view.dart';
import 'app/services/api_service.dart';
import 'app/services/tournee_service.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/tournee_controller.dart';

void main() async {
  // Initialisation GetStorage
  await GetStorage.init();
  
  // ✅ TOUT en global - Plus simple !
  Get.put(ApiService());
  Get.put(TourneeService());
  Get.put(AuthController());
  Get.put(TourneeController());
  
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
      ),
      
      // ✅ Routes simplifiées - Pas de bindings
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginView()),
        GetPage(name: '/tournee', page: () => TourneeView()),
        GetPage(name: '/clients', page: () => ClientsView()),
      ],
      
      debugShowCheckedModeBanner: false,
    );
  }
}