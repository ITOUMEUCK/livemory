import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  final String id;
  final String title;
  final String description;
  final String type; // weekend, soiree, citytrip, etc.
  final String creatorId;
  final DateTime startDate;
  final DateTime? endDate;
  final String? coverImageUrl;
  final List<EventStep> steps;
  final List<String> participantIds;
  final EventStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.creatorId,
    required this.startDate,
    this.endDate,
    this.coverImageUrl,
    this.steps = const [],
    this.participantIds = const [],
    this.status = EventStatus.draft,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? creatorId,
    DateTime? startDate,
    DateTime? endDate,
    String? coverImageUrl,
    List<EventStep>? steps,
    List<String>? participantIds,
    EventStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      creatorId: creatorId ?? this.creatorId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      steps: steps ?? this.steps,
      participantIds: participantIds ?? this.participantIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class EventStep {
  final String id;
  final String eventId;
  final String title;
  final String description;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<String> participantIds;
  final int order;

  EventStep({
    required this.id,
    required this.eventId,
    required this.title,
    required this.description,
    required this.startDateTime,
    this.endDateTime,
    this.location,
    this.latitude,
    this.longitude,
    this.participantIds = const [],
    required this.order,
  });

  factory EventStep.fromJson(Map<String, dynamic> json) =>
      _$EventStepFromJson(json);
  Map<String, dynamic> toJson() => _$EventStepToJson(this);
}

enum EventStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum EventType {
  @JsonValue('weekend')
  weekend,
  @JsonValue('soiree')
  soiree,
  @JsonValue('citytrip')
  citytrip,
  @JsonValue('vacation')
  vacation,
  @JsonValue('other')
  other,
}
