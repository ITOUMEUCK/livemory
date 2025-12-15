# 🎯 Spécification Produit - Livemory

## Vision Produit

**Livemory** est une application mobile-first, ludique et intuitive conçue pour orchestrer des week-ends et soirées entre amis en quelques taps. L'objectif est de rendre l'organisation d'événements sociaux simple, amusante et sans friction.

### Valeurs Clés
- ⚡ **Ultra rapide**: Organisation d'un événement en moins de 2 minutes
- 🎨 **Fun & convivial**: Design coloré, emojis, gamification
- 📱 **Mobile-first**: Expérience tactile optimale, actions swipe
- 🚀 **Friction minimale**: Participation sans inscription obligatoire

---

## 🎯 Public Cible

### Utilisateur Principal
- **Âge**: 20-35 ans
- **Comportement**: Actif socialement, organise ou participe à des événements avec amis
- **Pain points**: Applications trop complexes, coordination difficile, suivi budget fastidieux
- **Attentes**: Simplicité, rapidité, design moderne

### Personas

#### Alice - L'Organisatrice
- 28 ans, organise souvent des soirées
- Veut un outil simple pour gérer invitations et tâches
- Besoin: Visibilité sur qui apporte quoi, suivi budget

#### Thomas - Le Participant Occasionnel  
- 24 ans, participe sans forcément organiser
- Ne veut pas installer 10 apps différentes
- Besoin: Accès rapide via lien, notifications claires

---

## 📋 Fonctionnalités par Module

### 1. 👥 Groupes & Rôles

#### User Stories
- **En tant qu'organisateur**, je veux créer un groupe rapidement pour inviter mes amis
- **En tant qu'utilisateur**, je veux rejoindre un groupe via un simple lien
- **En tant qu'organisateur**, je veux définir des permissions pour contrôler qui peut modifier l'événement

#### Fonctionnalités
- ✅ Création de groupe en 30 secondes max
- ✅ Génération de lien d'invitation "magique" (pas d'inscription requise)
- ✅ Invitations via SMS, email, WhatsApp
- ✅ Système de rôles:
  - **Organisateur** (créateur + organisateurs désignés): peut tout modifier
  - **Co-organisateur**: peut modifier agenda, budget, tâches
  - **Participant**: peut voter, ajouter des photos, commenter
  - **Invité** (non inscrit): accès lecture + vote limité

#### Écrans
- `GroupCreateScreen`: Formulaire simple (nom, emoji, description)
- `GroupDetailScreen`: Liste membres avec rôles, bouton inviter
- `GroupSettingsScreen`: Gestion permissions, transfert propriété

---

### 2. 📅 Événements

#### User Stories
- **En tant qu'organisateur**, je veux créer un événement à partir d'un template pour gagner du temps
- **En tant qu'utilisateur**, je veux voir d'un coup d'œil toutes les infos importantes (date, lieu, participants)
- **En tant que participant**, je veux savoir ce que je dois apporter

#### Fonctionnalités
- ✅ **Templates pré-configurés**:
  - 🎉 Soirée (jeux, apéro, dîner...)
  - ✈️ Voyage (week-end, vacances...)
  - 🍽️ Restaurant (réservation groupe)
  - 🏠 Événement à domicile
  - 🎭 Sortie culturelle (ciné, concert...)

- ✅ **Informations événement**:
  - Titre & emoji personnalisé
  - Date(s) et horaires
  - Lieu avec carte interactive
  - Description illustrée (markdown léger)
  - Galerie photos/vidéos collaborative
  - Nombre participants (confirmés/en attente)

- ✅ **Checklists partagées** ("Qui apporte quoi"):
  - Ajout items par tous
  - Attribution d'items à un participant
  - Statut: À faire / En cours / Fait
  - Notifications quand item attribué

#### Écrans
- `EventListScreen`: Liste cards avec image, date, participants
- `EventCreateScreen`: Sélection template → Formulaire
- `EventDetailScreen`: Tabs (Infos, Tâches, Budget, Votes, Photos)
- `EventChecklistScreen`: Liste items avec assignation

---

### 3. 🗳️ Votes & Sondages

#### User Stories
- **En tant qu'organisateur**, je veux créer un sondage Doodle-like pour choisir une date
- **En tant que participant**, je veux voter rapidement depuis les notifications
- **En tant qu'organisateur**, je veux voir les résultats en temps réel

#### Fonctionnalités
- ✅ **Types de sondages**:
  - 📅 Disponibilités dates (multi-dates, plages horaires)
  - 📍 Choix de lieu (avec prévisualisation carte)
  - 🍽️ Choix de menu/restaurant
  - 🎯 Choix d'activités
  - ❓ Sondage personnalisé (texte libre)

