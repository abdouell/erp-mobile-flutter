import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  
  // Vérifier les permissions
  Future<bool> hasPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }
  
  // Demander les permissions
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }
  
  // Obtenir la position actuelle
  Future<Position?> getCurrentPosition() async {
    try {
      // Vérifier si le service est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Service de géolocalisation désactivé');
      }
      
      // Vérifier les permissions
      if (!await hasPermission()) {
        if (!await requestPermission()) {
          throw Exception('Permission géolocalisation refusée');
        }
      }
      
      // Obtenir la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      
      return position;
      
    } catch (e) {
      print('Erreur géolocalisation: $e');
      return null;
    }
  }
}