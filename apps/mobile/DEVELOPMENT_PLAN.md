# 🎯 Plan de Développement - Livemory Mobile

## 📋 Vue d'Ensemble

Ce document détaille le plan de développement par sprints pour le MVP de Livemory, avec une estimation de 16 semaines (4 mois) jusqu'au lancement.

---

## 🏗️ Phase 1: Fondations (Semaines 1-4)

### Sprint 1 (Semaine 1-2): Setup & Architecture

#### Objectifs
- ✅ Structure projet complete
- ✅ Configuration environnements (dev, staging, prod)
- ✅ Mise en place CI/CD
- ✅ Design system implémenté

#### Tâches Techniques

**Setup Projet**
- [ ] Nettoyer projet template Flutter
- [ ] Mettre en place architecture clean (features modulaires)
- [ ] Configurer linting strict (`analysis_options.yaml`)
- [ ] Setup Git workflow (branches, PR templates)

**Theme & Design System**
```dart
// Créer lib/core/theme/app_theme.dart
- Implémenter palette couleurs (LinkedIn Blue + WhatsApp Green)
- Définir TextThemes complets
- Créer composants de base (buttons, cards, inputs)
- Ajouter animations standards
```

**Configuration Environnements**
```dart
// Créer lib/core/config/env_config.dart
- Variables d'environnement (dev, staging, prod)
- Configuration API endpoints
- Feature flags (pour désactiver fonctionnalités en dev)
```

**CI/CD**
- [ ] GitHub Actions workflow (build, test, lint)
- [ ] Automated testing sur PR
- [ ] Configuration Fastlane (iOS/Android deployment)

#### Livrables
- ✅ Projet structuré selon ARCHITECTURE.md
- ✅ Design system fonctionnel
- ✅ Pipeline CI/CD opérationnel
- ✅ Documentation technique à jour

---

### Sprint 2 (Semaine 3-4): Authentification

#### Objectifs
- ✅ Auth email/password fonctionnelle
- ✅ Social auth (Google, Apple)
- ✅ Gestion tokens JWT
- ✅ Onboarding screens

#### Tâches Techniques

**Backend Integration**
- [ ] Setup API client (Dio) avec interceptors
- [ ] Gestion tokens (access + refresh)
- [ ] Error handling centralisé
- [ ] Network connectivity check

**Auth Feature Module**
```dart
lib/features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart     // SharedPreferences
│   │   └── auth_remote_datasource.dart    // API calls
│   ├── models/
│   │   ├── user_model.dart                // JSON serialization
│   │   └── token_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart           // Interface
│   └── usecases/
│       ├── login_usecase.dart
│       ├── register_usecase.dart
│       ├── logout_usecase.dart
│       └── social_auth_usecase.dart
└── presentation/
    ├── providers/
    │   └── auth_provider.dart             // State management
    ├── screens/
    │   ├── splash_screen.dart             // Check auth status
    │   ├── onboarding_screen.dart         // 3 slides
    │   ├── login_screen.dart
    │   └── register_screen.dart
    └── widgets/
        ├── auth_text_field.dart
        └── social_auth_buttons.dart       // Google, Apple, Email
```

**Dépendances à Ajouter**
```yaml
# pubspec.yaml
dependencies:
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.3
  firebase_auth: ^5.3.3
  flutter_secure_storage: ^9.2.2
```

**Écrans à Créer**

1. **SplashScreen**: Logo animé + vérification auth
2. **OnboardingScreen**: 3 slides (PageView + skip button)
   - Slide 1: "Organisez vos soirées en 2 minutes"
   - Slide 2: "Votes, budget, logistique en un seul endroit"
   - Slide 3: "Invitez vos amis sans friction"
3. **LoginScreen**: Email + password, social auth buttons
4. **RegisterScreen**: Nom, email, password, photo profil optionnelle

#### Livrables
- ✅ Login/Register fonctionnels
- ✅ Social auth (Google + Apple)
- ✅ Tokens sauvegardés en secure storage
- ✅ Navigation après auth (HomeScreen)
- ✅ Onboarding skippable

---

## 🏗️ Phase 2: Core Features (Semaines 5-8)

### Sprint 3 (Semaine 5-6): Groupes & Événements

