import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/domain/entities/user.dart' as app_user;

/// Service d'authentification Firebase
class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Utilisateur Firebase actuel
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  /// Stream de l'état d'authentification
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Connexion avec email et mot de passe
  Future<app_user.User> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Erreur de connexion');
      }

      // Récupérer les données utilisateur depuis Firestore
      return await _getUserFromFirestore(userCredential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Inscription avec email et mot de passe
  Future<app_user.User> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Erreur lors de la création du compte');
      }

      // Créer le document utilisateur dans Firestore
      final user = app_user.User(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        isEmailVerified: false,
        role: app_user.UserRole.user,
      );

      await _createUserInFirestore(user);

      // Envoyer l'email de vérification
      await userCredential.user!.sendEmailVerification();

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Connexion avec Google
  Future<app_user.User> signInWithGoogle() async {
    try {
      // Déclencher le flux d'authentification Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Connexion Google annulée');
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer les credentials Firebase
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Se connecter à Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Erreur de connexion Google');
      }

      // Vérifier si l'utilisateur existe déjà dans Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return await _getUserFromFirestore(userCredential.user!.uid);
      } else {
        // Créer un nouveau document utilisateur
        final user = app_user.User(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: userCredential.user!.displayName ?? 'Utilisateur',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          isEmailVerified: true,
          role: app_user.UserRole.user,
        );

        await _createUserInFirestore(user);
        return user;
      }
    } catch (e) {
      throw Exception('Erreur lors de la connexion Google: $e');
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  /// Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Mettre à jour le profil utilisateur
  Future<void> updateProfile({
    required String userId,
    required app_user.User user,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'name': user.name,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'phoneNumber': user.phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Récupérer un utilisateur depuis Firestore
  Future<app_user.User> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception('Utilisateur introuvable');
    }

    final data = doc.data()!;
    return app_user.User(
      id: doc.id,
      email: data['email'] as String,
      name: data['name'] as String,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      role: app_user.UserRole.values.firstWhere(
        (role) => role.toString() == 'UserRole.${data['role']}',
        orElse: () => app_user.UserRole.user,
      ),
    );
  }

  /// Récupérer un utilisateur depuis Firestore (méthode publique pour AuthProvider)
  Future<app_user.User> getUserFromFirestore(String uid) async {
    return await _getUserFromFirestore(uid);
  }

  /// Créer un utilisateur dans Firestore
  Future<void> _createUserInFirestore(app_user.User user) async {
    await _firestore.collection('users').doc(user.id).set({
      'email': user.email,
      'name': user.name,
      'photoUrl': user.photoUrl,
      'phoneNumber': user.phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'isEmailVerified': user.isEmailVerified,
      'role': user.role.toString().split('.').last,
    });
  }

  /// Gérer les exceptions Firebase Auth
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Email invalide';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      default:
        return 'Erreur d\'authentification: ${e.message}';
    }
  }
}
