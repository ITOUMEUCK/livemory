# 🔥 Guide de Configuration Firebase pour Livemory

Ce guide vous accompagne dans la configuration complète de Firebase pour l'application Livemory.

## 📋 Prérequis

- Compte Google
- Node.js installé (pour Firebase CLI)
- Application Flutter fonctionnelle

## 🎯 Étape 1: Créer un Projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur **"Ajouter un projet"**
3. Nommez votre projet: `livemory` (ou un autre nom)
4. Acceptez les conditions et créez le projet
5. Désactivez Google Analytics si non nécessaire (peut être activé plus tard)

## 🌐 Étape 2: Configurer l'Application Web

### 2.1 Ajouter une Application Web

1. Dans la console Firebase, cliquez sur l'icône **Web** (`</>`)
2. Nom de l'app: `Livemory Web`
3. ✅ Cochez "Configurer Firebase Hosting"
4. Cliquez sur **"Enregistrer l'application"**

### 2.2 Récupérer les Credentials Web

Vous verrez un objet JavaScript similaire à:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "livemory-xxxxx.firebaseapp.com",
  projectId: "livemory-xxxxx",
  storageBucket: "livemory-xxxxx.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef123456",
  measurementId: "G-XXXXXXXXXX"
};
```

### 2.3 Mettre à Jour le Code Flutter

Ouvrez le fichier `lib/core/services/firebase_service.dart` et remplacez les valeurs placeholders:

```dart
FirebaseOptions _getFirebaseOptions() {
  return const FirebaseOptions(
    apiKey: "VOTRE_API_KEY_ICI",           // <- Collez apiKey
    appId: "VOTRE_APP_ID_ICI",             // <- Collez appId
    messagingSenderId: "VOTRE_SENDER_ID",  // <- Collez messagingSenderId
    projectId: "VOTRE_PROJECT_ID",         // <- Collez projectId
    authDomain: "VOTRE_AUTH_DOMAIN",       // <- Collez authDomain
    storageBucket: "VOTRE_STORAGE_BUCKET", // <- Collez storageBucket
    measurementId: "VOTRE_MEASUREMENT_ID", // <- Collez measurementId (optionnel)
  );
}
```

## 📱 Étape 3: Configurer l'Application Android

### 3.1 Ajouter une Application Android

1. Dans Firebase Console, cliquez sur l'icône **Android**
2. **Nom du package Android**: `com.example.mobile` (ou votre package name dans `android/app/build.gradle.kts`)
3. **Nickname**: `Livemory Android`
4. Cliquez sur **"Enregistrer l'application"**

### 3.2 Télécharger google-services.json

1. Téléchargez le fichier `google-services.json`
2. Placez-le dans: `android/app/google-services.json`

### 3.3 Configurer Gradle

Le fichier `android/app/build.gradle.kts` doit déjà contenir:

```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // <- Ajoutez cette ligne
    // ...
}
```

Et dans `android/build.gradle.kts`:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

## 🍎 Étape 4: Configurer l'Application iOS

### 4.1 Ajouter une Application iOS

1. Dans Firebase Console, cliquez sur l'icône **iOS**
2. **Bundle ID**: Trouvez-le dans `ios/Runner.xcodeproj/project.pbxproj` (ex: `com.example.mobile`)
3. **Nickname**: `Livemory iOS`
4. Cliquez sur **"Enregistrer l'application"**

### 4.2 Télécharger GoogleService-Info.plist

1. Téléchargez le fichier `GoogleService-Info.plist`
2. Ouvrez Xcode: `open ios/Runner.xcworkspace`
3. Glissez `GoogleService-Info.plist` dans le dossier `Runner/` dans Xcode
4. ✅ Cochez "Copy items if needed"
5. ✅ Target: `Runner`

## 🔐 Étape 5: Activer l'Authentification

### 5.1 Activer Email/Password

1. Dans Firebase Console → **Authentication** → **Sign-in method**
2. Cliquez sur **"Email/Password"**
3. ✅ Activez **"Email/Password"**
4. Cliquez sur **"Enregistrer"**

### 5.2 Activer Google Sign-In

1. Dans **Sign-in method**, cliquez sur **"Google"**
2. ✅ Activez Google Sign-In
3. **Email d'assistance du projet**: Votre email
4. Cliquez sur **"Enregistrer"**

### 5.3 Configurer OAuth pour Google (Important!)

#### Pour Web:

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionnez votre projet Firebase
3. **APIs & Services** → **Credentials**
4. Trouvez "Web client (auto created by Google Service)"
5. Ajoutez ces **Authorized redirect URIs**:
   ```
   http://localhost
   https://votre-projet.firebaseapp.com/__/auth/handler
   ```

#### Pour Android:

1. Obtenez votre **SHA-1**:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copiez le SHA-1 de la variante `debug`
3. Dans Firebase Console → **Project Settings** → **Your apps** → Android
4. Ajoutez le SHA-1

#### Pour iOS:

1. Dans Firebase Console → **Project Settings** → **Your apps** → iOS
2. Téléchargez à nouveau `GoogleService-Info.plist` si nécessaire
3. Le `REVERSED_CLIENT_ID` sera utilisé automatiquement

## 🗄️ Étape 6: Créer la Base de Données Firestore

### 6.1 Créer Firestore

1. Firebase Console → **Firestore Database**
2. Cliquez sur **"Créer une base de données"**
3. **Mode de démarrage**: Choisissez **"Mode test"** (pour le développement)
4. **Emplacement**: Choisissez le plus proche (ex: `europe-west1`)
5. Cliquez sur **"Activer"**

### 6.2 Règles de Sécurité (Mode Test - Temporaire)

Les règles de test permettent l'accès pendant 30 jours:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2024, 12, 31);
    }
  }
}
```

