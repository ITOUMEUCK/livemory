# Livemory API - Endpoints de test

## Base URL
http://localhost:8080/api/v1

## Health Check
```bash
curl http://localhost:8080/api/v1/ping
# Response: "pong"
```

## Users

### Créer un utilisateur
```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Martin",
    "lastName": "Dupont",
    "email": "martin@example.com",
    "avatarUrl": "https://example.com/avatar.jpg"
  }'
```

### Obtenir tous les utilisateurs
```bash
curl http://localhost:8080/api/v1/users
```

### Obtenir un utilisateur par ID
```bash
curl http://localhost:8080/api/v1/users/1
```

### Obtenir un utilisateur par email
```bash
curl http://localhost:8080/api/v1/users/by-email?email=martin@example.com
```

### Supprimer un utilisateur
```bash
curl -X DELETE http://localhost:8080/api/v1/users/1
```

## Events

### Créer un événement
```bash
curl -X POST http://localhost:8080/api/v1/events \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Week-end à Paris",
    "description": "Un super week-end entre amis",
    "type": "CITY_TRIP",
    "coverImageUrl": "https://example.com/paris.jpg",
    "createdByUserId": 1,
    "startDate": "2024-06-15T10:00:00",
    "endDate": "2024-06-17T18:00:00"
  }'
```

### Obtenir tous les événements
```bash
curl http://localhost:8080/api/v1/events
```

### Obtenir un événement par ID
```bash
curl http://localhost:8080/api/v1/events/1
```

### Obtenir les événements par créateur
```bash
curl http://localhost:8080/api/v1/events/by-creator/1
```

### Obtenir les événements par type
```bash
curl http://localhost:8080/api/v1/events/by-type/WEEKEND
# Types disponibles: WEEKEND, PARTY, CITY_TRIP, VACATION, OTHER
```

### Supprimer un événement
```bash
curl -X DELETE http://localhost:8080/api/v1/events/1
```

## Structure des données

### EventType
- WEEKEND
- PARTY
- CITY_TRIP
- VACATION
- OTHER

### ParticipantRole
- ORGANIZER
- PARTICIPANT

### ParticipantStatus
- INVITED
- CONFIRMED
- DECLINED

### TaskStatus
- TODO
- IN_PROGRESS
- DONE

### TaskPriority
- LOW
- MEDIUM
- HIGH

### PaymentCategory
- ACCOMMODATION
- FOOD
- TRANSPORT
- ACTIVITY
- OTHER

### VoteType
- LOCATION
- TIME
- ACTIVITY
- OTHER

### VoteStatus
- ACTIVE
- CLOSED

### OfferCategory
- RESTAURANT
- HOTEL
- ACTIVITY
- TRANSPORT
- OTHER

### MediaType
- PHOTO
- VIDEO
