class ApiConstants {
  // Votre serveur local
  static const String BASE_URL = 'https://api.distrimob.fr';
  //static const String BASE_URL = 'http://localhost:8081';
  
  // Endpoints
  static const String LOGIN = '/api/user/login';
  
  // Headers
  static const Map<String, String> HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
