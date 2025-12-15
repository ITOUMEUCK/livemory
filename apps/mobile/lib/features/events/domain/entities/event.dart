import 'package:equatable/equatable.dart';

/// Entité Event - Représente un événement
class Event extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String groupId;
  final String creatorId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;
  final EventStatus status;
  final List<String> participantIds;
  final List<String> maybeIds;
  final List<String> declinedIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.groupId,
    required this.creatorId,
    this.startDate,
    this.endDate,
    this.location,
    this.status = EventStatus.planned,
    this.participantIds = const [],
    this.maybeIds = const [],
    this.declinedIds = const [],
    required this.createdAt,
    this.updatedAt,
  });

  /// Nombre total de réponses
  int get totalResponses =>
      participantIds.length + maybeIds.length + declinedIds.length;

  /// Nombre de participants confirmés
  int get confirmedCount => participantIds.length;

  /// Vérifier si un utilisateur participe
  bool isParticipating(String userId) => participantIds.contains(userId);

  /// Vérifier si l'événement est passé
  bool get isPast {
    if (endDate != null) {
      return endDate!.isBefore(DateTime.now());
    }
    if (startDate != null) {
      return startDate!.isBefore(DateTime.now());
    }
    return false;
  }

  /// Vérifier si l'événement est en cours
  bool get isOngoing {
    final now = DateTime.now();
    if (startDate != null && endDate != null) {
      return now.isAfter(startDate!) && now.isBefore(endDate!);
    }
    return false;
  }

  /// Créer une copie avec modifications
  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? groupId,
    String? creatorId,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    EventStatus? status,
    List<String>? participantIds,
    List<String>? maybeIds,
    List<String>? declinedIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      groupId: groupId ?? this.groupId,
      creatorId: creatorId ?? this.creatorId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      status: status ?? this.status,
      participantIds: participantIds ?? this.participantIds,
      maybeIds: maybeIds ?? this.maybeIds,
      declinedIds: declinedIds ?? this.declinedIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    groupId,
    creatorId,
    startDate,
    endDate,
    location,
    status,
    participantIds,
    maybeIds,
    declinedIds,
    createdAt,
    updatedAt,
  ];
}

/// Statut d'un événement
enum EventStatus { draft, planned, ongoing, completed, cancelled }