- ✅ **Fonctionnalités avancées**:
  - Vote "Oui / Peut-être / Non" (style Doodle)
  - Commentaires sur options
  - Deadline de vote avec rappels automatiques
  - Statistiques visuelles (graphiques, pourcentages)
  - Auto-clôture quand majorité atteinte
  - Notifications push aux retardataires (J-1, 3h avant deadline)

- ✅ **Visualisation résultats**:
  - Vue calendrier pour dates (heatmap)
  - Classement options par popularité
  - Export résultats (PDF/image)

#### Écrans
- `PollCreateScreen`: Type → Options → Paramètres
- `PollVoteScreen`: Interface de vote intuitive (swipe, tap)
- `PollResultsScreen`: Graphiques et statistiques

---

### 4. 💰 Budget & Paiements

#### User Stories
- **En tant qu'organisateur**, je veux suivre les dépenses en temps réel
- **En tant que participant**, je veux savoir combien je dois et à qui
- **En tant qu'utilisateur**, je veux un calcul automatique équitable des parts

#### Fonctionnalités
- ✅ **Gestion dépenses**:
  - Ajout dépense avec photo ticket (OCR optionnel)
  - Catégorisation (hébergement, repas, transport, activités...)
  - Attribution à un payeur
  - Répartition: équitable, par personne, pourcentages custom
  - Tags participants concernés (si partiel)

- ✅ **Calcul automatique**:
  - Total par personne
  - "Qui doit combien à qui" (simplification dettes)
  - Graphiques répartition des coûts
  - Alertes "budget dépassé" si limite définie

- ✅ **Cagnotte commune**:
  - Objectif de collecte
  - Progression temps réel
  - Lien intégration Lydia, PayPal, Stripe
  - Historique des contributions

- ✅ **Export & Partage**:
  - Export PDF/CSV détaillé
  - Partage récapitulatif par email
  - Archive budget post-événement

#### Écrans
- `BudgetOverviewScreen`: Dashboard avec graphiques
- `ExpenseAddScreen`: Formulaire ajout dépense
- `ExpenseDetailScreen`: Détail avec répartition
- `BalanceScreen`: "Qui doit à qui" simplifié
- `PaymentLinksScreen`: Liens Lydia/PayPal

---

### 5. 🗺️ Logistique & Transport

#### User Stories
- **En tant qu'organisateur**, je veux partager l'adresse facilement sur une carte
- **En tant que participant**, je veux des suggestions de transport
- **En tant qu'utilisateur**, je veux trouver des activités/hébergements avec réducs groupe

#### Fonctionnalités
- ✅ **Carte interactive**:
  - Affichage lieu événement
  - Itinéraire depuis position actuelle
  - Intégration Google Maps / Apple Maps
  - Partage coordonnées GPS

- ✅ **Suggestions transport**:
  - 🚗 Covoiturage: Organisation auto (qui prend qui)
  - 🚂 Train: Liens SNCF/Trainline avec dates pré-remplies
  - 🚌 Bus/Car: Suggestions Blablacar, Flixbus
  - ✈️ Vols: Si voyage longue distance

- ✅ **Hébergement & Activités**:
  - Suggestions Airbnb, Booking (liens affiliés)
  - Filtres "Réduction groupe ≥5 personnes"
  - Activités locales (Musement, GetYourGuide)
  - Comparateur de prix
  - Sauvegarde favoris partagés

#### Écrans
- `MapScreen`: Carte avec lieu + participants
- `TransportScreen`: Options transport organisées
- `AccommodationScreen`: Liste hébergements avec filtres
- `ActivitiesScreen`: Suggestions activités locales

---

### 6. 🔔 Notifications

#### User Stories
- **En tant qu'utilisateur**, je veux être notifié des changements importants
- **En tant qu'organisateur**, je veux rappeler les participants en temps voulu
- **En tant que participant**, je ne veux pas être spammé

#### Fonctionnalités
- ✅ **Types de notifications**:
  - 📨 Invitation à rejoindre groupe/événement
  - ✅ Nouvelle tâche assignée
  - 🗳️ Nouveau sondage / Rappel vote
  - 💰 Dépense ajoutée / Balance mise à jour
  - 📅 Rappels événement (J-7, J-1, jour J)
  - ⚠️ Alerte "budget dépassé"
  - 💬 Nouveau commentaire/message
  - 📸 Nouvelles photos ajoutées