### 6.3 Règles de Production (À configurer avant le déploiement!)

Remplacez par ces règles sécurisées:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isOwner(userId);
    }
    
    // Groups collection
    match /groups/{groupId} {
      allow read: if isSignedIn() && 
        request.auth.uid in resource.data.memberIds;
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && 
        request.auth.uid == resource.data.createdBy;
    }
    
    // Events collection
    match /events/{eventId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && 
        request.auth.uid == resource.data.createdBy;
    }
    
    // Polls collection
    match /polls/{pollId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && 
        request.auth.uid == resource.data.createdBy;
    }
    
    // Budgets collection
    match /budgets/{budgetId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn();
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if isSignedIn() && 
        request.auth.uid == resource.data.userId;
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## 📦 Étape 7: Configurer Firebase Storage

### 7.1 Activer Storage

1. Firebase Console → **Storage**
2. Cliquez sur **"Commencer"**
3. Acceptez les règles par défaut
4. Choisissez le même emplacement que Firestore
5. Cliquez sur **"Terminé"**

### 7.2 Règles de Sécurité Storage

Mode test (temporaire):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.time < timestamp.date(2024, 12, 31);
    }
  }
}
```

Mode production:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Profile photos
    match /users/{userId}/profile/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId 
        && request.resource.size < 5 * 1024 * 1024  // 5MB max
        && request.resource.contentType.matches('image/.*');
    }
    
    // Event photos
    match /events/{eventId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && request.resource.size < 10 * 1024 * 1024  // 10MB max
        && request.resource.contentType.matches('image/.*');
    }
    
    // Group photos
    match /groups/{groupId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## 🔔 Étape 8: Configurer Firebase Cloud Messaging (Notifications Push)

### 8.1 Pour Web

1. Firebase Console → **Project Settings** → **Cloud Messaging**
2. Sous **Web configuration**, cliquez sur **"Générer une paire de clés"**
3. Copiez le **Jeton de serveur**
4. Utilisez-le dans votre code web

### 8.2 Pour Android

Déjà configuré avec `google-services.json`!

### 8.3 Pour iOS

1. Téléchargez le certificat APNs depuis Apple Developer
2. Uploadez-le dans **Project Settings** → **Cloud Messaging** → **APNs Certificates**

## 🧪 Étape 9: Tester la Configuration

### 9.1 Installer les Dépendances

```bash
flutter pub get
```

### 9.2 Lancer l'Application

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

### 9.3 Vérifier l'Initialisation

Dans la console, vous devriez voir:

```
✅ Firebase initialisé avec succès
```

### 9.4 Tester l'Authentification

1. Créez un compte avec email/password
2. Vérifiez dans **Firebase Console → Authentication → Users** que l'utilisateur apparaît
3. Vérifiez dans **Firestore → users** que le document utilisateur est créé

## 🔍 Résolution de Problèmes

### ❌ Erreur: "Firebase not initialized"

- Vérifiez que vous avez bien remplacé les placeholders dans `firebase_service.dart`
- Vérifiez que `google-services.json` est dans `android/app/`
- Vérifiez que `GoogleService-Info.plist` est dans `ios/Runner/`

### ❌ Erreur: "Google Sign-In failed"

- Vérifiez les SHA-1 pour Android
- Vérifiez les Authorized redirect URIs pour Web
- Vérifiez que Google Sign-In est activé dans Firebase Console

### ❌ Erreur: "Permission denied" sur Firestore

- Vérifiez les règles de sécurité Firestore
- Assurez-vous que l'utilisateur est authentifié
- Vérifiez que les champs requis sont présents dans les documents

### 🐛 Debug Mode

Pour voir les logs Firebase détaillés:

```dart
// Dans main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mode debug Firebase
  await Firebase.initializeApp();
  FirebaseFirestore.setLoggingEnabled(true);
  
  runApp(const LivemoryApp());
}
```

## 📚 Ressources Utiles

- [Documentation Flutter + Firebase](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Storage](https://firebase.google.com/docs/storage)

## 🎉 Félicitations!

Votre application Livemory est maintenant connectée à Firebase! 🔥

Prochaines étapes:
1. ✅ Testez l'authentification
2. ✅ Créez vos premiers groupes/événements
3. ✅ Passez en mode production avec les règles de sécurité
4. ✅ Configurez les notifications push
5. ✅ Déployez sur le Play Store / App Store

---

**Questions?** Consultez la documentation ou ouvrez une issue sur GitHub.
