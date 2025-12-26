import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/todo_list.dart';
import '../../domain/entities/todo_task.dart';

/// Provider pour gérer les TODO lists des événements
class TodoListProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TodoList> _todoLists = [];
  bool _isLoading = false;
  String? _error;

  List<TodoList> get todoLists => _todoLists;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Récupère toutes les TODO lists d'un événement
  Future<void> fetchTodoLists(String eventId) async {
    print('TodoListProvider.fetchTodoLists - Début pour eventId: $eventId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('todoLists')
          .where('eventId', isEqualTo: eventId)
          .get();

      print('TodoListProvider: ${snapshot.docs.length} todoLists trouvées');

      _todoLists = snapshot.docs.map((doc) {
        print('TodoList doc: ${doc.id}');
        return TodoList.fromMap(doc.data());
      }).toList();

      // Trier côté client par date de création (plus récents d'abord)
      _todoLists.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('TodoListProvider: _todoLists.length = ${_todoLists.length}');
    } catch (e) {
      print('TodoListProvider ERROR: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute une nouvelle TODO list
  Future<void> addTodoList(TodoList todoList) async {
    try {
      await _firestore
          .collection('todoLists')
          .doc(todoList.id)
          .set(todoList.toMap());

      _todoLists.insert(0, todoList);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Met à jour une TODO list
  Future<void> updateTodoList(TodoList todoList) async {
    try {
      await _firestore
          .collection('todoLists')
          .doc(todoList.id)
          .update(todoList.toMap());

      final index = _todoLists.indexWhere((t) => t.id == todoList.id);
      if (index != -1) {
        _todoLists[index] = todoList;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Supprime une TODO list
  Future<void> deleteTodoList(String todoListId) async {
    try {
      await _firestore.collection('todoLists').doc(todoListId).delete();

      _todoLists.removeWhere((t) => t.id == todoListId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Met à jour le statut d'une tâche
  Future<void> updateTaskStatus(
    String todoListId,
    String taskId,
    TaskStatus newStatus,
  ) async {
    final todoList = _todoLists.firstWhere((t) => t.id == todoListId);
    final updatedTasks = todoList.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(status: newStatus, updatedAt: DateTime.now());
      }
      return task;
    }).toList();

    final updatedTodoList = todoList.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
    );

    await updateTodoList(updatedTodoList);
  }

  /// Filtre les TODO lists par événement
  List<TodoList> getTodoListsByEvent(String eventId) {
    return _todoLists.where((t) => t.eventId == eventId).toList();
  }

  /// Récupère les tâches assignées à un utilisateur
  List<TodoTask> getTasksAssignedToUser(String userId) {
    final allTasks = <TodoTask>[];
    for (var todoList in _todoLists) {
      for (var task in todoList.tasks) {
        if (task.assignedTo.contains(userId)) {
          allTasks.add(task);
        }
      }
    }
    return allTasks;
  }
}
