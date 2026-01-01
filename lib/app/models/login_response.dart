import 'user.dart';

class LoginResponse {
  final String token;
  final User user;
  
  LoginResponse({
    required this.token,
    required this.user,
  });
  
  // Convertir réponse JSON backend → LoginResponse
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['accessToken'],  // Backend sends 'accessToken' not 'token'
      user: User.fromJson(json['user']),
    );
  }
}