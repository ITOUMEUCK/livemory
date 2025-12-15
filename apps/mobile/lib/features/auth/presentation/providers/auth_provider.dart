import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';
import '../../../../core/services/auth_service.dart';

/// Provider pour gérer l'état d'authentification
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      _currentUser != null && _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  /// Initialiser l'écoute des changements d'authentification
  void initAuthListener() {
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((
      firebaseUser,
    ) {
      if (firebaseUser == null) {
        _currentUser = null;
        _setStatus(AuthStatus.unauthenticated);
      } else {
        // L'utilisateur sera chargé depuis Firestore via checkAuthStatus
        checkAuthStatus();
      }
    });
  }

  /// Connexion avec email et mot de passe
  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setStatus(AuthStatus.loading);

      final user = await _authService.signInWithEmail(email, password);
      _currentUser = user;

      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Inscription avec email et mot de passe
  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setStatus(AuthStatus.loading);

      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      _currentUser = user;

      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Connexion avec Google
  Future<bool> signInWithGoogle() async {
    try {
      _setStatus(AuthStatus.loading);

      final user = await _authService.signInWithGoogle();
      _currentUser = user;

      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Connexion avec Apple
  Future<bool> signInWithApple() async {
    try {
      _setStatus(AuthStatus.loading);

      // TODO: Implémenter l'authentification Apple
      await Future.delayed(const Duration(seconds: 2));

      _currentUser = User(
        id: 'apple_user_123',
        email: 'user@icloud.com',
        name: 'Utilisateur Apple',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isEmailVerified: true,
      );

      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _setError('Erreur connexion Apple: ${e.toString()}');
      return false;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      _setStatus(AuthStatus.loading);

      await _authService.signOut();
      _currentUser = null;

      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _setError('Erreur de déconnexion: ${e.toString()}');
    }
  }

  /// Vérifier si l'utilisateur est déjà connecté (au démarrage)
  Future<void> checkAuthStatus() async {
    try {
      _setStatus(AuthStatus.loading);

      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // Charger les données utilisateur depuis Firestore
        final user = await _authService.getUserFromFirestore(firebaseUser.uid);
        _currentUser = user;
        _setStatus(AuthStatus.authenticated);
      } else {
        _currentUser = null;
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _setError('Erreur vérification auth: ${e.toString()}');
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// Mettre à jour le profil utilisateur
  Future<bool> updateProfile({
    String? name,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    if (_currentUser == null) return false;

    try {
      _setStatus(AuthStatus.loading);

      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
      );

      await _authService.updateProfile(
        userId: _currentUser!.id,
        user: updatedUser,
      );
      _currentUser = updatedUser;

      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _setError('Erreur mise à jour profil: ${e.toString()}');
      return false;
    }
  }

  /// Réinitialiser le mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      _setStatus(AuthStatus.loading);

      await _authService.resetPassword(email);

      _setStatus(AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Méthodes privées

  void _setStatus(AuthStatus status) {
    _status = status;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = AuthStatus.error;
    notifyListeners();
  }

  /// Nettoyer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Statuts d'authentification
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }
