import 'user_dto.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserDto user;
  
  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
      user: UserDto.fromJson(json['user'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'user': user.toJson(),
    };
  }
}
