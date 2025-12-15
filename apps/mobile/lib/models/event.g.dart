// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: json['type'] as String,
  creatorId: json['creatorId'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  coverImageUrl: json['coverImageUrl'] as String?,
  steps:
      (json['steps'] as List<dynamic>?)
          ?.map((e) => EventStep.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$EventStatusEnumMap, json['status']) ??
      EventStatus.draft,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': instance.type,
  'creatorId': instance.creatorId,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'coverImageUrl': instance.coverImageUrl,
  'steps': instance.steps,
  'participantIds': instance.participantIds,
  'status': _$EventStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$EventStatusEnumMap = {
  EventStatus.draft: 'draft',
  EventStatus.active: 'active',
  EventStatus.completed: 'completed',
  EventStatus.cancelled: 'cancelled',
};

EventStep _$EventStepFromJson(Map<String, dynamic> json) => EventStep(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  startDateTime: DateTime.parse(json['startDateTime'] as String),
  endDateTime: json['endDateTime'] == null
      ? null
      : DateTime.parse(json['endDateTime'] as String),
  location: json['location'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  order: (json['order'] as num).toInt(),
);

Map<String, dynamic> _$EventStepToJson(EventStep instance) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'title': instance.title,
  'description': instance.description,
  'startDateTime': instance.startDateTime.toIso8601String(),
  'endDateTime': instance.endDateTime?.toIso8601String(),
  'location': instance.location,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'participantIds': instance.participantIds,
  'order': instance.order,
};
