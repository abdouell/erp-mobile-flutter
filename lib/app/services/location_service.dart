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
      // First try native last known position (OS-level cache)
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      
      if (lastKnownPosition != null) {
        final cacheAge = DateTime.now().difference(lastKnownPosition.timestamp);
        
        // Use if recent (within 5 minutes)
        if (cacheAge.inMinutes < 5) {
          print('📍 GPS: Using cached position (${cacheAge.inMinutes}m old)');
          return lastKnownPosition;
        }
      }
      
      // Get fresh GPS position
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (lastKnownPosition != null) {
          print('📍 GPS: Service disabled, using cached position');
          return lastKnownPosition;
        }
        throw Exception('Service de géolocalisation désactivé');
      }
      
      if (!await hasPermission()) {
        if (!await requestPermission()) {
          if (lastKnownPosition != null) {
            print('📍 GPS: Permission denied, using cached position');
            return lastKnownPosition;
          }
          throw Exception('Permission géolocalisation refusée');
        }
      }
      
      // Get fresh position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      );
      
      print('📍 GPS: Fresh position acquired (accuracy: ${position.accuracy}m)');
      return position;
      
    } catch (e) {
      print('📍 GPS Error: $e');
      
      // Fallback to last known position on timeout
      if (e.toString().contains('timeout')) {
        try {
          final fallbackPosition = await Geolocator.getLastKnownPosition();
          if (fallbackPosition != null) {
            final cacheAge = DateTime.now().difference(fallbackPosition.timestamp);
            print('📍 GPS: Using cached position after timeout (${cacheAge.inMinutes}m old)');
            return fallbackPosition;
          }
        } catch (fallbackError) {
          print('📍 GPS: Fallback failed: $fallbackError');
        }
      }
      
      return null;
    }
  }
}