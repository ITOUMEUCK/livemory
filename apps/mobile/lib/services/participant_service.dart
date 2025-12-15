import '../config/api_config.dart';
import '../models/participant.dart';
import 'api_service.dart';

class ParticipantService {
  final ApiService _apiService = ApiService();

  // Get participants for an event
  Future<List<Participant>> getEventParticipants(String eventId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/participants',
    );
    final participants = (response['participants'] as List)
        .map((json) => Participant.fromJson(json))
        .toList();
    return participants;
  }

  // Add participant to event
  Future<Participant> addParticipant(
    String eventId,
    String userId, {
    List<String>? stepIds,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/participants',
      data: {'userId': userId, if (stepIds != null) 'stepIds': stepIds},
    );
    return Participant.fromJson(response['participant']);
  }

  // Update participant
  Future<Participant> updateParticipant(
    String eventId,
    String participantId, {
    ParticipantRole? role,
    List<String>? stepIds,
  }) async {
    final response = await _apiService.patch<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/participants/$participantId',
      data: {
        if (role != null) 'role': role.toString().split('.').last,
        if (stepIds != null) 'stepIds': stepIds,
      },
    );
    return Participant.fromJson(response['participant']);
  }

  // Remove participant
  Future<void> removeParticipant(String eventId, String participantId) async {
    await _apiService.delete<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/participants/$participantId',
    );
  }

  // Accept invitation
  Future<Participant> acceptInvitation(String eventId) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/participants/accept',
    );
    return Participant.fromJson(response['participant']);
  }

  // Decline invitation
  Future<void> declineInvitation(String eventId) async {
    await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/participants/decline',
    );
  }

  // Add participant to step
  Future<void> addParticipantToStep(
    String eventId,
    String stepId,
    String participantId,
  ) async {
    await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/steps/$stepId/participants',
      data: {'participantId': participantId},
    );
  }

  // Remove participant from step
  Future<void> removeParticipantFromStep(
    String eventId,
    String stepId,
    String participantId,
  ) async {
    await _apiService.delete<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/steps/$stepId/participants/$participantId',
    );
  }
}
