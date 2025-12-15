# Livemory Mobile - Application Flutter

Application mobile Flutter complète pour gérer des événements de groupe avec fonctionnalités avancées.

## 🚀 Fonctionnalités

### ✅ Gestion d'événements
- **Création d'événements multi-étapes** : Week-end, soirées, city trips, vacances
- Définition de dates, lieux et descriptions pour chaque étape
- Couverture photo personnalisée
- Statuts d'événements (brouillon, actif, terminé, annulé)

### 👥 Gestion des participants
- Ajout de participants à l'événement ou à des étapes spécifiques
- Rôles différenciés : Organisateur, Admin, Membre
- Système d'invitations avec acceptation
- Gestion des droits d'accès

### ✔️ Système de tâches
- Création et attribution de tâches
- Suivi de l'avancement (À faire, En cours, Terminé)
- Priorités (Basse, Moyenne, Haute)
- Dates d'échéance
- Vue organisée par statut

### 💰 Gestion de budget et paiements
- Définition d'un budget total
- Ajout de dépenses par catégorie (Transport, Nourriture, Hébergement, Activités)
- Partage automatique des frais entre participants
- Graphique de répartition des dépenses
- Suivi des paiements entre participants
- Upload de reçus

### 🗳️ Système de votes
- Création de votes pour choisir lieux, horaires ou activités
- Options multiples avec images
- Votes simples ou multiples
- Résultats en temps réel avec pourcentages
- Votes anonymes possibles
- Clôture automatique ou manuelle

### 🎁 Réductions exclusives
- Catalogue de réductions pour groupes
- Filtrage par catégorie (Restaurants, Hôtels, Activités, Transport)
- Codes promo
- Liens directs vers sites de réservation
- Conditions de groupe (nombre minimum de participants)

### 📸 Album photos/vidéos
- Upload de photos et vidéos
- Galerie interactive avec zoom
- Système de likes
- Tag des participants
- Légendes et descriptions
- Partage direct

## 🏗️ Architecture

```
lib/
├── config/           # Configuration (API endpoints)
├── models/          # Modèles de données
│   ├── event.dart
│   ├── participant.dart
│   ├── task.dart
│   ├── budget.dart
│   ├── vote.dart
│   ├── deal.dart
│   ├── media.dart
│   └── user.dart
├── services/        # Services API
│   ├── api_service.dart
│   ├── event_service.dart
│   ├── participant_service.dart
│   ├── task_service.dart
│   ├── budget_service.dart
│   ├── vote_service.dart
│   ├── deal_service.dart
│   └── media_service.dart
├── providers/       # State management (Provider)
│   └── event_provider.dart
├── screens/         # Écrans de l'application
│   ├── home_screen.dart
│   ├── event_list_screen.dart
│   ├── event_detail_screen.dart
│   ├── create_event_screen.dart
│   ├── participants_tab.dart
│   ├── tasks_tab.dart
│   ├── budget_tab.dart
│   ├── votes_tab.dart
│   ├── media_tab.dart
│   └── deals_screen.dart
└── main.dart        # Point d'entrée
```

## 📦 Dépendances principales

- **provider** : Gestion d'état
- **dio** : Client HTTP
- **json_annotation** : Sérialisation JSON
- **image_picker** : Sélection de photos/vidéos
- **video_player** : Lecture de vidéos
- **photo_view** : Visionneuse d'images avec zoom
- **fl_chart** : Graphiques pour le budget
- **flutter_datetime_picker_plus** : Sélecteur de dates
- **url_launcher** : Ouverture de liens externes
- **shared_preferences** : Stockage local
- **cached_network_image** : Cache d'images

## 🚀 Installation

1. **Prérequis**
   ```bash
   Flutter SDK ^3.10.4
   Dart SDK
   Android Studio / Xcode
   ```

2. **Installation des dépendances**
   ```bash
   cd apps/mobile
   flutter pub get
   ```

3. **Configuration de l'API**
   
   Modifiez `lib/config/api_config.dart` pour pointer vers votre backend :
   ```dart
   static const String baseUrl = 'https://votre-api.com/api';
   ```

4. **Génération du code**
   ```bash
   flutter pub run build_runner build
   ```

5. **Lancement de l'application**
   ```bash
   # Android
   flutter run

   # iOS
   flutter run -d ios

   # Web
   flutter run -d chrome

   # Windows
   flutter run -d windows
   ```

## 🔧 Configuration Backend

L'application s'attend à ce que le backend expose les endpoints suivants :

### Événements
- `GET /api/events` - Liste des événements
- `POST /api/events` - Créer un événement
- `GET /api/events/:id` - Détails d'un événement
- `PUT /api/events/:id` - Modifier un événement
- `DELETE /api/events/:id` - Supprimer un événement

### Participants
- `GET /api/events/:eventId/participants` - Liste des participants
- `POST /api/events/:eventId/participants` - Ajouter un participant
- `PATCH /api/events/:eventId/participants/:id` - Modifier un participant
- `DELETE /api/events/:eventId/participants/:id` - Retirer un participant

### Tâches
- `GET /api/events/:eventId/tasks` - Liste des tâches
- `POST /api/events/:eventId/tasks` - Créer une tâche
- `PUT /api/events/:eventId/tasks/:id` - Modifier une tâche
- `DELETE /api/events/:eventId/tasks/:id` - Supprimer une tâche

### Budget
- `GET /api/events/:eventId/budget` - Budget de l'événement
- `POST /api/events/:eventId/budget/expenses` - Ajouter une dépense
- `POST /api/events/:eventId/budget/payments` - Enregistrer un paiement

### Votes
- `GET /api/events/:eventId/votes` - Liste des votes
- `POST /api/events/:eventId/votes` - Créer un vote
- `POST /api/events/:eventId/votes/:id/cast` - Voter

### Médias
- `GET /api/events/:eventId/media` - Liste des médias
- `POST /api/events/:eventId/media` - Upload de média
- `POST /api/events/:eventId/media/:id/like` - Liker un média

### Réductions
- `GET /api/deals` - Liste des réductions
- `POST /api/deals/:id/claim` - Réclamer une réduction

## 🎨 Personnalisation du thème

Le thème peut être modifié dans `lib/main.dart` :

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple, // Changez cette couleur
    brightness: Brightness.light,
  ),
  useMaterial3: true,
),
```

## 📱 Plateformes supportées

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔐 Authentification

Pour implémenter l'authentification :

1. Ajoutez un service d'authentification dans `lib/services/auth_service.dart`
2. Stockez le token JWT dans `SharedPreferences`
3. Utilisez `ApiService.setAuthToken()` pour configurer le token
4. Ajoutez un écran de connexion/inscription

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test
```

## 📝 TODO

- [ ] Implémenter l'authentification complète
- [ ] Ajouter la synchronisation offline
- [ ] Notifications push
- [ ] Chat de groupe intégré
- [ ] Export PDF des événements
- [ ] Partage d'événements par lien
- [ ] Intégration Google Maps pour les lieux
- [ ] Traductions multilingues

## 🤝 Contribution

1. Fork le projet
2. Créez votre branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet fait partie de Livemory.

## 📧 Contact

Pour toute question, contactez l'équipe de développement Livemory.
