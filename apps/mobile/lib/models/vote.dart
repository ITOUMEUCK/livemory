import 'package:json_annotation/json_annotation.dart';

part 'vote.g.dart';

@JsonSerializable()
class Vote {
  final String id;
  final String eventId;
  final String? stepId;
  final String title;
  final String description;
  final VoteType type;
  final List<VoteOption> options;
  final bool allowMultipleChoices;
  final bool isAnonymous;
  final DateTime? deadline;
  final VoteStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vote({
    required this.id,
    required this.eventId,
    this.stepId,
    required this.title,
    required this.description,
    this.type = VoteType.location,
    this.options = const [],
    this.allowMultipleChoices = false,
    this.isAnonymous = false,
    this.deadline,
    this.status = VoteStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);
  Map<String, dynamic> toJson() => _$VoteToJson(this);

  int get totalVotes =>
      options.fold(0, (sum, option) => sum + option.voteCount);
}

@JsonSerializable()
class VoteOption {
  final String id;
  final String voteId;
  final String title;
  final String? description;
  final String? imageUrl;
  final int voteCount;
  final List<String> votedByIds;

  VoteOption({
    required this.id,
    required this.voteId,
    required this.title,
    this.description,
    this.imageUrl,
    this.voteCount = 0,
    this.votedByIds = const [],
  });

  factory VoteOption.fromJson(Map<String, dynamic> json) =>
      _$VoteOptionFromJson(json);
  Map<String, dynamic> toJson() => _$VoteOptionToJson(this);

  VoteOption copyWith({
    String? id,
    String? voteId,
    String? title,
    String? description,
    String? imageUrl,
    int? voteCount,
    List<String>? votedByIds,
  }) {
    return VoteOption(
      id: id ?? this.id,
      voteId: voteId ?? this.voteId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      voteCount: voteCount ?? this.voteCount,
      votedByIds: votedByIds ?? this.votedByIds,
    );
  }
}

enum VoteType {
  @JsonValue('location')
  location,
  @JsonValue('datetime')
  datetime,
  @JsonValue('activity')
  activity,
  @JsonValue('other')
  other,
}

enum VoteStatus {
  @JsonValue('active')
  active,
  @JsonValue('closed')
  closed,
}
