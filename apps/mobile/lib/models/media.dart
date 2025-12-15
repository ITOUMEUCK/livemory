import 'package:json_annotation/json_annotation.dart';

part 'media.g.dart';

@JsonSerializable()
class Media {
  final String id;
  final String eventId;
  final String? stepId;
  final String uploadedById;
  final String uploadedByName;
  final MediaType type;
  final String url;
  final String? thumbnailUrl;
  final String? caption;
  final List<String> taggedParticipantIds;
  final int likes;
  final List<String> likedByIds;
  final DateTime createdAt;

  Media({
    required this.id,
    required this.eventId,
    this.stepId,
    required this.uploadedById,
    required this.uploadedByName,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.caption,
    this.taggedParticipantIds = const [],
    this.likes = 0,
    this.likedByIds = const [],
    required this.createdAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
  Map<String, dynamic> toJson() => _$MediaToJson(this);

  Media copyWith({
    String? id,
    String? eventId,
    String? stepId,
    String? uploadedById,
    String? uploadedByName,
    MediaType? type,
    String? url,
    String? thumbnailUrl,
    String? caption,
    List<String>? taggedParticipantIds,
    int? likes,
    List<String>? likedByIds,
    DateTime? createdAt,
  }) {
    return Media(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      stepId: stepId ?? this.stepId,
      uploadedById: uploadedById ?? this.uploadedById,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      taggedParticipantIds: taggedParticipantIds ?? this.taggedParticipantIds,
      likes: likes ?? this.likes,
      likedByIds: likedByIds ?? this.likedByIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum MediaType {
  @JsonValue('photo')
  photo,
  @JsonValue('video')
  video,
}

@JsonSerializable()
class Album {
  final String id;
  final String eventId;
  final String title;
  final String? description;
  final String? coverMediaId;
  final List<Media> mediaItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  Album({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    this.coverMediaId,
    this.mediaItems = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
  Map<String, dynamic> toJson() => _$AlbumToJson(this);

  int get photoCount =>
      mediaItems.where((m) => m.type == MediaType.photo).length;
  int get videoCount =>
      mediaItems.where((m) => m.type == MediaType.video).length;
}
