import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/config/env_config.dart';
import 'core/services/firebase_service.dart';
import 'app.dart';

void main() async {
  // S'assurer que les bindings Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  try {
    await FirebaseService.instance.initialize();
    debugPrint('✅ Firebase initialisé avec succès');
  } catch (e) {
    debugPrint('❌ Erreur initialisation Firebase: $e');
    // L'app peut quand même démarrer sans Firebase pour le développement
  }

  // Initialiser les locales françaises pour les dates
  await initializeDateFormatting('fr_FR', null);

  // Configuration de l'environnement (dev par défaut)
  EnvConfig.setEnvironment(Environment.dev);

  runApp(const LivemoryApp());
}
