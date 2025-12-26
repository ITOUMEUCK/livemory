/// Activité datée associée à un événement
class Activity {
  final String id;
  final String eventId;
  final String title;
  final String? description;
  final DateTime dateTime;
  final String? location;
  final String createdBy;
  final List<String> participantIds; // Liste des participants confirmés
  final DateTime createdAt;
  final DateTime updatedAt;

  const Activity({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    required this.dateTime,
    this.location,
    required this.createdBy,
    this.participantIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une copie avec certains champs modifiés
  Activity copyWith({
    String? id,
    String? eventId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    String? createdBy,
    List<String>? participantIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convertit en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'createdBy': createdBy,
      'participantIds': participantIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crée depuis un Map Firestore
  factory Activity.fromMap(Map<String, dynamic> map) {
    try {
      return Activity(
        id: map['id'] as String? ?? '',
        eventId: map['eventId'] as String? ?? '',
        title: map['title'] as String? ?? 'Sans titre',
        description: map['description'] as String?,
        dateTime: map['dateTime'] != null
            ? DateTime.parse(map['dateTime'] as String)
            : DateTime.now(),
        location: map['location'] as String?,
        createdBy: map['createdBy'] as String? ?? '',
        participantIds: map['participantIds'] != null
            ? List<String>.from(map['participantIds'])
            : [],
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing Activity from map: $e');
      print('Map content: $map');
      rethrow;
    }
  }
}
