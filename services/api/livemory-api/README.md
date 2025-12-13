# Livemory API

API REST pour Livemory - une plateforme collaborative de planification d'événements en groupe.

## 🚀 Fonctionnalités

✅ **Gestion d'événements** - Créer des événements avec plusieurs étapes (week-ends, soirées, city trips, vacances)
✅ **Participants** - Ajouter des participants à tout ou partie des étapes
✅ **Tâches** - Attribuer et suivre les tâches entre participants
✅ **Budget & Paiements** - Gérer les budgets et suivre les paiements par catégorie
✅ **Votes** - Lancer des votes pour les lieux, horaires et activités
✅ **Offres partenaires** - Réductions exclusives pour les groupes (restaurants, hôtels, activités)
✅ **Album souvenir** - Partager photos et vidéos de l'événement

## 🏗️ Architecture

- **Framework**: Spring Boot 3.4.0
- **Language**: Java 17
- **Database**: PostgreSQL 16
- **Migration**: Flyway
- **Build**: Maven

### Structure du projet
```
src/main/java/com/livemory/livemory_api/
├── LivemoryApiApplication.java
├── budget/          # Gestion des budgets
├── event/           # Événements principaux
├── health/          # Health checks
├── media/           # Photos et vidéos
├── offer/           # Offres partenaires
├── participant/     # Participants aux événements
├── payment/         # Paiements et transactions
├── step/            # Étapes d'un événement
├── task/            # Tâches à accomplir
├── user/            # Utilisateurs
└── vote/            # Système de votes
```

## 🛠️ Développement

### Prérequis
- Java 17
- Docker & Docker Compose
- Maven (wrapper inclus)

### Démarrage rapide

1. **Démarrer PostgreSQL**
```bash
docker-compose up -d
```

2. **Lancer l'application**
```bash
# Windows
mvnw.cmd spring-boot:run

# Linux/Mac
./mvnw spring-boot:run
```

3. **Tester l'API**
```bash
curl http://localhost:8080/api/v1/ping
# Response: "pong"
```

L'application sera accessible sur `http://localhost:8080`

### Tests des endpoints

Voir [API_TESTS.md](API_TESTS.md) pour des exemples d'utilisation de tous les endpoints.

## 📊 Modèle de données

### Entités principales
- **User** - Utilisateurs de l'application
- **Event** - Événements (types: WEEKEND, PARTY, CITY_TRIP, VACATION, OTHER)
- **Step** - Étapes d'un événement
- **Participant** - Lien entre utilisateurs et événements/étapes
- **Task** - Tâches assignées avec statuts (TODO, IN_PROGRESS, DONE)
- **Budget** - Budget global d'un événement
- **Payment** - Paiements effectués par catégorie
- **Vote** - Votes pour décisions de groupe
- **VoteOption** - Options de vote
- **PartnerOffer** - Réductions et offres partenaires
- **Media** - Photos et vidéos de l'album souvenir

### Relations principales
- Un événement a plusieurs étapes (1:N)
- Un événement a plusieurs participants (1:N)
- Un participant peut être assigné à l'événement entier ou à des étapes spécifiques
- Un événement a un budget et plusieurs paiements (1:1, 1:N)
- Un événement peut avoir plusieurs votes avec options (1:N:N)
- Un événement contient plusieurs médias (1:N)

## 🗄️ Base de données

Les migrations Flyway sont appliquées automatiquement au démarrage:
- **V1** - Table de health check
- **V2** - Tables core (users, events, steps, participants)
- **V3** - Table tasks
- **V4** - Tables budget et payments
- **V5** - Tables votes (votes, vote_options, user_votes)
- **V6** - Table partner_offers
- **V7** - Table media

## 📝 Conventions de code

### Layered Architecture
Chaque feature suit cette structure:
```
feature/
├── Entity.java              # Entité JPA
├── EntityRepository.java    # Repository Spring Data JPA
├── EntityService.java       # Logique métier (@Service, @Transactional)
├── EntityController.java    # Endpoints REST (@RestController)
├── CreateEntityRequest.java # DTO de création (Java record)
├── EntityResponse.java      # DTO de réponse (avec from() mapper)
└── EntityType.java          # Enums si nécessaire
```

### Endpoints REST
- Tous les endpoints utilisent le préfixe `/api/v1/`
- Utilisation de `@Valid` pour la validation
- Codes HTTP: 201 (POST), 204 (DELETE), 200 (GET/PUT)

### Base de données
- ⚠️ **Important**: Ne JAMAIS modifier `spring.jpa.hibernate.ddl-auto` (doit rester `validate`)
- Tous les changements de schéma doivent passer par des migrations Flyway

## 🏥 Health Checks

- **Custom ping**: `GET /api/v1/ping` → `"pong"`
- **Actuator health**: `GET /actuator/health`
- **Actuator info**: `GET /actuator/info`

## 🔧 Configuration

Voir [application.properties](src/main/resources/application.properties) pour la configuration complète.

Connexion PostgreSQL par défaut:
- Host: `localhost:5432`
- Database: `livemory`
- User: `livemory`
- Password: `livemory`

## 📚 Documentation supplémentaire

- [Instructions pour les agents AI](.github/copilot-instructions.md)
- [Tests des endpoints](API_TESTS.md)
- [HELP.md](HELP.md) - Documentation générée par Spring Initializr

## 📄 License

Ce projet fait partie de Livemory - plateforme collaborative de planification d'événements.
