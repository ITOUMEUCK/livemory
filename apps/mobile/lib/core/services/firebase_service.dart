import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Service Firebase central
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  FirebaseService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialiser Firebase
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Configuration Firebase par plateforme
      await Firebase.initializeApp(options: _getFirebaseOptions());

      _initialized = true;
      debugPrint('✅ Firebase initialisé avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation Firebase: $e');
      rethrow;
    }
  }

  /// Options Firebase selon la plateforme
  FirebaseOptions? _getFirebaseOptions() {
    if (kIsWeb) {
      // Configuration Web
      // TODO: Remplacer par vos propres valeurs depuis Firebase Console
      return const FirebaseOptions(
        apiKey: 'AIzaSyBDwf_YWTNJ1ysX4auvOCPeevJTr8qUjc0',
        appId: '1:466303645510:web:ea9fee133401be55e81747',
        messagingSenderId: '466303645510',
        projectId: 'livemory-22510',
        authDomain: 'livemory-22510.firebaseapp.com',
        storageBucket: 'livemory-22510.firebasestorage.app',
        measurementId: 'G-6G1CBZXVFL',
      );
    }

    // Pour Android et iOS, les fichiers de config seront utilisés automatiquement
    // (google-services.json et GoogleService-Info.plist)
    return null;
  }

  /// Vérifier si Firebase est configuré
  bool isConfigured() {
    if (kIsWeb) {
      // Vérifier si les clés web sont configurées
      final options = _getFirebaseOptions();
      return options?.apiKey != 'YOUR_WEB_API_KEY';
    }
    return true; // Supposer que les fichiers de config mobiles sont présents
  }
}