#### Objectifs
- ✅ CRUD Groupes complet
- ✅ Invitations via liens magiques
- ✅ CRUD Événements avec templates
- ✅ Bottom navigation bar

#### Tâches Techniques

**Groups Feature Module**
```dart
lib/features/groups/
├── data/
│   ├── models/
│   │   ├── group_model.dart
│   │   └── member_model.dart
│   └── repositories/
│       └── group_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── group.dart
│   │   └── member.dart
│   ├── usecases/
│   │   ├── create_group_usecase.dart
│   │   ├── get_groups_usecase.dart
│   │   ├── invite_member_usecase.dart      // Generate magic link
│   │   └── join_group_usecase.dart         // Via magic link
└── presentation/
    ├── screens/
    │   ├── group_list_screen.dart
    │   ├── group_detail_screen.dart
    │   ├── group_create_screen.dart        // Wizard: nom, emoji, membres
    │   └── group_settings_screen.dart
    └── widgets/
        ├── group_card.dart                  // Card avec emoji, nom, membres
        ├── member_list_item.dart            // Avatar + nom + rôle
        └── invite_link_dialog.dart          // Share sheet
```

**Events Feature Module**
```dart
lib/features/events/
├── data/
│   ├── models/
│   │   ├── event_model.dart
│   │   ├── event_template_model.dart
│   │   └── checklist_item_model.dart
├── domain/
│   ├── entities/
│   │   ├── event.dart
│   │   ├── event_template.dart
│   │   └── checklist_item.dart
│   ├── usecases/
│   │   ├── create_event_usecase.dart
│   │   ├── get_events_usecase.dart
│   │   └── manage_checklist_usecase.dart
└── presentation/
    ├── screens/
    │   ├── event_list_screen.dart           // Cards scrollables
    │   ├── event_detail_screen.dart         // Tabs: Info, Tâches, Budget
    │   ├── event_create_screen.dart         // Step 1: Template select
    │   └── event_checklist_screen.dart
    └── widgets/
        ├── event_card.dart                   // Image, titre, date, participants
        ├── template_selector.dart            // Grid templates avec emojis
        └── checklist_item_widget.dart        // Checkbox, titre, assignee
```

**Navigation Structure**
```dart
// Bottom Navigation Bar (3 tabs)
lib/shared/widgets/navigation/bottom_nav_bar.dart

- Tab 1: 🏠 Accueil (HomeScreen)
- Tab 2: 📅 Événements (EventListScreen)
- Tab 3: 👤 Profil (ProfileScreen)

// HomeScreen: Dashboard avec cards actions rapides
- Card "Créer un groupe"
- Card "Créer un événement"
- Liste "Événements à venir" (3 prochains)
- Liste "Mes groupes actifs"
```

**Templates Événements**
```dart
// Prédéfinis dans assets ou backend
enum EventType {
  party,       // 🎉 Soirée
  trip,        // ✈️ Voyage
  restaurant,  // 🍽️ Restaurant
  home,        // 🏠 À domicile
  cultural,    // 🎭 Sortie culturelle
}

// Chaque template avec checklists par défaut
PartyTemplate:
- Tâches: Apporter boissons, snacks, playlist, jeux
- Budget estimé: 15€/personne

TripTemplate:
- Tâches: Réserver hébergement, transport, activités
- Budget estimé: 100€/personne
```

#### Dépendances à Ajouter
```yaml
dependencies:
  share_plus: ^10.1.2           # Partage liens invitations
  qr_flutter: ^4.1.0            # QR codes pour invitations
  flutter_contacts: ^1.1.9      # Import contacts (optionnel)
```

#### Livrables
- ✅ Création groupe + invitation par lien/SMS
- ✅ Rejoindre groupe via magic link
- ✅ Liste événements avec filtres
- ✅ Création événement depuis template
- ✅ Checklist partagée fonctionnelle
- ✅ Navigation bottom bar opérationnelle

---

### Sprint 4 (Semaine 7-8): Galerie Photos & Détails Événement

#### Objectifs
- ✅ Upload photos/vidéos
- ✅ Galerie événement collaborative
- ✅ Détails événement (date, lieu, description)
- ✅ Carte interactive

