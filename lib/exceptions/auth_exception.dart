class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

class TokenExpiredException extends AuthException {
  TokenExpiredException() : super('Token has expired');
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid email or password');
}

class NetworkException extends AuthException {
  NetworkException(String message) : super('Network error: $message');
}

class SessionExpiredException extends AuthException {
  SessionExpiredException() : super('Session expired, please login again');
}
