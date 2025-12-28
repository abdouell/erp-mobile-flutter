/// Custom application exceptions for clean error handling
/// Replaces raw DioException with domain-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const AppException(this.message, {this.code, this.originalError});
  
  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ServerException extends AppException {
  const ServerException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class TimeoutException extends AppException {
  const TimeoutException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Authentication & Authorization exceptions
class UnauthorizedException extends AppException {
  const UnauthorizedException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ForbiddenException extends AppException {
  const ForbiddenException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class TokenExpiredException extends AppException {
  const TokenExpiredException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Business logic exceptions
class BusinessException extends AppException {
  const BusinessException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ValidationException extends AppException {
  const ValidationException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class NotFoundException extends AppException {
  const NotFoundException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ConflictException extends AppException {
  const ConflictException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Generic exception for unexpected errors
class UnexpectedException extends AppException {
  const UnexpectedException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}