- ✅ **Canaux**:
  - Push notifications (priorité)
  - Email (récapitulatifs, urgences)
  - SMS (invitations non-inscrits)
  - In-app (feed activités)

- ✅ **Paramètres granulaires**:
  - Activer/désactiver par type
  - Fréquence (temps réel, digest quotidien)
  - Plages horaires (mode nuit)
  - Muet par groupe/événement

#### Écrans
- `NotificationCenterScreen`: Liste notifications groupées
- `NotificationSettingsScreen`: Préférences détaillées

---

## 🎮 Différenciation & UX Unique

### 1. ⚡ Ultra Rapide

#### Flux Guidé en 3 Étapes
1. **Créer groupe** (30s): Nom, emoji, inviter via lien
2. **Créer événement** (1min): Template → Date/Lieu → Go
3. **Organiser** (ongoing): Tâches, votes, budget en parallèle

#### Suggestions Intelligentes (IA)
- Auto-complétion basée sur historique
- Suggestions dates/lieux selon participants
- Templates personnalisés selon habitudes
- Prédiction budget selon type événement

### 2. 🎨 Fun & Convivial

#### Design Ludique
- Emojis contextuels partout (événements, tâches, réactions)
- Animations micro-interactions (confettis validation, etc.)
- Couleurs vives et inspirantes
- Illustrations custom (empty states, onboarding)

#### Gamification
- Badges d'accomplissements ("Organisateur Pro", "Budget Master")
- Stats personnelles (événements organisés, participations)
- Feed d'activités des amis (style social)
- Récompenses pour contributions (ajouter photos, compléter tâches)

### 3. 📱 Mobile-First

#### Design Tactile
- Swipe actions:
  - Swipe right sur notification: Accepter
  - Swipe left: Refuser/Archiver
  - Swipe sur tâche: Marquer terminée
  - Swipe sur dépense: Éditer/Supprimer

- Actions rapides:
  - Long press pour options contextuelles
  - Pull-to-refresh sur toutes les listes
  - Shake pour feedback/bug report

#### PWA + Apps Natives
- Installation PWA sans store
- Apps natives iOS/Android pour notifications push
- Synchronisation temps réel (WebSockets)
- Mode offline pour consultation

### 4. 🚀 Friction Minimale

#### Lien Magique
- Accès instantané sans compte
- Token URL unique et sécurisé
- Consultation et vote sans inscription
- Conversion progressive: Invité → User

#### Onboarding Minimaliste
- 3 écrans max, skippable
- Création compte optionnelle (social auth)
- Connexion via email magic link
- Import contacts Facebook/Google optionnel

---

## 🏗️ Architecture Technique

### Stack Technologique

#### Frontend (Mobile)
- **Framework**: Flutter (iOS, Android, Web)
- **State Management**: Provider (actuellement) → Riverpod (migration prévue)
- **Storage Local**: Shared Preferences, SQLite (sqflite)
- **API Client**: Dio + JSON serialization

#### Backend (À définir)
- **API**: REST ou GraphQL
- **Real-time**: WebSockets (Socket.io ou Firebase)
- **Auth**: JWT + OAuth (Google, Apple, Facebook)
- **Storage**: Cloud Storage (images/videos)
- **Database**: PostgreSQL ou Firebase Firestore

### Modules Flutter

#### Structure Proposée
```
lib/
├── main.dart
├── app.dart (MaterialApp config)
├── config/
│   ├── theme.dart (couleurs, styles)
│   ├── routes.dart (navigation)
│   └── constants.dart
├── models/
│   ├── user.dart
│   ├── group.dart
│   ├── event.dart
│   ├── task.dart
│   ├── poll.dart
│   ├── expense.dart
│   └── notification.dart
├── providers/
│   ├── auth_provider.dart
│   ├── group_provider.dart
│   ├── event_provider.dart
│   └── notification_provider.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── notification_service.dart
│   ├── storage_service.dart
│   └── location_service.dart
├── screens/
│   ├── auth/
│   ├── groups/
│   ├── events/
│   ├── polls/
│   ├── budget/
│   └── profile/
├── widgets/
│   ├── common/
│   ├── cards/
│   └── inputs/
└── utils/
    ├── validators.dart
    ├── formatters.dart
    └── helpers.dart
```

### Dépendances Clés

#### Actuelles (déjà dans pubspec.yaml)
- `provider`: State management
- `dio`: HTTP client
- `shared_preferences`: Storage local
- `image_picker`, `video_player`: Médias
- `fl_chart`: Graphiques budget
- `url_launcher`: Liens paiements
- `cached_network_image`: Images optimisées

