import '../config/api_config.dart';
import '../models/vote.dart';
import 'api_service.dart';

class VoteService {
  final ApiService _apiService = ApiService();

  // Get votes for an event
  Future<List<Vote>> getEventVotes(String eventId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/votes',
    );
    final votes = (response['votes'] as List)
        .map((json) => Vote.fromJson(json))
        .toList();
    return votes;
  }

  // Get vote by ID
  Future<Vote> getVoteById(String eventId, String voteId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/votes/$voteId',
    );
    return Vote.fromJson(response['vote']);
  }

  // Create vote
  Future<Vote> createVote(String eventId, Vote vote) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/votes',
      data: vote.toJson(),
    );
    return Vote.fromJson(response['vote']);
  }

  // Update vote
  Future<Vote> updateVote(String eventId, String voteId, Vote vote) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/votes/$voteId',
      data: vote.toJson(),
    );
    return Vote.fromJson(response['vote']);
  }

  // Delete vote
  Future<void> deleteVote(String eventId, String voteId) async {
    await _apiService.delete<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/votes/$voteId',
    );
  }

  // Cast vote
  Future<Vote> castVote(
    String eventId,
    String voteId,
    List<String> optionIds,
  ) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/votes/$voteId/cast',
      data: {'optionIds': optionIds},
    );
    return Vote.fromJson(response['vote']);
  }

  // Close vote
  Future<Vote> closeVote(String eventId, String voteId) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/votes/$voteId/close',
    );
    return Vote.fromJson(response['vote']);
  }

  // Get vote results
  Future<Map<String, dynamic>> getVoteResults(
    String eventId,
    String voteId,
  ) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/votes/$voteId/results',
    );
    return response;
  }
}