#### Tâches Techniques

**Media Management**
```dart
lib/features/events/presentation/widgets/
├── event_gallery_widget.dart            // Grid photos avec preview
├── photo_upload_button.dart             // Camera + gallery picker
└── photo_fullscreen_viewer.dart         // Swipe viewer avec zoom
```

**Map Integration**
```dart
lib/features/events/presentation/widgets/
└── event_map_widget.dart                // Google Maps ou Flutter Map
```

**Dépendances à Ajouter**
```yaml
dependencies:
  google_maps_flutter: ^2.9.0
  # OU flutter_map: ^7.0.2         # Alternative open-source
  geolocator: ^13.0.2              # Géolocalisation
  geocoding: ^3.0.0                # Adresse ↔ coordonnées
  permission_handler: ^11.3.1      # Permissions location/camera
```

**Écrans à Améliorer**

**EventDetailScreen (avec Tabs)**
```dart
DefaultTabController(
  length: 4,
  child: Scaffold(
    appBar: AppBar(
      title: Text(event.title),
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.info), text: "Infos"),
          Tab(icon: Icon(Icons.checklist), text: "Tâches"),
          Tab(icon: Icon(Icons.attach_money), text: "Budget"),
          Tab(icon: Icon(Icons.photo), text: "Photos"),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        _InfoTab(),        // Date, lieu, description, carte
        _ChecklistTab(),   // Liste tâches
        _BudgetTab(),      // Dépenses (Sprint 5)
        _GalleryTab(),     // Photos/vidéos
      ],
    ),
  ),
)
```

#### Livrables
- ✅ Upload photos via camera ou galerie
- ✅ Galerie collaborative (tous peuvent ajouter)
- ✅ Carte interactive avec lieu événement
- ✅ Détails complets événement (date, lieu, description)
- ✅ Partage événement (lien magique)

---

## 🗳️ Phase 3: Votes & Budget (Semaines 9-12)

### Sprint 5 (Semaine 9-10): Système de Sondages

#### Objectifs
- ✅ Création sondages (dates, lieux, activités)
- ✅ Interface de vote intuitive
- ✅ Résultats temps réel avec graphiques
- ✅ Notifications votes

#### Tâches Techniques

**Polls Feature Module**
```dart
lib/features/polls/
├── data/
│   ├── models/
│   │   ├── poll_model.dart
│   │   ├── poll_option_model.dart
│   │   └── vote_model.dart
├── domain/
│   ├── entities/
│   │   ├── poll.dart
│   │   ├── poll_option.dart
│   │   └── vote.dart
│   ├── usecases/
│   │   ├── create_poll_usecase.dart
│   │   ├── vote_usecase.dart
│   │   ├── get_poll_results_usecase.dart
│   │   └── send_poll_reminder_usecase.dart
└── presentation/
    ├── screens/
    │   ├── poll_create_screen.dart         // Step 1: Type, Step 2: Options
    │   ├── poll_vote_screen.dart           // Interface swipe ou tap
    │   └── poll_results_screen.dart        // Graphiques + stats
    └── widgets/
        ├── poll_option_card.dart            // Card option avec icon/image
        ├── poll_results_chart.dart          // Bar chart (fl_chart)
        └── availability_grid.dart           // Pour sondages dates (Doodle-like)
```

**Types de Sondages**
```dart
enum PollType {
  dates,        // Grille disponibilités style Doodle
  locations,    // Options avec carte preview
  choices,      // Options texte/images (menu, activités)
}

enum VoteType {
  yes,          // Oui
  maybe,        // Peut-être
  no,           // Non
}
```

**Écrans à Créer**

**PollCreateScreen (Wizard)**
```dart
Step 1: Sélection type (dates, lieux, choix multiple)
Step 2: Ajout options
  - Dates: Date picker multi-select
  - Lieux: Search + map preview
  - Choix: Texte libre + image optionnelle
Step 3: Paramètres
  - Deadline vote
  - Vote anonyme ou public
  - Multiple choix autorisé
```

**PollVoteScreen**
```dart
// Interface intuitive selon type
- Dates: Grille interactive (tap = toggle yes/maybe/no)
- Lieux/Choix: Cards swipeable (right = yes, left = no, up = maybe)
```

