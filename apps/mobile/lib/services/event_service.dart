import '../config/api_config.dart';
import '../models/event.dart';
import 'api_service.dart';

class EventService {
  final ApiService _apiService = ApiService();

  // Get all events
  Future<List<Event>> getEvents() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      ApiConfig.eventsEndpoint,
    );
    final events = (response['events'] as List)
        .map((json) => Event.fromJson(json))
        .toList();
    return events;
  }

  // Get event by ID
  Future<Event> getEventById(String id) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$id',
    );
    return Event.fromJson(response['event']);
  }

  // Create event
  Future<Event> createEvent(Event event) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConfig.eventsEndpoint,
      data: event.toJson(),
    );
    return Event.fromJson(response['event']);
  }

  // Update event
  Future<Event> updateEvent(String id, Event event) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$id',
      data: event.toJson(),
    );
    return Event.fromJson(response['event']);
  }

  // Delete event
  Future<void> deleteEvent(String id) async {
    await _apiService.delete<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$id',
    );
  }

  // Add step to event
  Future<EventStep> addStep(String eventId, EventStep step) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/steps',
      data: step.toJson(),
    );
    return EventStep.fromJson(response['step']);
  }

  // Update step
  Future<EventStep> updateStep(
    String eventId,
    String stepId,
    EventStep step,
  ) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/steps/$stepId',
      data: step.toJson(),
    );
    return EventStep.fromJson(response['step']);
  }

  // Delete step
  Future<void> deleteStep(String eventId, String stepId) async {
    await _apiService.delete<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/steps/$stepId',
    );
  }

  // Get my events (as creator or participant)
  Future<List<Event>> getMyEvents() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/me',
    );
    final events = (response['events'] as List)
        .map((json) => Event.fromJson(json))
        .toList();
    return events;
  }
}
