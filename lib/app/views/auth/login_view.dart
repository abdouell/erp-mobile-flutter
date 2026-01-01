import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../models/user_dto.dart';

class LoginView extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Titre
              Image.asset(  'assets/images/distrimob_logo.png',width: 200,  fit: BoxFit.contain),
              SizedBox(height: 16),
              Text('DistriMob 1.0', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 48),
              // Champ Username
              TextFormField(
                onChanged: (value) => controller.username.value = value,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Champ Password
              TextFormField(
                onChanged: (value) => controller.password.value = value,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              
              SizedBox(height: 32),
              
              // Bouton Connexion avec état loading
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value 
                      ? null 
                      : () => controller.login(),
                  child: controller.isLoading.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Connexion...'),
                          ],
                        )
                      : Text('Se connecter', style: TextStyle(fontSize: 16)),
                ),
              )),
              
              SizedBox(height: 24),
              
              // Affichage statut (pour debug)
              Obx(() => controller.isAuthenticated.value
                  ? Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(height: 8),
                            Text('Connecté en tant que:'),
                            Text(
                              controller.user.value?.displayName ?? 'Utilisateur',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => controller.logout(),
                              child: Text('Se déconnecter'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
