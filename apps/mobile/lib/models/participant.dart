import 'package:json_annotation/json_annotation.dart';

part 'participant.g.dart';

@JsonSerializable()
class Participant {
  final String id;
  final String userId;
  final String eventId;
  final String name;
  final String? email;
  final String? avatarUrl;
  final ParticipantRole role;
  final bool hasAccepted;
  final List<String> stepIds; // Steps this participant is part of
  final DateTime joinedAt;

  Participant({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.name,
    this.email,
    this.avatarUrl,
    this.role = ParticipantRole.member,
    this.hasAccepted = false,
    this.stepIds = const [],
    required this.joinedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantToJson(this);

  Participant copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? name,
    String? email,
    String? avatarUrl,
    ParticipantRole? role,
    bool? hasAccepted,
    List<String>? stepIds,
    DateTime? joinedAt,
  }) {
    return Participant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      hasAccepted: hasAccepted ?? this.hasAccepted,
      stepIds: stepIds ?? this.stepIds,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

enum ParticipantRole {
  @JsonValue('organizer')
  organizer,
  @JsonValue('admin')
  admin,
  @JsonValue('member')
  member,
}
