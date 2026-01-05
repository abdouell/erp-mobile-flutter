class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

class TokenExpiredException extends AuthException {
  TokenExpiredException() : super('Votre session a expiré');
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Identifiants incorrects');
}

class NetworkException extends AuthException {
  NetworkException(String message) : super('Erreur réseau: $message');
}

class SessionExpiredException extends AuthException {
  SessionExpiredException() : super('Session expirée, veuillez vous reconnecte');
}
