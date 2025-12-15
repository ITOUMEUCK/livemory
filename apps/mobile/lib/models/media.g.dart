// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  stepId: json['stepId'] as String?,
  uploadedById: json['uploadedById'] as String,
  uploadedByName: json['uploadedByName'] as String,
  type: $enumDecode(_$MediaTypeEnumMap, json['type']),
  url: json['url'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  caption: json['caption'] as String?,
  taggedParticipantIds:
      (json['taggedParticipantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  likes: (json['likes'] as num?)?.toInt() ?? 0,
  likedByIds:
      (json['likedByIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'stepId': instance.stepId,
  'uploadedById': instance.uploadedById,
  'uploadedByName': instance.uploadedByName,
  'type': _$MediaTypeEnumMap[instance.type]!,
  'url': instance.url,
  'thumbnailUrl': instance.thumbnailUrl,
  'caption': instance.caption,
  'taggedParticipantIds': instance.taggedParticipantIds,
  'likes': instance.likes,
  'likedByIds': instance.likedByIds,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$MediaTypeEnumMap = {MediaType.photo: 'photo', MediaType.video: 'video'};

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  coverMediaId: json['coverMediaId'] as String?,
  mediaItems:
      (json['mediaItems'] as List<dynamic>?)
          ?.map((e) => Media.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'title': instance.title,
  'description': instance.description,
  'coverMediaId': instance.coverMediaId,
  'mediaItems': instance.mediaItems,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
