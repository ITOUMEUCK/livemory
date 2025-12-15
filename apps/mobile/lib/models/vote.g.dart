// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vote _$VoteFromJson(Map<String, dynamic> json) => Vote(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  stepId: json['stepId'] as String?,
  title: json['title'] as String,
  description: json['description'] as String,
  type:
      $enumDecodeNullable(_$VoteTypeEnumMap, json['type']) ?? VoteType.location,
  options:
      (json['options'] as List<dynamic>?)
          ?.map((e) => VoteOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  allowMultipleChoices: json['allowMultipleChoices'] as bool? ?? false,
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  deadline: json['deadline'] == null
      ? null
      : DateTime.parse(json['deadline'] as String),
  status:
      $enumDecodeNullable(_$VoteStatusEnumMap, json['status']) ??
      VoteStatus.active,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$VoteToJson(Vote instance) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'stepId': instance.stepId,
  'title': instance.title,
  'description': instance.description,
  'type': _$VoteTypeEnumMap[instance.type]!,
  'options': instance.options,
  'allowMultipleChoices': instance.allowMultipleChoices,
  'isAnonymous': instance.isAnonymous,
  'deadline': instance.deadline?.toIso8601String(),
  'status': _$VoteStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$VoteTypeEnumMap = {
  VoteType.location: 'location',
  VoteType.datetime: 'datetime',
  VoteType.activity: 'activity',
  VoteType.other: 'other',
};

const _$VoteStatusEnumMap = {
  VoteStatus.active: 'active',
  VoteStatus.closed: 'closed',
};

VoteOption _$VoteOptionFromJson(Map<String, dynamic> json) => VoteOption(
  id: json['id'] as String,
  voteId: json['voteId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
  votedByIds:
      (json['votedByIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$VoteOptionToJson(VoteOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'voteId': instance.voteId,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'voteCount': instance.voteCount,
      'votedByIds': instance.votedByIds,
    };
