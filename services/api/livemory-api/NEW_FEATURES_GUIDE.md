# API Livemory - Guide des Endpoints

## 📋 Vue d'ensemble des nouvelles fonctionnalités

Toutes les fonctionnalités demandées ont été implémentées avec succès ! Voici un guide complet des nouveaux endpoints.

---

## 1️⃣ Groupes persistants

### POST `/api/v1/groups`
Créer un nouveau groupe d'amis
```json
{
  "name": "Groupe Week-end Montagne",
  "description": "Notre groupe pour les sorties ski"
}
?createdById=1
```

### GET `/api/v1/groups/user/{userId}`
Récupérer tous les groupes d'un utilisateur

### GET `/api/v1/groups/{id}`
Détails d'un groupe spécifique

### POST `/api/v1/groups/{groupId}/members`
Ajouter un membre au groupe
```json
{
  "userId": 5,
  "role": "MEMBER"
}
```

### GET `/api/v1/groups/{groupId}/members`
Liste des membres du groupe

### DELETE `/api/v1/groups/{groupId}/members/{userId}`
Retirer un membre

### DELETE `/api/v1/groups/{groupId}?userId={userId}`
Supprimer le groupe (owner uniquement)

---

## 2️⃣ Invitations (liens magiques)

### POST `/api/v1/invitations`
Créer une invitation par lien/email/SMS
```json
{
  "groupId": 1,
  "eventId": null,
  "invitedById": 1,
  "invitedEmail": "ami@example.com",
  "invitedPhone": "+33612345678",
  "role": "MEMBER",
  "expiresInDays": 7
}
```
Retourne le token et `invitationLink` prêt à partager

### GET `/api/v1/invitations/{token}`
Voir les détails d'une invitation

### POST `/api/v1/invitations/accept`
Accepter une invitation
```json
{
  "token": "abc123def456...",
  "userId": 5
}
```

### POST `/api/v1/invitations/{token}/decline`
Refuser une invitation

### GET `/api/v1/invitations/email/{email}`
Voir toutes les invitations pour un email

### GET `/api/v1/invitations/group/{groupId}`
Invitations d'un groupe

### GET `/api/v1/invitations/event/{eventId}`
Invitations d'un événement

---

## 3️⃣ Utilisateurs invités (authentification légère)

### POST `/api/v1/guests`
Créer un compte invité sans inscription complète
```json
{
  "name": "Martin",
  "email": "martin@example.com",
  "phone": "+33612345678",
  "invitationToken": "abc123def456..."
}
```

### GET `/api/v1/guests/{token}`
Récupérer les infos d'un invité

### POST `/api/v1/guests/{token}/convert?email={email}&password={password}`
Convertir un invité en utilisateur complet

---

## 4️⃣ Templates d'événements

### GET `/api/v1/templates/system`
Récupérer tous les templates système (8 templates pré-configurés)

### GET `/api/v1/templates/type/{eventType}`
Templates par type (PARTY, WEEKEND, TRIP, RESTAURANT, etc.)

### GET `/api/v1/templates/user/{userId}`
Templates personnalisés d'un utilisateur

### GET `/api/v1/templates/{id}`
Détails d'un template

### POST `/api/v1/templates`
Créer un template personnalisé
```json
{
  "name": "Mon template voyage",
  "description": "Template pour nos voyages en groupe",
  "eventType": "TRIP",
  "icon": "✈️",
  "defaultDurationHours": 120,
  "suggestedTasks": ["Réserver billets", "Check-in hotel"],
  "suggestedBudgetCategories": ["Transport", "Hébergement"],
  "createdById": 1
}
```

### DELETE `/api/v1/templates/{id}?userId={userId}`
Supprimer un template (pas les templates système)

---

## 5️⃣ Notifications

### POST `/api/v1/notifications`
Créer une notification
```json
{
  "userId": 5,
  "type": "EVENT_REMINDER",
  "title": "Rappel: Week-end à la montagne",
  "message": "N'oublie pas le week-end dans 2 jours !",
  "relatedEntityType": "EVENT",
  "relatedEntityId": 10,
  "actionUrl": "/events/10"
}
```

### GET `/api/v1/notifications/user/{userId}`
Toutes les notifications d'un utilisateur

### GET `/api/v1/notifications/user/{userId}/unread`
Notifications non lues

### GET `/api/v1/notifications/user/{userId}/unread/count`
Nombre de notifications non lues

### PUT `/api/v1/notifications/{id}/read`
Marquer comme lue

### PUT `/api/v1/notifications/user/{userId}/read-all`
Tout marquer comme lu

### DELETE `/api/v1/notifications/{id}`
Supprimer une notification

### GET `/api/v1/notifications/preferences/{userId}`
Récupérer les préférences de notification

### PUT `/api/v1/notifications/preferences/{userId}`
Modifier les préférences
```json
{
  "emailEnabled": true,
  "pushEnabled": true,
  "eventReminders": true,
  "taskAssignments": true,
  "voteNotifications": true,
  "budgetAlerts": true,
  "groupInvitations": true
}
```

