/// Configuration de l'environnement de l'application
enum Environment { dev, staging, prod }

class EnvConfig {
  EnvConfig._();

  static Environment _currentEnvironment = Environment.dev;

  /// Définir l'environnement actuel
  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }

  /// Obtenir l'environnement actuel
  static Environment get currentEnvironment => _currentEnvironment;

  /// Mode debug actif ?
  static bool get isDebug => _currentEnvironment == Environment.dev;

  /// Mode production ?
  static bool get isProduction => _currentEnvironment == Environment.prod;

  // ============ API Configuration ============

  /// Base URL de l'API selon l'environnement
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.dev:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://staging-api.livemory.app';
      case Environment.prod:
        return 'https://api.livemory.app';
    }
  }

  /// URL WebSocket selon l'environnement
  static String get socketUrl {
    switch (_currentEnvironment) {
      case Environment.dev:
        return 'ws://localhost:3000';
      case Environment.staging:
        return 'wss://staging-api.livemory.app';
      case Environment.prod:
        return 'wss://api.livemory.app';
    }
  }

  // ============ Logging Configuration ============

  /// Activer les logs détaillés
  static bool get enableLogging => _currentEnvironment != Environment.prod;

  /// Activer les logs réseau (Dio)
  static bool get enableNetworkLogging =>
      _currentEnvironment == Environment.dev;

  /// Activer les logs d'erreurs
  static bool get enableErrorLogging => true;

  // ============ Analytics Configuration ============

  /// Activer Firebase Analytics
  static bool get enableAnalytics => _currentEnvironment == Environment.prod;

  /// Activer Crashlytics
  static bool get enableCrashlytics => _currentEnvironment != Environment.dev;

  // ============ Feature Flags ============

  /// Mode hors ligne activé
  static bool get enableOfflineMode => false; // TODO: v1.1

  /// Mode sombre disponible
  static bool get enableDarkMode => false; // TODO: v1.1

  /// Assistant IA activé
  static bool get enableAIAssistant => false; // TODO: v2.0

  /// Mock API (pour tests sans backend)
  static bool get useMockApi => false;

  // ============ External Services ============

  /// Google Maps API Key (à définir dans les variables d'environnement)
  static String get googleMapsApiKey {
    // TODO: Remplacer par la vraie clé via --dart-define
    return const String.fromEnvironment('GOOGLE_MAPS_KEY', defaultValue: '');
  }

  /// Firebase Config
  static String get firebaseProjectId {
    switch (_currentEnvironment) {
      case Environment.dev:
        return 'livemory-dev';
      case Environment.staging:
        return 'livemory-staging';
      case Environment.prod:
        return 'livemory-prod';
    }
  }

  // ============ Timeouts ============

  /// Timeout des requêtes API
  static Duration get apiTimeout {
    return _currentEnvironment == Environment.dev
        ? const Duration(seconds: 60) // Plus long en dev pour debug
        : const Duration(seconds: 30);
  }

  /// Timeout de connexion
  static Duration get connectTimeout => const Duration(seconds: 15);

  /// Timeout de réception
  static Duration get receiveTimeout => const Duration(seconds: 30);
}