**PollResultsScreen**
```dart
// Graphiques visuels
- Bar chart (votes par option)
- Heatmap (pour dates: vert = tous dispo, rouge = personne)
- Liste participants avec leurs votes
- Bouton "Décider" (clôturer + sélectionner option gagnante)
```

#### Dépendances (déjà ajoutées)
```yaml
dependencies:
  fl_chart: ^0.69.2             # Graphiques
```

#### Livrables
- ✅ Création sondage dates/lieux/choix
- ✅ Vote avec interface intuitive
- ✅ Résultats temps réel
- ✅ Notifications nouveaux sondages
- ✅ Rappels auto retardataires (J-1 deadline)

---

### Sprint 6 (Semaine 11-12): Gestion Budget

#### Objectifs
- ✅ Ajout dépenses avec répartition
- ✅ Calcul automatique "qui doit à qui"
- ✅ Graphiques budget
- ✅ Liens paiements (Lydia, PayPal)

#### Tâches Techniques

**Budget Feature Module**
```dart
lib/features/budget/
├── data/
│   ├── models/
│   │   ├── expense_model.dart
│   │   ├── balance_model.dart
│   │   └── payment_link_model.dart
├── domain/
│   ├── entities/
│   │   ├── expense.dart
│   │   ├── balance.dart
│   │   └── payment_link.dart
│   ├── usecases/
│   │   ├── add_expense_usecase.dart
│   │   ├── calculate_balances_usecase.dart
│   │   ├── export_budget_usecase.dart
│   │   └── generate_payment_link_usecase.dart
└── presentation/
    ├── screens/
    │   ├── budget_overview_screen.dart      // Dashboard graphiques
    │   ├── expense_add_screen.dart          // Formulaire + photo ticket
    │   ├── expense_detail_screen.dart       // Détail répartition
    │   └── balance_screen.dart              // Qui doit à qui
    └── widgets/
        ├── expense_card.dart                 // Card dépense avec montant
        ├── balance_chart.dart                // Pie chart répartition
        └── payment_link_button.dart          // Lydia, PayPal, Stripe
```

**Logique Calcul Budget**
```dart
// Algorithm: Simplify debts
class BalanceCalculator {
  List<Balance> calculateBalances(List<Expense> expenses, List<Member> members) {
    // 1. Calculer total dépensé par personne
    Map<String, double> totalPaid = {};
    Map<String, double> totalOwed = {};
    
    // 2. Calculer balance nette (paid - owed)
    Map<String, double> netBalance = {};
    
    // 3. Simplifier dettes (algorithme greedy)
    List<Balance> balances = _simplifyDebts(netBalance);
    
    return balances;
  }
  
  List<Balance> _simplifyDebts(Map<String, double> netBalance) {
    // Algorithme: Match creditors avec debtors
    // Minimiser nombre de transactions
  }
}
```

**Écrans à Créer**

**BudgetOverviewScreen**
```dart
- Card "Total dépenses" (montant + participants)
- Card "Ma part" (montant personnel)
- Graphique répartition par catégorie (Pie chart)
- Graphique dépenses par personne (Bar chart)
- Liste dépenses récentes (scrollable)
- FAB "Ajouter dépense"
```

**ExpenseAddScreen**
```dart
- Photo ticket (optionnel, avec OCR si possible)
- Montant (TextField avec keyboard numérique)
- Description
- Catégorie (Dropdown: Hébergement, Repas, Transport, Activités)
- Payé par (Dropdown membres)
- Répartition:
  - Équitable (par défaut)
  - Par personne (sélection multi)
  - Pourcentages custom
- Participants concernés (si partiel)
```

**BalanceScreen**
```dart
// Simplification dettes
- Liste "Qui doit à qui"
  Ex: "Alice doit 25€ à Thomas"
      "Bob doit 15€ à Alice"
- Boutons "Marquer comme payé"
- Liens Lydia/PayPal (deep links avec montant pré-rempli)
```

**Export Budget**
```dart
// PDF/CSV export
- Génération PDF récapitulatif
- Export CSV pour Excel
- Partage par email
```

