# 🚀 Guide de Démarrage Rapide - Livemory Mobile

## Étapes de mise en route

### 1. Installation des dépendances

```bash
cd apps/mobile
flutter pub get
```

### 2. Génération des fichiers de code

Les modèles utilisent `json_serializable` qui nécessite la génération de fichiers `.g.dart`.

**Sur Windows:**
```powershell
.\generate.ps1
```

**Sur macOS/Linux:**
```bash
chmod +x generate.sh
./generate.sh
```

Ou manuellement:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configuration de l'API

Ouvrez `lib/config/api_config.dart` et modifiez l'URL de base:

```dart
static const String baseUrl = 'http://localhost:3000/api'; // Votre URL d'API
```

### 4. Lancement de l'application

```bash
# Sur émulateur/appareil Android
flutter run

# Sur simulateur iOS (macOS uniquement)
flutter run -d ios

# Sur navigateur Web
flutter run -d chrome

# Sur Windows
flutter run -d windows
```

## 📋 Checklist avant le premier lancement

- [ ] Flutter SDK installé et configuré
- [ ] Dépendances installées (`flutter pub get`)
- [ ] Fichiers `.g.dart` générés (`build_runner`)
- [ ] URL de l'API configurée dans `api_config.dart`
- [ ] Backend Livemory-API en cours d'exécution
- [ ] Émulateur/appareil connecté

## 🎯 Tester les fonctionnalités

### Test de création d'événement

1. Lancez l'application
2. Cliquez sur "Créer un Événement"
3. Remplissez les informations de base
4. Ajoutez des étapes avec "Ajouter une étape"
5. Cliquez sur "Créer"

### Test de l'interface complète

1. **Home Screen** : Accédez à toutes les fonctionnalités
2. **Mes Événements** : Liste de vos événements
3. **Détail Événement** : Onglets pour participants, tâches, budget, votes, médias
4. **Réductions** : Catalogue des offres exclusives

## 🔧 Résolution des problèmes courants

### Erreur "Target of URI hasn't been generated"
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erreur de compilation Gradle (Android)
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Hot reload ne fonctionne pas
Appuyez sur `R` dans le terminal pour un hot restart complet.

### Erreur de connexion API
- Vérifiez que le backend est en cours d'exécution
- Vérifiez l'URL dans `api_config.dart`
- Sur émulateur Android, utilisez `10.0.2.2` au lieu de `localhost`
- Sur émulateur iOS, utilisez `localhost` ou l'IP de votre machine

## 🌐 URLs pour émulateurs

- **Android Emulator**: `http://10.0.2.2:3000/api`
- **iOS Simulator**: `http://localhost:3000/api`
- **Appareil physique**: `http://[VOTRE_IP_LOCAL]:3000/api`

Exemple:
```dart
// Pour Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Pour iOS ou appareil physique sur le même réseau
static const String baseUrl = 'http://192.168.1.100:3000/api';
```

## 📱 Commandes utiles

```bash
# Lister les appareils disponibles
flutter devices

# Analyser le code
flutter analyze

# Formater le code
flutter format .

# Nettoyer le projet
flutter clean

# Voir les logs en temps réel
flutter logs

# Build APK pour Android
flutter build apk --release

# Build IPA pour iOS
flutter build ios --release
```

## 🎨 Personnalisation

### Changer la couleur principale
Éditez `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue, // Changez ici
),
```

### Changer le nom de l'application
Éditez `pubspec.yaml`:
```yaml
name: mobile
description: "Votre description"
```

## 📸 Fonctionnalités principales implémentées

✅ Création d'événements multi-étapes
✅ Gestion des participants avec rôles
✅ Système de tâches avec attribution
✅ Gestion de budget et partage des frais
✅ Votes pour décisions de groupe
✅ Album photos/vidéos partagé
✅ Réductions exclusives pour groupes
✅ Navigation intuitive par onglets
✅ Interface Material Design 3

## 🔜 Prochaines étapes

1. **Authentification** : Implémenter le login/signup
2. **Notifications** : Push notifications pour les événements
3. **Offline Mode** : Synchronisation des données
4. **Chat** : Messagerie de groupe intégrée
5. **Maps** : Intégration Google Maps pour les lieux

## ⚙️ Configuration avancée

### Activer le mode debug réseau
Dans `lib/services/api_service.dart`, ajoutez un intercepteur de log:
```dart
_dio.interceptors.add(LogInterceptor(
  request: true,
  requestBody: true,
  responseBody: true,
  error: true,
));
```

### Configurer les timeouts
Dans `lib/config/api_config.dart`:
```dart
static const Duration connectTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
```

## 📞 Support

En cas de problème, vérifiez :
1. La version de Flutter : `flutter --version`
2. Les logs : `flutter logs`
3. Les erreurs : `flutter analyze`
4. L'état du backend

---

**Bon développement ! 🎉**
