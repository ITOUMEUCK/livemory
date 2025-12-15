# 📱 Livemory Mobile

**Livemory** est une application mobile-first, ludique et intuitive pour orchestrer vos soirées et week-ends entre amis en quelques taps.

## 🎯 Vision

Organiser des événements sociaux ne devrait pas être compliqué. Livemory simplifie la coordination de groupes en centralisant :
- 👥 Gestion de groupes et invitations
- 📅 Création d'événements avec templates
- 🗳️ Votes et sondages (dates, lieux, activités)
- 💰 Suivi budget et répartition des coûts
- 🗺️ Logistique (carte, transport, hébergement)
- 🔔 Notifications intelligentes

## ✨ Fonctionnalités Clés

### ⚡ Ultra Rapide
- Création événement en **moins de 2 minutes**
- Flux guidé en 3 étapes (Groupe → Événement → Organiser)
- Suggestions intelligentes basées sur l'historique

### 🎨 Fun & Convivial
- Design coloré inspiré WhatsApp × LinkedIn
- Emojis contextuels partout
- Animations micro-interactions
- Gamification (badges, stats)

### 📱 Mobile-First
- Actions swipe intuitives
- Bottom navigation 3 tabs
- PWA + Apps natives (iOS/Android)
- Mode offline

### 🚀 Friction Minimale
- **Liens magiques**: Participez sans inscription
- Authentification sociale (Google, Apple)
- Onboarding en 3 slides (<30 secondes)

## 🏗️ Architecture

**Clean Architecture** avec séparation en couches :
```
Presentation (UI) → Domain (Business Logic) → Data (API/Storage)
```

**State Management**: Provider (migration Riverpod prévue)

**Structure modulaire** par features :
```
lib/
├── features/
│   ├── auth/          # Authentification
│   ├── groups/        # Gestion groupes
│   ├── events/        # Événements
│   ├── polls/         # Votes & sondages
│   ├── budget/        # Budget & paiements
│   ├── logistics/     # Carte & transport
│   └── notifications/ # Notifications
├── core/              # Utils transversaux
└── shared/            # Widgets communs
```

Voir [ARCHITECTURE.md](ARCHITECTURE.md) pour plus de détails.

## 🎨 Design System

Inspiré de **WhatsApp** (clarté, minimalisme) et **LinkedIn** (professionnalisme).

**Couleurs principales**:
- Primary: `#0A66C2` (LinkedIn Blue)
- Secondary: `#25D366` (WhatsApp Green)
- Background: `#F5F7FA`

**Composants**:
- Cards avec ombres légères
- Boutons arrondis (24px radius)
- Bottom Navigation Bar
- FAB (Floating Action Button)

Voir [DESIGN.md](DESIGN.md) pour le guide complet.

## 📋 Plan de Développement

**MVP en 17 semaines** (4 mois) :

### Phase 1: Fondations (Semaines 1-4)
- Setup projet + architecture
- Design system
- Authentification (email + social auth)
- Onboarding

### Phase 2: Core Features (Semaines 5-8)
- Groupes & invitations
- Événements avec templates
- Checklists partagées
- Galerie photos

### Phase 3: Votes & Budget (Semaines 9-12)
- Système de sondages (dates/lieux/choix)
- Gestion dépenses
- Calcul balances automatique
- Export PDF/CSV

### Phase 4: Logistique & Polish (Semaines 13-16)
- Carte interactive
- Suggestions transport/hébergement
- Notifications push
- Bug fixes & optimisations

### Phase 5: Launch (Semaine 17)
- Beta testing (50 users)
- App Store & Play Store
- Landing page
- Lancement soft

Voir [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) pour le détail complet.

## 🚀 Getting Started

### Prérequis
- Flutter SDK `>=3.10.4`
- Dart SDK `>=3.10.4`
- Android Studio / Xcode
- Git

### Installation

```bash
# Cloner le repository
git clone https://github.com/yourorg/livemory-mobile.git
cd livemory-mobile/apps/mobile

# Installer les dépendances
flutter pub get

# Lancer l'app en mode dev
flutter run
```

### Configuration

1. **Firebase**: Ajouter `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)
2. **API**: Configurer `lib/core/constants/api_constants.dart` avec les URLs backend
3. **Maps**: Ajouter API keys Google Maps dans `AndroidManifest.xml` et `Info.plist`

## 📦 Dépendances Principales

```yaml
# State Management
provider: ^6.1.2

# Networking
dio: ^5.7.0

# Firebase
firebase_auth: ^5.3.3
firebase_messaging: ^15.1.6
firebase_analytics: ^11.4.0

# UI
cached_network_image: ^3.4.1
fl_chart: ^0.69.2
google_maps_flutter: ^2.9.0

# Storage
shared_preferences: ^2.3.3
flutter_secure_storage: ^9.2.2

# Utilities
image_picker: ^1.1.2
url_launcher: ^6.3.1
share_plus: ^10.1.2
```

Voir [pubspec.yaml](pubspec.yaml) pour la liste complète.

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests widgets
flutter test test/widget

# Tests d'intégration
flutter drive --target=test_driver/app.dart
```

**Objectif couverture**: >70%

## 📱 Build & Deployment

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Debug
flutter build ios --debug

# Release (Archive via Xcode)
flutter build ios --release
```

### Web (PWA)
```bash
flutter build web --release
```

## 📚 Documentation

- [PRODUCT_SPEC.md](PRODUCT_SPEC.md) - Spécification produit complète
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture technique détaillée
- [DESIGN.md](DESIGN.md) - Guide de design
- [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) - Plan de développement par sprints

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/amazing-feature`)
3. Commit les changements (`git commit -m 'Add amazing feature'`)
4. Push sur la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

**Convention commits**: [Conventional Commits](https://www.conventionalcommits.org/)

```
feat: Ajout système de votes
fix: Correction calcul budget
docs: Mise à jour README
style: Formatage code
refactor: Refonte architecture auth
test: Ajout tests unitaires budget
chore: Update dependencies
```

## 📄 License

MIT License - voir [LICENSE](LICENSE) pour plus de détails.

## 👥 Équipe

- **Product Owner**: [Nom]
- **Lead Developer**: [Nom]
- **Designer**: [Nom]

## 📧 Contact & Support

- **Email**: contact@livemory.app
- **Website**: https://livemory.app
- **Twitter**: [@livemory_app](https://twitter.com/livemory_app)

## 🎯 Roadmap

### Version 1.0 (MVP) - Q1 2026
- ✅ Groupes & événements
- ✅ Votes & sondages
- ✅ Budget & paiements
- ✅ Logistique & carte
- ✅ Notifications

### Version 1.1 - Q2 2026
- Mode sombre
- Recherche avancée
- Statistiques personnelles
- Notifications digest

### Version 2.0 - Q3 2026
- Assistant IA
- Playlists Spotify partagées
- Visio intégrée
- Marketplace partenaires

Voir [PRODUCT_SPEC.md](PRODUCT_SPEC.md) pour la roadmap complète.

---

**Made with ❤️ by the Livemory Team**