#### Dépendances à Ajouter
```yaml
dependencies:
  pdf: ^3.11.1                  # Génération PDF
  csv: ^6.0.0                   # Export CSV
  printing: ^5.13.4             # Print/share PDF
```

#### Livrables
- ✅ Ajout dépenses avec photo ticket
- ✅ Répartition équitable/custom
- ✅ Calcul automatique balances
- ✅ Graphiques budget (pie + bar charts)
- ✅ Export PDF/CSV
- ✅ Liens Lydia/PayPal pour paiements

---

## 🗺️ Phase 4: Logistique & Polish (Semaines 13-16)

### Sprint 7 (Semaine 13-14): Logistique & Transport

#### Objectifs
- ✅ Carte interactive avec itinéraires
- ✅ Suggestions transport (covoit, train)
- ✅ Suggestions hébergement/activités

#### Tâches Techniques

**Logistics Feature Module**
```dart
lib/features/logistics/
├── data/
│   ├── models/
│   │   ├── location_model.dart
│   │   ├── transport_option_model.dart
│   │   └── accommodation_model.dart
├── domain/
│   ├── entities/
│   │   ├── location.dart
│   │   ├── transport_option.dart
│   │   └── accommodation.dart
│   ├── usecases/
│   │   ├── get_directions_usecase.dart
│   │   ├── search_transport_usecase.dart
│   │   └── search_accommodations_usecase.dart
└── presentation/
    ├── screens/
    │   ├── map_screen.dart                  // Fullscreen map
    │   ├── transport_screen.dart            // Options transport groupées
    │   └── accommodation_screen.dart        // Liste hébergements
    └── widgets/
        ├── map_widget.dart                  // Embedded map avec markers
        ├── transport_option_card.dart       // Covoit, train, bus
        └── accommodation_card.dart          // Hotel/Airbnb avec price
```

**APIs Externes à Intégrer**
```dart
// Google Maps / Directions API
- Affichage itinéraires
- Calcul temps trajet
- Suggestions transport public

// Suggestions Transport (liens affiliés)
- Trainline API (trains)
- Blablacar API (covoiturage)
- Flixbus API (bus)

// Suggestions Hébergement/Activités
- Booking.com API (liens affiliés)
- Airbnb (liens deep link)
- GetYourGuide API (activités)
```

**Écrans à Créer**

**MapScreen**
```dart
- Carte fullscreen avec marker lieu événement
- Markers participants (positions si partagées)
- Bouton "Itinéraire" → Google Maps / Apple Maps
- Info sheet: Adresse, distance, temps trajet
```

**TransportScreen**
```dart
// Sections groupées
1. 🚗 Covoiturage
   - Organisation interne (qui prend qui)
   - Liens Blablacar avec dates pré-remplies

2. 🚂 Train/Bus
   - Liens Trainline avec gares départ/arrivée
   - Liens Flixbus

3. ✈️ Avion (si longue distance)
   - Liens comparateurs (Skyscanner, Google Flights)
```

**AccommodationScreen**
```dart
- Liste hébergements avec:
  - Image, nom, prix/nuit
  - Note/reviews
  - Filtres: Prix, distance, réduction groupe ≥5
- Boutons "Voir sur Booking" / "Voir sur Airbnb"
```

#### Dépendances (déjà ajoutées)
```yaml
dependencies:
  google_maps_flutter: ^2.9.0
  geolocator: ^13.0.2
  geocoding: ^3.0.0
```

#### Livrables
- ✅ Carte interactive avec lieu événement
- ✅ Itinéraires depuis position actuelle
- ✅ Organisation covoiturage
- ✅ Liens train/bus avec infos pré-remplies
- ✅ Suggestions hébergements avec filtres
- ✅ Liens activités locales

---

### Sprint 8 (Semaine 15-16): Notifications & Polish

#### Objectifs
- ✅ Push notifications configurées
- ✅ In-app notifications
- ✅ Onboarding finalisé
- ✅ Bug fixes & optimisations

#### Tâches Techniques