#### À Ajouter
- `flutter_map` ou `google_maps_flutter`: Cartes interactives
- `firebase_messaging`: Push notifications
- `share_plus`: Partage liens/contenu
- `qr_flutter`: QR codes invitations
- `socket_io_client`: Real-time sync
- `flutter_local_notifications`: Notifications locales
- `image_cropper`: Edition photos
- `permission_handler`: Permissions système
- `flutter_contacts`: Import contacts
- `package_info_plus`: Info app

---

## 🎯 Roadmap MVP (Version 1.0)

### Phase 1: Core (Semaines 1-4)
- ✅ Setup projet + architecture
- ✅ Design system implémentation
- ✅ Authentification (email, Google, Apple)
- ✅ Création groupes + invitations
- ✅ Profil utilisateur basique

### Phase 2: Événements (Semaines 5-8)
- ✅ Templates événements
- ✅ CRUD événements
- ✅ Galerie photos
- ✅ Checklists partagées
- ✅ Vue calendrier

### Phase 3: Votes & Budget (Semaines 9-12)
- ✅ Système de sondages
- ✅ Gestion dépenses
- ✅ Calcul répartitions
- ✅ Graphiques budget

### Phase 4: Logistique & Polish (Semaines 13-16)
- ✅ Cartes & itinéraires
- ✅ Suggestions transport/hébergement
- ✅ Notifications push
- ✅ Onboarding
- ✅ Tests & bug fixes

### Phase 5: Launch (Semaine 17)
- ✅ Beta testing (50 users)
- ✅ App Store & Play Store submission
- ✅ Landing page
- ✅ Lancement soft

---

## 🎨 Design Principles (Lien avec DESIGN.md)

### Inspirations
- **WhatsApp**: Clarté, minimalisme, conversations fluides
- **LinkedIn**: Professionnalisme, cards élégantes, hiérarchie claire
- **Material Design 3**: Modernité, composants standards

### Couleurs
- **Primary**: #0A66C2 (LinkedIn Blue) - Confiance, organisation
- **Secondary**: #25D366 (WhatsApp Green) - Action, validation
- **Accents**: Fun colors pour emojis et badges

### Navigation
- **Bottom Navigation Bar** (3 tabs):
  - 🏠 Accueil (Dashboard)
  - 📅 Événements
  - 👤 Profil

- **FAB**: Action principale contextuelle (+ Événement, + Groupe...)

---

## 📊 Métriques de Succès

### Onboarding
- Taux d'inscription: >30% des invités deviennent users
- Temps d'onboarding: <1 minute

### Engagement
- MAU (Monthly Active Users): Objectif 10k en 6 mois
- Événements créés/user/mois: >2
- Participation votes: >70%
- Temps moyen session: >5 minutes

### Rétention
- Day 1: >50%
- Week 1: >30%
- Month 1: >20%

### Satisfaction
- App Store rating: >4.5/5
- NPS (Net Promoter Score): >50

---

## 🔐 Considérations Légales & Sécurité

### RGPD
- Consentement explicite collecte données
- Droit à l'oubli implémenté
- Export données personnelles (GDPR)
- Politique de confidentialité claire

### Sécurité
- HTTPS obligatoire
- JWT tokens sécurisés (refresh + access)
- Chiffrement données sensibles (budget)
- Rate limiting API
- Validation inputs côté serveur

### Paiements
- Pas de stockage CB (redirection Stripe/Lydia)
- Conformité PCI-DSS si intégration directe
- Transparence frais (si commissions)

---

## 💡 Idées Futures (Post-MVP)

### Version 2.0
- 🤖 **Assistant IA**: Suggestions smart, réponses automatiques sondages
- 🎵 **Playlists Spotify partagées**: Musique collaborative pour soirées
- 🎟️ **Billetterie intégrée**: Achat tickets concerts/événements
- 📺 **Visio intégrée**: Appel groupe pour planification
- 🏆 **Leaderboard**: Classement organisateurs les plus actifs

### Version 3.0
- 🌍 **Événements publics**: Rencontres communautaires
- 💼 **Mode Business**: Événements corporatifs, team buildings
- 🎁 **Marketplace partenaires**: Offres exclusives (restos, activités)
- 📱 **Widget iOS/Android**: Prochains événements sur home screen
- 🔗 **Intégrations**: Google Calendar, Notion, Trello

---

**Document créé le**: 15 décembre 2025  
**Version**: 1.0.0  
**Auteur**: Équipe Produit Livemory  
**Statut**: ✅ Approuvé pour développement
