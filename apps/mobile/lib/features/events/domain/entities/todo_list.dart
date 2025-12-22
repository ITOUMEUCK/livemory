import 'todo_task.dart';

/// Liste de tâches (TODO) associée à un événement
class TodoList {
  final String id;
  final String eventId;
  final String title;
  final String? description;
  final List<TodoTask> tasks;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoList({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    required this.tasks,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calcule le statut global basé sur les tâches
  TaskStatus get overallStatus {
    if (tasks.isEmpty) return TaskStatus.notStarted;

    final allCompleted = tasks.every(
      (task) => task.status == TaskStatus.completed,
    );
    if (allCompleted) return TaskStatus.completed;

    final hasInProgress = tasks.any(
      (task) => task.status == TaskStatus.inProgress,
    );
    if (hasInProgress) return TaskStatus.inProgress;

    return TaskStatus.notStarted;
  }

  /// Pourcentage de complétion
  double get completionPercentage {
    if (tasks.isEmpty) return 0;
    final completed = tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    return completed / tasks.length;
  }

  /// Crée une copie avec certains champs modifiés
  TodoList copyWith({
    String? id,
    String? eventId,
    String? title,
    String? description,
    List<TodoTask>? tasks,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoList(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      tasks: tasks ?? this.tasks,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convertit en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'title': title,
      'description': description,
      'tasks': tasks.map((task) => task.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crée depuis un Map Firestore
  factory TodoList.fromMap(Map<String, dynamic> map) {
    return TodoList(
      id: map['id'] as String,
      eventId: map['eventId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      tasks: (map['tasks'] as List)
          .map((taskMap) => TodoTask.fromMap(taskMap as Map<String, dynamic>))
          .toList(),
      createdBy: map['createdBy'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