---

## 6️⃣ Export budget

### GET `/api/v1/export/budget/{eventId}?format=CSV`
Exporter le budget en CSV

### GET `/api/v1/export/budget/{eventId}?format=EXCEL`
Exporter le budget en Excel (.xlsx)

Formats supportés: `CSV`, `EXCEL` (PDF à venir)

---

## 7️⃣ Liens de paiement (Lydia/PayPal)

### POST `/api/v1/payment-links`
Créer un lien de paiement
```json
{
  "eventId": 10,
  "budgetId": 5,
  "paymentProvider": "LYDIA",
  "paymentUrl": "lydia://pay?recipient=0612345678&amount=25.00",
  "amount": 25.00,
  "description": "Part pour le week-end",
  "createdById": 1,
  "expiresInDays": 30
}
```

### GET `/api/v1/payment-links/event/{eventId}`
Tous les liens de paiement d'un événement

### GET `/api/v1/payment-links/event/{eventId}/active`
Liens actifs uniquement

### GET `/api/v1/payment-links/{id}`
Détails d'un lien

### PUT `/api/v1/payment-links/{id}/status?status=COMPLETED`
Modifier le statut (ACTIVE, EXPIRED, COMPLETED, CANCELLED)

### DELETE `/api/v1/payment-links/{id}`
Supprimer un lien

### GET `/api/v1/payment-links/generate/lydia?recipient=0612345678&amount=25.00&message=Weekend`
Générer un lien Lydia

### GET `/api/v1/payment-links/generate/paypal?email=user@example.com&amount=25.00&description=Weekend`
Générer un lien PayPal

**Providers supportés**: LYDIA, PAYPAL, STRIPE, LEETCHI, PAYLIB, REVOLUT, OTHER

---

## 8️⃣ Suggestions (transport, hébergement, activités)

### POST `/api/v1/suggestions`
Créer une suggestion
```json
{
  "eventId": 10,
  "suggestionType": "TRANSPORT",
  "providerName": "SNCF",
  "title": "TGV Paris-Lyon",
  "description": "Départ 8h30, arrivée 10h30",
  "url": "https://www.sncf.com/...",
  "pricePerPerson": 45.00,
  "groupDiscountAvailable": true,
  "minGroupSize": 5,
  "discountPercentage": 15.00,
  "departureLocation": "Paris Gare de Lyon",
  "arrivalLocation": "Lyon Part-Dieu",
  "departureTime": "2025-12-20T08:30:00",
  "arrivalTime": "2025-12-20T10:30:00",
  "createdById": 1
}
```

### GET `/api/v1/suggestions/event/{eventId}`
Toutes les suggestions d'un événement

### GET `/api/v1/suggestions/event/{eventId}/type/{type}`
Suggestions par type (TRANSPORT, ACCOMMODATION, ACTIVITY)

### GET `/api/v1/suggestions/event/{eventId}/group-discounts`
Suggestions avec réductions groupe (filtrées selon le nombre de participants)

### GET `/api/v1/suggestions/{id}`
Détails d'une suggestion

### DELETE `/api/v1/suggestions/{id}`
Supprimer une suggestion

---

## 🗄️ Migrations de base de données

8 nouvelles migrations Flyway ont été créées :
- **V8**: Tables `groups` et `group_members`
- **V9**: Table `invitations`
- **V10**: Table `guest_users`
- **V11**: Table `event_templates`
- **V12**: Insertion des 8 templates système
- **V13**: Tables `notifications` et `notification_preferences`
- **V14**: Table `payment_links`
- **V15**: Table `suggestions`

---

## 📦 Dépendances ajoutées

```xml
<!-- Apache POI pour export Excel -->
<dependency>
  <groupId>org.apache.poi</groupId>
  <artifactId>poi-ooxml</artifactId>
  <version>5.2.5</version>
</dependency>

<!-- OpenCSV pour export CSV -->
<dependency>
  <groupId>com.opencsv</groupId>
  <artifactId>opencsv</artifactId>
  <version>5.9</version>
</dependency>
```

---

## 🚀 Prochaines étapes

1. **Démarrer PostgreSQL**: `docker-compose up -d`
2. **Installer les dépendances**: `mvnw clean install`
3. **Lancer l'application**: `mvnw spring-boot:run`
4. **Tester les endpoints**: Les migrations Flyway s'exécuteront automatiquement

L'API est maintenant prête à supporter toutes les fonctionnalités front-end décrites !

---

## 🎯 Templates système disponibles

1. **Soirée classique** 🎉 - PARTY
2. **Week-end détente** 🏖️ - WEEKEND
3. **Voyage/Vacances** ✈️ - TRIP
4. **Restaurant** 🍽️ - RESTAURANT
5. **Pique-nique** 🧺 - OUTDOOR
6. **Anniversaire** 🎂 - BIRTHDAY
7. **Activité sportive** ⚽ - SPORT
8. **Soirée jeux** 🎲 - GAME_NIGHT

Chaque template contient des tâches suggérées et des catégories de budget pré-configurées.
