import 'package:equatable/equatable.dart';

/// Entité Poll - Représente un sondage
class Poll extends Equatable {
  final String id;
  final String question;
  final String? description;
  final String eventId;
  final String creatorId;
  final PollType type;
  final List<PollOption> options;
  final DateTime? deadline;
  final bool allowMultipleChoices;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Poll({
    required this.id,
    required this.question,
    this.description,
    required this.eventId,
    required this.creatorId,
    required this.type,
    this.options = const [],
    this.deadline,
    this.allowMultipleChoices = false,
    this.isAnonymous = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Nombre total de votes
  int get totalVotes {
    return options.fold(0, (sum, option) => sum + option.voteCount);
  }

  /// Vérifier si le sondage est fermé
  bool get isClosed {
    if (deadline != null) {
      return deadline!.isBefore(DateTime.now());
    }
    return false;
  }

  /// Vérifier si un utilisateur a voté
  bool hasVoted(String userId) {
    return options.any((option) => option.voterIds.contains(userId));
  }

  /// Obtenir les votes d'un utilisateur
  List<String> getUserVotes(String userId) {
    return options
        .where((option) => option.voterIds.contains(userId))
        .map((option) => option.id)
        .toList();
  }

  /// Option gagnante (la plus votée)
  PollOption? get winningOption {
    if (options.isEmpty) return null;
    return options.reduce((a, b) => a.voteCount > b.voteCount ? a : b);
  }

  /// Copier avec modifications
  Poll copyWith({
    String? id,
    String? question,
    String? description,
    String? eventId,
    String? creatorId,
    PollType? type,
    List<PollOption>? options,
    DateTime? deadline,
    bool? allowMultipleChoices,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Poll(
      id: id ?? this.id,
      question: question ?? this.question,
      description: description ?? this.description,
      eventId: eventId ?? this.eventId,
      creatorId: creatorId ?? this.creatorId,
      type: type ?? this.type,
      options: options ?? this.options,
      deadline: deadline ?? this.deadline,
      allowMultipleChoices: allowMultipleChoices ?? this.allowMultipleChoices,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    question,
    description,
    eventId,
    creatorId,
    type,
    options,
    deadline,
    allowMultipleChoices,
    isAnonymous,
    createdAt,
    updatedAt,
  ];
}

/// Option d'un sondage
class PollOption extends Equatable {
  final String id;
  final String text;
  final List<String> voterIds;
  final String? metadata; // Pour stocker date, lieu, etc.

  const PollOption({
    required this.id,
    required this.text,
    this.voterIds = const [],
    this.metadata,
  });

  int get voteCount => voterIds.length;

  /// Pourcentage de votes (nécessite le total)
  double getPercentage(int totalVotes) {
    if (totalVotes == 0) return 0.0;
    return (voteCount / totalVotes) * 100;
  }

  PollOption copyWith({
    String? id,
    String? text,
    List<String>? voterIds,
    String? metadata,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voterIds: voterIds ?? this.voterIds,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, text, voterIds, metadata];
}

/// Type de sondage
enum PollType {
  date, // Choisir une date
  location, // Choisir un lieu
  activity, // Choisir une activité
  general, // Sondage général personnalisé
}

extension PollTypeExtension on PollType {
  String get displayName {
    switch (this) {
      case PollType.date:
        return 'Date';
      case PollType.location:
        return 'Lieu';
      case PollType.activity:
        return 'Activité';
      case PollType.general:
        return 'Général';
    }
  }

  String get icon {
    switch (this) {
      case PollType.date:
        return '📅';
      case PollType.location:
        return '📍';
      case PollType.activity:
        return '🎯';
      case PollType.general:
        return '📊';
    }
  }
}
