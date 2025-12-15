/// Exceptions personnalisées pour l'application
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception serveur (5xx)
class ServerException extends AppException {
  ServerException([String message = 'Erreur serveur'])
    : super(message, code: 'SERVER_ERROR');
}

/// Exception réseau (pas de connexion)
class NetworkException extends AppException {
  NetworkException([String message = 'Pas de connexion Internet'])
    : super(message, code: 'NETWORK_ERROR');
}

/// Exception d'authentification
class AuthException extends AppException {
  AuthException([String message = 'Erreur d\'authentification'])
    : super(message, code: 'AUTH_ERROR');
}

/// Exception de validation
class ValidationException extends AppException {
  ValidationException([String message = 'Données invalides'])
    : super(message, code: 'VALIDATION_ERROR');
}

/// Exception non trouvé (404)
class NotFoundException extends AppException {
  NotFoundException([String message = 'Ressource non trouvée'])
    : super(message, code: 'NOT_FOUND');
}

/// Exception permission refusée (403)
class PermissionException extends AppException {
  PermissionException([String message = 'Permission refusée'])
    : super(message, code: 'PERMISSION_DENIED');
}

/// Exception timeout
class TimeoutException extends AppException {
  TimeoutException([String message = 'Délai d\'attente dépassé'])
    : super(message, code: 'TIMEOUT');
}

/// Exception de cache
class CacheException extends AppException {
  CacheException([String message = 'Erreur de cache'])
    : super(message, code: 'CACHE_ERROR');
}