**Notifications Feature Module**
```dart
lib/features/notifications/
├── data/
│   ├── models/
│   │   └── notification_model.dart
│   ├── datasources/
│   │   ├── notification_local_datasource.dart
│   │   └── notification_remote_datasource.dart
├── domain/
│   ├── entities/
│   │   └── notification.dart
│   ├── usecases/
│   │   ├── get_notifications_usecase.dart
│   │   ├── mark_as_read_usecase.dart
│   │   └── update_settings_usecase.dart
└── presentation/
    ├── screens/
    │   ├── notification_center_screen.dart
    │   └── notification_settings_screen.dart
    └── widgets/
        ├── notification_card.dart
        └── notification_badge.dart          // Badge sur bottom nav
```

**Push Notifications Setup**
```dart
// Firebase Cloud Messaging
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Get FCM token
    String? token = await _fcm.getToken();
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Handle notification tap (app opened)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }
  
  void _handleMessage(RemoteMessage message) {
    // Show in-app notification
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to relevant screen
  }
}
```

**Types de Notifications**
```dart
enum NotificationType {
  invitation,          // Invitation groupe/événement
  taskAssigned,        // Tâche assignée
  pollCreated,         // Nouveau sondage
  pollReminder,        // Rappel vote (J-1)
  expenseAdded,        // Nouvelle dépense
  balanceUpdated,      // Balance modifiée
  eventReminder,       // Rappel événement (J-7, J-1, jour J)
  budgetAlert,         // Budget dépassé
  comment,             // Nouveau commentaire
  photoAdded,          // Nouvelles photos
}
```

**Écrans à Finaliser**

**NotificationCenterScreen**
```dart
- Liste notifications groupées par date
- Badge "unread" sur nouvelles
- Swipe right: Marquer lu
- Swipe left: Supprimer
- Tap: Navigation vers contexte
```

**NotificationSettingsScreen**
```dart
- Toggle par type de notification
- Fréquence (temps réel, digest quotidien)
- Plages horaires (mode nuit 22h-8h)
- Muet par groupe/événement
```

**Onboarding Amélioré**
```dart
// 3 slides + permission requests
Slide 1: "Organisez en 2 minutes"
Slide 2: "Votes, budget, logistique"
Slide 3: "Invitez sans friction"

After onboarding:
- Request notification permission
- Request location permission (optionnel)
- Import contacts (optionnel, skippable)
```

**Optimisations & Bug Fixes**
- [ ] Performance profiling (Dart DevTools)
- [ ] Optimiser images (compression, lazy loading)
- [ ] Caching API responses (Dio cache interceptor)
- [ ] Offline mode (queue sync quand reconnecté)
- [ ] Error handling uniforme
- [ ] Loading states partout
- [ ] Empty states avec illustrations
- [ ] Accessibility (screen reader, contraste)
- [ ] Dark mode (optionnel)

#### Dépendances à Ajouter
```yaml
dependencies:
  firebase_messaging: ^15.1.6
  flutter_local_notifications: ^18.0.1
  timezone: ^0.9.4                  # Pour scheduled notifications
```

#### Livrables
- ✅ Push notifications fonctionnelles
- ✅ In-app notification center
- ✅ Paramètres notifications granulaires
- ✅ Onboarding avec permissions
- ✅ Bug fixes critiques
- ✅ Optimisations performances
- ✅ Tests (unit + widget) couvrant 70%+

---

## 🚀 Phase 5: Launch (Semaine 17)

### Sprint 9 (Semaine 17): Beta Testing & Launch

#### Objectifs
- ✅ Beta testing avec 50 users
- ✅ App Store & Play Store submissions
- ✅ Landing page live
- ✅ Lancement soft

#### Tâches

**Beta Testing**
- [ ] Recruter 50 beta testers (amis, famille, réseaux)
- [ ] Distribuer via TestFlight (iOS) + Internal Testing (Android)
- [ ] Collecter feedback (Google Forms + in-app)
- [ ] Prioriser bugs critiques
- [ ] Fix bugs bloquants

**App Store Preparation**

**iOS (App Store)**
```
- Screenshots (6.5" iPhone): 5 screenshots
  1. Home dashboard
  2. Création événement
  3. Vote sondage
  4. Budget overview
  5. Galerie photos
- App icon (1024x1024)
- App Store description (FR + EN)
- Keywords optimization
- Privacy policy URL
- Support URL
- Demo video (optionnel, 30s max)
```

