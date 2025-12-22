# 📋 Système d'Activités et TODO Lists pour les Événements

## Vue d'ensemble

Ce module permet d'ajouter et de gérer des activités datées et des listes de tâches (TODO) pour chaque événement Livemory.

## 🎯 Fonctionnalités

### Activités Datées
- ✅ Créer des activités avec date/heure
- ✅ Ajouter un lieu et une description
- ✅ Tri automatique par date
- ✅ Modification et suppression

### TODO Lists
- ✅ Créer des listes de tâches
- ✅ Ajouter plusieurs tâches par liste
- ✅ 3 statuts : Non démarré, En cours, Terminé
- ✅ Attribution multiple (plusieurs membres par tâche)
- ✅ Calcul automatique du statut global
- ✅ Barre de progression visuelle

## 📁 Structure des fichiers

```
lib/features/events/
├── domain/entities/
│   ├── activity.dart              # Modèle Activity
│   ├── todo_task.dart             # Modèle TodoTask
│   └── todo_list.dart             # Modèle TodoList
│
├── presentation/
│   ├── providers/
│   │   ├── activity_provider.dart     # Gestion des activités
│   │   └── todo_list_provider.dart    # Gestion des TODO
│   │
│   ├── screens/
│   │   ├── event_activities_tab.dart  # Onglet activités
│   │   └── event_todos_tab.dart       # Onglet TODO
│   │
│   └── widgets/
│       ├── activity_card.dart         # Carte d'activité
│       └── todo_list_card.dart        # Carte TODO
```

## 🔄 Intégration

### 1. Providers ajoutés dans `app.dart`
```dart
ChangeNotifierProvider(create: (_) => ActivityProvider()),
ChangeNotifierProvider(create: (_) => TodoListProvider()),
```

### 2. Intégration dans l'écran de détail d'événement

Ajoutez ces onglets dans `EventDetailScreen` :

```dart
TabBar(
  tabs: [
    Tab(text: 'Infos'),
    Tab(text: 'Activités'),      // Nouvel onglet
    Tab(text: 'TODO'),            // Nouvel onglet
    Tab(text: 'Budget'),
    Tab(text: 'Sondages'),
  ],
),
TabBarView(
  children: [
    InfoTab(),
    EventActivitiesTab(eventId: eventId),  // Nouveau
    EventTodosTab(eventId: eventId),       // Nouveau
    BudgetTab(),
    PollsTab(),
  ],
),
```

### 3. Ajout de FABs conditionnels

```dart
floatingActionButton: _currentTabIndex == 1
    ? FloatingActionButton.extended(
        onPressed: () => _showAddActivityDialog(),
        icon: Icon(Icons.add),
        label: Text('Activité'),
      )
    : _currentTabIndex == 2
        ? FloatingActionButton.extended(
            onPressed: () => _showAddTodoDialog(),
            icon: Icon(Icons.add),
            label: Text('TODO'),
          )
        : null,
```

## 📊 Modèles de données

### Activity
```dart
- id: String
- eventId: String
- title: String
- description: String?
- dateTime: DateTime
- location: String?
- createdBy: String
- createdAt: DateTime
- updatedAt: DateTime
```

### TodoTask
```dart
- id: String
- title: String
- description: String?
- assignedTo: List<String>  // IDs des membres
- status: TaskStatus (notStarted, inProgress, completed)
- dueDate: DateTime?
- createdAt: DateTime
- updatedAt: DateTime
```

### TodoList
```dart
- id: String
- eventId: String
- title: String
- description: String?
- tasks: List<TodoTask>
- createdBy: String
- createdAt: DateTime
- updatedAt: DateTime

// Propriétés calculées:
- overallStatus: TaskStatus
- completionPercentage: double
```

## 🎨 UI/UX

### ActivityCard
- 📅 Date et heure formatées
- 📍 Lieu optionnel avec icône
- ✏️ Modification au clic
- 🗑️ Suppression avec confirmation

### TodoListCard
- 📊 Barre de progression colorée
- 🏷️ Badge de statut
- 📈 Pourcentage de complétion
- 🔢 Nombre de tâches

## 🚀 Utilisation

### Créer une activité
1. Aller dans l'onglet "Activités" d'un événement
2. Cliquer sur le bouton FAB "Activité"
3. Remplir les informations
4. Enregistrer

### Créer une TODO
1. Aller dans l'onglet "TODO" d'un événement
2. Cliquer sur le bouton FAB "TODO"
3. Ajouter des tâches
4. Assigner des membres à chaque tâche
5. Enregistrer

### Mettre à jour le statut d'une tâche
1. Ouvrir la TODO list
2. Modifier une tâche
3. Changer le statut
4. Le statut global et le pourcentage se mettent à jour automatiquement

## 🔐 Firestore Collections

```
activities/
  {activityId}/
    - id, eventId, title, description, dateTime, location, createdBy, createdAt, updatedAt

todoLists/
  {todoListId}/
    - id, eventId, title, description, createdBy, createdAt, updatedAt
    - tasks: [
        {id, title, description, assignedTo, status, dueDate, createdAt, updatedAt}
      ]
```

## 📝 TODO / Améliorations futures

- [ ] Notifications pour les tâches assignées
- [ ] Dates d'échéance pour les tâches
- [ ] Rappels automatiques
- [ ] Historique des modifications
- [ ] Commentaires sur les activités/tâches
- [ ] Export des TODO en PDF
- [ ] Synchronisation avec calendrier externe

## 🎯 Points clés

- **Statut auto-calculé** : Le statut d'une TODO est déterminé par ses tâches
- **Attribution flexible** : Une tâche peut être assignée à plusieurs membres
- **Tri intelligent** : Les activités sont triées par date automatiquement
- **UX optimisée** : Dialogues modaux pour éviter la navigation excessive
- **Validation** : Champs requis et messages d'erreur clairs
