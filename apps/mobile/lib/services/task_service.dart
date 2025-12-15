import '../config/api_config.dart';
import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService = ApiService();

  // Get tasks for an event
  Future<List<Task>> getEventTasks(String eventId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/tasks',
    );
    final tasks = (response['tasks'] as List)
        .map((json) => Task.fromJson(json))
        .toList();
    return tasks;
  }

  // Get tasks for a step
  Future<List<Task>> getStepTasks(String eventId, String stepId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/steps/$stepId/tasks',
    );
    final tasks = (response['tasks'] as List)
        .map((json) => Task.fromJson(json))
        .toList();
    return tasks;
  }

  // Create task
  Future<Task> createTask(String eventId, Task task) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/tasks',
      data: task.toJson(),
    );
    return Task.fromJson(response['task']);
  }

  // Update task
  Future<Task> updateTask(String eventId, String taskId, Task task) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/tasks/$taskId',
      data: task.toJson(),
    );
    return Task.fromJson(response['task']);
  }

  // Update task status
  Future<Task> updateTaskStatus(
    String eventId,
    String taskId,
    TaskStatus status,
  ) async {
    final response = await _apiService.patch<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/tasks/$taskId/status',
      data: {'status': status.toString().split('.').last},
    );
    return Task.fromJson(response['task']);
  }

  // Assign task
  Future<Task> assignTask(
    String eventId,
    String taskId,
    String participantId,
  ) async {
    final response = await _apiService.patch<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/tasks/$taskId/assign',
      data: {'assignedToId': participantId},
    );
    return Task.fromJson(response['task']);
  }

  // Delete task
  Future<void> deleteTask(String eventId, String taskId) async {
    await _apiService.delete<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/tasks/$taskId',
    );
  }

  // Get my tasks
  Future<List<Task>> getMyTasks() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.tasksEndpoint}/me',
    );
    final tasks = (response['tasks'] as List)
        .map((json) => Task.fromJson(json))
        .toList();
    return tasks;
  }
}