**Android (Play Store)**
```
- Screenshots (Phone + Tablet): 4 min
- Feature graphic (1024x500)
- Icon (512x512)
- Store listing (FR + EN)
- Content rating questionnaire
- Privacy policy URL
- Data safety form
```

**Landing Page**
```html
<!-- Simple landing page -->
Sections:
- Hero: "Organisez vos soirées en 2 minutes"
- Features: 6 cards (Groupes, Événements, Votes, Budget, Logistique, Fun)
- Screenshots: Carousel
- Download buttons: App Store + Play Store
- Footer: Contact, Privacy Policy, Terms
```

**Launch Strategy**

**Soft Launch**
- [ ] Lancer en France uniquement (iOS + Android)
- [ ] Post sur réseaux sociaux (Twitter, LinkedIn, Facebook)
- [ ] Partage dans groupes ciblés (étudiants, jeunes actifs)
- [ ] Email à beta testers avec lien store

**Monitoring**
- [ ] Setup Firebase Analytics
- [ ] Setup Crashlytics
- [ ] Dashboard métriques (MAU, DAU, retention)
- [ ] Alertes Slack pour crashes

**Support**
- [ ] Email support (contact@livemory.app)
- [ ] FAQ dans app
- [ ] Réponse feedback stores (<48h)

#### Livrables
- ✅ App live sur App Store & Play Store
- ✅ Landing page accessible
- ✅ 50+ downloads premiers jours
- ✅ Monitoring en place
- ✅ Support opérationnel

---

## 📊 Post-Launch (Semaines 18+)

### Semaine 18-20: Iteration & Improvements

**Métriques à Surveiller**
- Onboarding completion rate (target: >80%)
- Day 1 retention (target: >50%)
- Week 1 retention (target: >30%)
- Événements créés/user (target: >2/mois)
- Votes participation (target: >70%)
- Crash-free users (target: >99%)

**Roadmap Post-MVP**

**Version 1.1 (1 mois post-launch)**
- [ ] Mode sombre
- [ ] Recherche événements/groupes
- [ ] Filtres avancés
- [ ] Notifications digest (résumé quotidien)
- [ ] Statistiques personnelles (événements organisés, participations)

**Version 1.2 (2 mois post-launch)**
- [ ] Intégration calendrier (Google Calendar, Apple Calendar)
- [ ] Export iCal événements
- [ ] Playlists Spotify partagées
- [ ] Gamification (badges, leaderboard)

**Version 2.0 (6 mois post-launch)**
- [ ] Assistant IA (suggestions smart)
- [ ] Visio intégrée (planning calls)
- [ ] Marketplace partenaires (offres exclusives)
- [ ] Mode Business (événements corporatifs)

---

## 📦 Dépendances Complètes

### Dépendances Production

```yaml
dependencies:
  flutter:
    sdk: flutter

  # UI
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.4.1
  photo_view: ^0.15.0
  pull_to_refresh: ^2.0.0
  
  # State Management
  provider: ^6.1.2
  
  # Networking
  http: ^1.2.2
  dio: ^5.7.0
  connectivity_plus: ^6.1.0
  
  # JSON & Serialization
  json_annotation: ^4.9.0
  
  # Storage
  shared_preferences: ^2.3.3
  flutter_secure_storage: ^9.2.2
  sqflite: ^2.4.1
  path_provider: ^2.1.5
  
  # Media
  image_picker: ^1.1.2
  video_player: ^2.9.2
  image_cropper: ^8.0.2
  
  # Firebase
  firebase_core: ^3.10.0
  firebase_auth: ^5.3.3
  firebase_messaging: ^15.1.6
  firebase_analytics: ^11.4.0
  firebase_crashlytics: ^4.2.0
  
  # Auth
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.3
  
  # Maps & Location
  google_maps_flutter: ^2.9.0
  geolocator: ^13.0.2
  geocoding: ^3.0.0
  
  # Charts
  fl_chart: ^0.69.2
  
  # Date/Time
  intl: ^0.20.1
  flutter_datetime_picker_plus: ^2.2.0
  timezone: ^0.9.4
  
  # Utilities
  url_launcher: ^6.3.1
  share_plus: ^10.1.2
  qr_flutter: ^4.1.0
  file_picker: ^8.1.4
  permission_handler: ^11.3.1
  flutter_contacts: ^1.1.9
  package_info_plus: ^8.1.1
  device_info_plus: ^10.1.2
  
  # PDF & Export
  pdf: ^3.11.1
  csv: ^6.0.0
  printing: ^5.13.4
  
  # Notifications
  flutter_local_notifications: ^18.0.1
  
  # WebSocket (Real-time)
  socket_io_client: ^2.0.3+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Linting
  flutter_lints: ^6.0.0
  
  # Code Generation
  build_runner: ^2.4.13
  json_serializable: ^6.8.0
  
  # Testing
  mockito: ^5.4.4
  flutter_driver:
    sdk: flutter
  integration_test:
    sdk: flutter
```

