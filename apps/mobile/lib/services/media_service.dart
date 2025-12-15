import '../config/api_config.dart';
import '../models/media.dart';
import 'api_service.dart';

class MediaService {
  final ApiService _apiService = ApiService();

  // Get media for event
  Future<List<Media>> getEventMedia(String eventId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/media',
    );
    final mediaItems = (response['media'] as List)
        .map((json) => Media.fromJson(json))
        .toList();
    return mediaItems;
  }

  // Get media for step
  Future<List<Media>> getStepMedia(String eventId, String stepId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/steps/$stepId/media',
    );
    final mediaItems = (response['media'] as List)
        .map((json) => Media.fromJson(json))
        .toList();
    return mediaItems;
  }

  // Upload media
  Future<Media> uploadMedia(
    String eventId,
    String filePath, {
    String? stepId,
    String? caption,
    List<String>? taggedParticipantIds,
  }) async {
    final response = await _apiService.uploadFile<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/media',
      filePath,
      fileKey: 'media',
      data: {
        if (stepId != null) 'stepId': stepId,
        if (caption != null) 'caption': caption,
        if (taggedParticipantIds != null)
          'taggedParticipantIds': taggedParticipantIds,
      },
    );
    return Media.fromJson(response['media']);
  }

  // Update media
  Future<Media> updateMedia(
    String eventId,
    String mediaId, {
    String? caption,
    List<String>? taggedParticipantIds,
  }) async {
    final response = await _apiService.patch<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/media/$mediaId',
      data: {
        if (caption != null) 'caption': caption,
        if (taggedParticipantIds != null)
          'taggedParticipantIds': taggedParticipantIds,
      },
    );
    return Media.fromJson(response['media']);
  }

  // Delete media
  Future<void> deleteMedia(String eventId, String mediaId) async {
    await _apiService.delete<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/media/$mediaId',
    );
  }

  // Like media
  Future<Media> likeMedia(String eventId, String mediaId) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/media/$mediaId/like',
    );
    return Media.fromJson(response['media']);
  }

  // Unlike media
  Future<Media> unlikeMedia(String eventId, String mediaId) async {
    final response = await _apiService.delete<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/media/$mediaId/like',
    );
    return Media.fromJson(response['media']);
  }

  // Get album
  Future<Album> getAlbum(String eventId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/album',
    );
    return Album.fromJson(response['album']);
  }

  // Create album
  Future<Album> createAlbum(
    String eventId,
    String title, {
    String? description,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/album',
      data: {
        'title': title,
        if (description != null) 'description': description,
      },
    );
    return Album.fromJson(response['album']);
  }

  // Update album
  Future<Album> updateAlbum(
    String eventId, {
    String? title,
    String? description,
    String? coverMediaId,
  }) async {
    final response = await _apiService.patch<Map<String, dynamic>>(
      '${ApiConfig.eventsEndpoint}/$eventId/album',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (coverMediaId != null) 'coverMediaId': coverMediaId,
      },
    );
    return Album.fromJson(response['album']);
  }
}
