import 'package:equatable/equatable.dart';

/// Entité Group - Représente un groupe d'utilisateurs
class Group extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? photoUrl;
  final String creatorId;
  final List<String> memberIds;
  final List<String> adminIds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final GroupSettings settings;

  const Group({
    required this.id,
    required this.name,
    this.description,
    this.photoUrl,
    required this.creatorId,
    required this.memberIds,
    required this.adminIds,
    required this.createdAt,
    this.updatedAt,
    required this.settings,
  });

  /// Nombre de membres
  int get memberCount => memberIds.length;

  /// Vérifier si un utilisateur est admin
  bool isAdmin(String userId) => adminIds.contains(userId);

  /// Vérifier si un utilisateur est membre
  bool isMember(String userId) => memberIds.contains(userId);

  /// Créer une copie avec modifications
  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? photoUrl,
    String? creatorId,
    List<String>? memberIds,
    List<String>? adminIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    GroupSettings? settings,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    photoUrl,
    creatorId,
    memberIds,
    adminIds,
    createdAt,
    updatedAt,
    settings,
  ];
}

/// Paramètres d'un groupe
class GroupSettings extends Equatable {
  final bool isPrivate;
  final bool allowMemberInvite;
  final bool requireAdminApproval;
  final bool notifyOnNewEvent;
  final bool notifyOnNewPoll;

  const GroupSettings({
    this.isPrivate = false,
    this.allowMemberInvite = true,
    this.requireAdminApproval = false,
    this.notifyOnNewEvent = true,
    this.notifyOnNewPoll = true,
  });

  GroupSettings copyWith({
    bool? isPrivate,
    bool? allowMemberInvite,
    bool? requireAdminApproval,
    bool? notifyOnNewEvent,
    bool? notifyOnNewPoll,
  }) {
    return GroupSettings(
      isPrivate: isPrivate ?? this.isPrivate,
      allowMemberInvite: allowMemberInvite ?? this.allowMemberInvite,
      requireAdminApproval: requireAdminApproval ?? this.requireAdminApproval,
      notifyOnNewEvent: notifyOnNewEvent ?? this.notifyOnNewEvent,
      notifyOnNewPoll: notifyOnNewPoll ?? this.notifyOnNewPoll,
    );
  }

  @override
  List<Object?> get props => [
    isPrivate,
    allowMemberInvite,
    requireAdminApproval,
    notifyOnNewEvent,
    notifyOnNewPoll,
  ];
}