---

## ✅ Checklist Lancement

### Pré-Launch

**Technique**
- [ ] Tous tests passent (unit + widget + integration)
- [ ] Pas de crashs critiques (Crashlytics)
- [ ] Performance OK (FPS >60, cold start <3s)
- [ ] Taille app <50MB
- [ ] Permissions Android/iOS déclarées
- [ ] Deep links configurés (magic links)
- [ ] API prod configurée
- [ ] Environnements séparés (dev, staging, prod)

**Design**
- [ ] Design system complet implémenté
- [ ] Tous écrans responsive (phone + tablet)
- [ ] Dark mode (optionnel MVP)
- [ ] Loading states partout
- [ ] Empty states avec illustrations
- [ ] Error states avec retry
- [ ] Animations fluides (pas de jank)

**Contenu**
- [ ] Textes finalisés (FR + EN)
- [ ] Privacy policy rédigée + publiée
- [ ] Terms of service rédigées + publiées
- [ ] FAQ (10 questions minimum)
- [ ] Tutoriel in-app (tooltips)

**Marketing**
- [ ] Landing page live
- [ ] Screenshots App Store/Play Store
- [ ] Description stores optimisée (SEO)
- [ ] App icon finalisé
- [ ] Social media accounts créés
- [ ] Email support configuré

**Légal & Sécurité**
- [ ] RGPD compliant (consentement, droit à l'oubli)
- [ ] Données chiffrées (HTTPS, secure storage)
- [ ] Tokens sécurisés (refresh + access)
- [ ] Rate limiting API
- [ ] Input validation côté serveur

### Post-Launch

**Monitoring**
- [ ] Firebase Analytics configuré
- [ ] Crashlytics opérationnel
- [ ] Dashboard métriques (Grafana/Datadog)
- [ ] Alertes crashes/erreurs (Slack)
- [ ] Logs backend consultables

**Support**
- [ ] Email support monitored
- [ ] Réponse reviews stores (<48h)
- [ ] Bug tracking (Jira/Linear)
- [ ] Process release hotfix

**Iteration**
- [ ] Feedback beta testers intégré
- [ ] Roadmap v1.1 priorisée
- [ ] Sprint planning post-launch
- [ ] A/B testing setup (optionnel)

---

## 🎯 Métriques de Succès MVP

### Onboarding
- ✅ Taux d'inscription: >30% des invités
- ✅ Temps d'onboarding: <1 minute
- ✅ Onboarding completion: >80%

### Engagement
- ✅ MAU (Monthly Active Users): 1000 en 3 mois
- ✅ DAU/MAU ratio: >30%
- ✅ Événements créés/user/mois: >2
- ✅ Temps session moyen: >5 minutes
- ✅ Participation votes: >70%

### Rétention
- ✅ Day 1: >50%
- ✅ Week 1: >30%
- ✅ Month 1: >20%

### Qualité
- ✅ Crash-free users: >99%
- ✅ App Store rating: >4.5/5
- ✅ NPS (Net Promoter Score): >50

### Business (Post-MVP)
- ✅ Liens affiliés cliqués: >100/mois
- ✅ Revenue (si commissions): >500€/mois à 6 mois

---

**Document créé le**: 15 décembre 2025  
**Version**: 1.0.0  
**Timeline**: 17 semaines (4 mois)  
**Statut**: ✅ Prêt pour développement
