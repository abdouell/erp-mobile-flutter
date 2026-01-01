import 'package:dio/dio.dart';
import 'app_exceptions.dart';

/// Converts DioException to AppException
/// This is the ONLY place where HTTP/Dio logic should be handled
class ErrorConverter {
  static AppException convert(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Délai de connexion dépassé');
        
      case DioExceptionType.connectionError:
        return const NetworkException('Erreur de connexion réseau');
        
      case DioExceptionType.badResponse:
        return _handleHttpError(dioException);
        
      case DioExceptionType.cancel:
        return const UnexpectedException('Requête annulée');
        
      case DioExceptionType.unknown:
      default:
        return UnexpectedException(
          'Erreur inattendue: ${dioException.message}',
          originalError: dioException,
        );
    }
  }
  
  static AppException _handleHttpError(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final data = dioException.response?.data;
    
    // Extract server message if available
    String serverMessage = _extractServerMessage(data);
    
    switch (statusCode) {
      case 400:
        return ValidationException(
          serverMessage.isNotEmpty ? serverMessage : 'Requête invalide',
          code: 'BAD_REQUEST',
        );
        
      case 401:
        // Special case for login - return raw response for now (MVP)
        if (dioException.requestOptions.path.contains('/api/auth/login')) {
          return UnexpectedException(
            serverMessage.isNotEmpty ? serverMessage : 'Identifiants invalides',
            originalError: dioException,
          );
        }
        return UnauthorizedException(
          serverMessage.isNotEmpty ? serverMessage : 'Non autorisé',
          code: 'UNAUTHORIZED',
        );
        
      case 403:
        return ForbiddenException(
          serverMessage.isNotEmpty ? serverMessage : 'Accès refusé',
          code: 'FORBIDDEN',
        );
        
      case 404:
        return NotFoundException(
          serverMessage.isNotEmpty ? serverMessage : 'Ressource introuvable',
          code: 'NOT_FOUND',
        );
        
      case 409:
        return ConflictException(
          serverMessage.isNotEmpty ? serverMessage : 'Conflit de données',
          code: 'CONFLICT',
        );
        
      case 500:
        return ServerException(
          serverMessage.isNotEmpty ? serverMessage : 'Erreur serveur interne',
          code: 'SERVER_ERROR',
        );
        
      case 503:
        return ServerException(
          serverMessage.isNotEmpty ? serverMessage : 'Service indisponible',
          code: 'SERVICE_UNAVAILABLE',
        );
        
      default:
        return ServerException(
          serverMessage.isNotEmpty ? serverMessage : 'Erreur serveur: $statusCode',
          code: 'HTTP_ERROR_$statusCode',
        );
    }
  }
  
  static String _extractServerMessage(dynamic data) {
    if (data == null) return '';
    
    // Handle plain text responses (like login errors)
    if (data is String) {
      return data.trim();
    }
    
    // Handle JSON responses
    if (data is Map<String, dynamic>) {
      // Try common message fields
      for (String key in ['message', 'error', 'detail', 'description']) {
        if (data[key] is String) {
          return data[key].toString().trim();
        }
      }
    }
    
    return '';
  }
}
