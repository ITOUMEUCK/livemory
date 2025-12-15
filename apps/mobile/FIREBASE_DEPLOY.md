# 🚀 Guide de Déploiement Firebase

Ce guide explique comment déployer les configurations Firebase (règles de sécurité, indexes) pour le projet Livemory.

## 📋 Prérequis

- Firebase CLI installé : `npm install -g firebase-tools`
- Projet Firebase créé (voir [FIREBASE_SETUP.md](FIREBASE_SETUP.md))
- Authentification Firebase : `firebase login`

## 🔧 Configuration Initiale

### 1. Initialiser Firebase dans le Projet

```bash
firebase init
```

Sélectionnez les options suivantes :
- ✅ Firestore
- ✅ Hosting (optionnel, pour le web)
- ✅ Storage (si vous utilisez Firebase Storage)

Fichiers générés :
- `.firebaserc` : Configuration du projet
- `firebase.json` : Configuration des services
- `firestore.rules` : Règles de sécurité ✅ (déjà créé)
- `firestore.indexes.json` : Indexes ✅ (déjà créé)

### 2. Associer le Projet Firebase

Si `firebase init` ne crée pas automatiquement `.firebaserc` :

```bash
firebase use --add
```

Sélectionnez votre projet Firebase dans la liste.

## 🗄️ Déployer Firestore

### Déployer les Règles de Sécurité

**Mode Test (Développement uniquement) :**
Les règles actuelles dans Firebase Console expirent le 31/12/2026. Pour les règles de production :

```bash
firebase deploy --only firestore:rules
```

Cela déploie le fichier `firestore.rules` qui contient :
- ✅ Authentification requise pour toutes les opérations
- ✅ Vérification des propriétaires/créateurs
- ✅ Vérification des membres de groupes
- ✅ Protection contre la suppression d'utilisateurs
- ✅ Contrôle des votes et des paiements

**Vérifier les règles déployées :**
Firebase Console → Firestore Database → Règles

### Déployer les Indexes

Les indexes sont nécessaires pour les requêtes composées (filtre + tri) :

```bash
firebase deploy --only firestore:indexes
```

**7 indexes seront créés** :
1. Groups : memberIds + createdAt
2. Events : groupId + startDate
3. Events : participantIds + startDate
4. Polls : eventId + createdAt
5. Budgets : eventId + createdAt
6. Notifications : userId + isRead + createdAt
7. Notifications : userId + createdAt

**Durée de création** : 2-5 minutes selon le volume de données.

**Vérifier les indexes :**
Firebase Console → Firestore Database → Indexes

### Déployer Firestore Complet (Règles + Indexes)

```bash
firebase deploy --only firestore
```

## 📦 Déployer Storage (Optionnel)

Si vous utilisez Firebase Storage pour les photos :

```bash
firebase deploy --only storage
```

Fichier déployé : `storage.rules` (à créer si nécessaire)

## 🌐 Déployer Hosting (Web)

Pour déployer l'application web sur Firebase Hosting :

### 1. Build de l'App Web

```bash
flutter build web --release
```

### 2. Configurer Hosting

Dans `firebase.json`, vérifiez :

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### 3. Déployer

```bash
firebase deploy --only hosting
```

Votre app sera accessible sur : `https://votre-projet.web.app`

## 🔍 Commandes Utiles

### Voir les Projets Disponibles

```bash
firebase projects:list
```

### Changer de Projet

```bash
firebase use nom-du-projet
```

### Voir la Configuration Actuelle

```bash
firebase projects:list
cat .firebaserc
```

### Déployer Tout en Une Fois

```bash
firebase deploy
```

Déploie :
- ✅ Firestore rules
- ✅ Firestore indexes
- ✅ Storage rules (si configuré)
- ✅ Hosting (si configuré)
- ✅ Functions (si configuré)

### Déploiement Ciblé

```bash
# Uniquement les règles
firebase deploy --only firestore:rules

# Uniquement les indexes
firebase deploy --only firestore:indexes

# Uniquement le hosting
firebase deploy --only hosting

# Plusieurs services
firebase deploy --only firestore,hosting
```

## 🧪 Tester Avant Déploiement

### Tester les Règles en Local

```bash
firebase emulators:start --only firestore
```

### Tester les Règles dans Firebase Console

Firebase Console → Firestore Database → Règles → **Simulateur de règles**

Testez des requêtes comme :
```
Opération: get
Chemin: /groups/group123
Auth: {uid: 'user456'}
```

## 🚨 Résolution de Problèmes

### Erreur : "Firebase not initialized"

```bash
firebase login
firebase use --add
```

### Erreur : "Permission denied"

Vérifiez que vous avez les permissions Owner ou Editor sur le projet Firebase.

### Erreur : "Index creation failed"

Supprimez les anciens indexes en conflit dans Firebase Console → Indexes.

### Les Règles ne se Déploient Pas

Vérifiez la syntaxe du fichier `firestore.rules` :
```bash
firebase deploy --only firestore:rules --debug
```

## 📊 Monitoring Après Déploiement

### Vérifier les Règles

1. Firebase Console → Firestore Database → Règles
2. Vérifiez la date de dernière publication
3. Testez avec le simulateur

### Vérifier les Indexes

1. Firebase Console → Firestore Database → Indexes
2. Statut **Activé** (vert) = Prêt ✅
3. Statut **Création** (orange) = Patientez ⏳

### Tester l'Application

1. Lancez l'app : `flutter run -d chrome`
2. Créez un groupe
3. Vérifiez que les requêtes fonctionnent sans erreur
4. Consultez les logs dans la console

## 🎯 Checklist de Déploiement

Avant de passer en production :

- [ ] Firebase CLI installé et authentifié
- [ ] Projet Firebase sélectionné (`firebase use`)
- [ ] Règles de sécurité testées (simulateur)
- [ ] Indexes créés et **activés** (verts)
- [ ] Application testée avec les nouvelles règles
- [ ] Backup des données existantes (si applicable)
- [ ] Notifications d'erreur configurées (Crashlytics)
- [ ] Budget Firebase vérifié (quotas, facturation)

## 📚 Ressources

- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firestore Indexes](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)

---

**Besoin d'aide ?** Consultez la [documentation Firebase](https://firebase.google.com/docs) ou ouvrez une issue sur GitHub.
