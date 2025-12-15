// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
  id: json['id'] as String,
  userId: json['userId'] as String,
  eventId: json['eventId'] as String,
  name: json['name'] as String,
  email: json['email'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  role:
      $enumDecodeNullable(_$ParticipantRoleEnumMap, json['role']) ??
      ParticipantRole.member,
  hasAccepted: json['hasAccepted'] as bool? ?? false,
  stepIds:
      (json['stepIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'eventId': instance.eventId,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'role': _$ParticipantRoleEnumMap[instance.role]!,
      'hasAccepted': instance.hasAccepted,
      'stepIds': instance.stepIds,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

const _$ParticipantRoleEnumMap = {
  ParticipantRole.organizer: 'organizer',
  ParticipantRole.admin: 'admin',
  ParticipantRole.member: 'member',
};
