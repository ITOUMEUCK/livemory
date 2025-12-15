import 'package:equatable/equatable.dart';

/// Classe de base pour les failures (erreurs métier)
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure serveur
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Erreur serveur']) : super(message);
}

/// Failure réseau
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Pas de connexion Internet'])
    : super(message);
}

/// Failure cache
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Erreur de cache']) : super(message);
}

/// Failure validation
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Données invalides'])
    : super(message);
}

/// Failure authentification
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Erreur d\'authentification'])
    : super(message);
}

/// Failure permission
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission refusée'])
    : super(message);
}

/// Failure non trouvé
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Ressource non trouvée'])
    : super(message);
}

/// Failure timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'Délai d\'attente dépassé'])
    : super(message);
}
