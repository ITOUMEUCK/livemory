import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/domain/entities/notification.dart'
    as app_notification;

/// Provider pour gérer les groupes
class GroupProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  NotificationProvider? _notificationProvider;

  // Injecter le NotificationProvider
  void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  List<Group> _groups = [];
  Group? _selectedGroup;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Group> get groups => _groups;
  Group? get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupérer tous les groupes de l'utilisateur
  Future<void> fetchGroups(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final querySnapshot = await _firestoreService.query(
        'groups',
        field: 'memberIds',
        arrayContains: userId,
      );

      _groups = querySnapshot.docs.map((doc) {
        return _groupFromFirestore(doc);
      }).toList();

      // Trier par date de création (plus récents d'abord)
      _groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors du chargement des groupes: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Créer un nouveau groupe
  Future<bool> createGroup({
    required String name,
    String? description,
    String? photoUrl,
    required String creatorId,
    GroupSettings? settings,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final groupData = {
        'name': name,
        'description': description,
        'photoUrl': photoUrl,
        'creatorId': creatorId,
        'memberIds': [creatorId],
        'adminIds': [creatorId],
        'settings': _settingsToMap(settings ?? const GroupSettings()),
      };

      final groupId = await _firestoreService.create('groups', groupData);

      final newGroup = Group(
        id: groupId,
        name: name,
        description: description,
        photoUrl: photoUrl,
        creatorId: creatorId,
        memberIds: [creatorId],
        adminIds: [creatorId],
        createdAt: DateTime.now(),
        settings: settings ?? const GroupSettings(),
      );

      _groups.insert(0, newGroup);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la création du groupe: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Mettre à jour un groupe
  Future<bool> updateGroup(Group updatedGroup) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final groupData = {
        'name': updatedGroup.name,
        'description': updatedGroup.description,
        'photoUrl': updatedGroup.photoUrl,
        'memberIds': updatedGroup.memberIds,
        'adminIds': updatedGroup.adminIds,
        'settings': _settingsToMap(updatedGroup.settings),
      };

      await _firestoreService.update('groups', updatedGroup.id, groupData);

      final index = _groups.indexWhere((g) => g.id == updatedGroup.id);
      if (index != -1) {
        _groups[index] = updatedGroup.copyWith(updatedAt: DateTime.now());
        if (_selectedGroup?.id == updatedGroup.id) {
          _selectedGroup = _groups[index];
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Erreur lors de la mise à jour du groupe: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Supprimer un groupe
  Future<bool> deleteGroup(String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.delete('groups', groupId);

      _groups.removeWhere((g) => g.id == groupId);
      if (_selectedGroup?.id == groupId) {
        _selectedGroup = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Erreur lors de la suppression du groupe: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Ajouter un membre au groupe
  Future<bool> addMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final group = _groups.firstWhere((g) => g.id == groupId);
      final updatedGroup = group.copyWith(
        memberIds: [...group.memberIds, userId],
      );
      return await updateGroup(updatedGroup);
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout du membre: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Ajouter plusieurs membres au groupe
  Future<bool> addMembers(
    String groupId,
    List<String> userIds, {
    String? invitedBy,
  }) async {
    try {
      print('GroupProvider.addMembers - Début');
      print('groupId: $groupId');
      print('userIds: $userIds');
      print('Nombre de groupes chargés: ${_groups.length}');

      final group = _groups.firstWhere(
        (g) => g.id == groupId,
        orElse: () =>
            throw Exception('Groupe $groupId non trouvé dans la liste'),
      );

      print('Groupe trouvé: ${group.name}');
      print('Membres actuels: ${group.memberIds}');

      final newMemberIds = {...group.memberIds, ...userIds}.toList();
      print('Nouveaux membres après fusion: $newMemberIds');

      final updatedGroup = group.copyWith(memberIds: newMemberIds);
      print('Appel updateGroup...');

      final success = await updateGroup(updatedGroup);
      print('updateGroup résultat: $success');

      // Envoyer des notifications aux nouveaux membres
      if (success && _notificationProvider != null) {
        print('Envoi des notifications...');

        // Récupérer les événements actifs du groupe
        final groupEventsQuery = await _firestoreService.query(
          'events',
          field: 'groupId',
          isEqualTo: groupId,
        );

        final now = DateTime.now();
        final activeEvents = groupEventsQuery.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final endDate = data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null;
          // Événement actif = pas encore terminé
          return endDate == null || endDate.isAfter(now);
        }).toList();

        print('Événements actifs du groupe: ${activeEvents.length}');

        for (final userId in userIds) {
          if (!group.memberIds.contains(userId)) {
            print('Envoi notification à $userId');

            // Notification d'ajout au groupe
            await _notificationProvider!.createNotification(
              userId: userId,
              type: app_notification.NotificationType.invitation,
              title: 'Invitation à un groupe',
              message: 'Vous avez été ajouté au groupe "${group.name}"',
              metadata: {
                'groupId': groupId,
                'groupName': group.name,
                'invitedBy': invitedBy,
              },
            );

            // Notifications pour chaque événement actif du groupe
            for (final eventDoc in activeEvents) {
              final eventData = eventDoc.data() as Map<String, dynamic>;
              final eventTitle = eventData['title'] as String;

              await _notificationProvider!.createNotification(
                userId: userId,
                type: app_notification.NotificationType.eventUpdate,
                title: 'Événement en cours',
                message:
                    'Le groupe "${group.name}" a un événement actif: "$eventTitle"',
                metadata: {
                  'eventId': eventDoc.id,
                  'eventTitle': eventTitle,
                  'groupId': groupId,
                  'groupName': group.name,
                },
              );
            }
          }
        }
      }

      print('GroupProvider.addMembers - Fin avec succès: $success');
      return success;
    } catch (e) {
      print('GroupProvider.addMembers - Erreur: $e');
      _errorMessage = 'Erreur lors de l\'ajout des membres: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Retirer un membre du groupe
  Future<bool> removeMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final group = _groups.firstWhere((g) => g.id == groupId);
      final memberIds = group.memberIds.where((id) => id != userId).toList();
      final adminIds = group.adminIds.where((id) => id != userId).toList();

      final updatedGroup = group.copyWith(
        memberIds: memberIds,
        adminIds: adminIds,
      );
      return await updateGroup(updatedGroup);
    } catch (e) {
      _errorMessage = 'Erreur lors du retrait du membre: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Promouvoir un membre en admin
  Future<bool> promoteToAdmin({
    required String groupId,
    required String userId,
  }) async {
    try {
      final group = _groups.firstWhere((g) => g.id == groupId);
      if (!group.adminIds.contains(userId)) {
        final updatedGroup = group.copyWith(
          adminIds: [...group.adminIds, userId],
        );
        return await updateGroup(updatedGroup);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la promotion: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Rétrograder un admin en membre normal
  Future<bool> demoteAdmin({
    required String groupId,
    required String userId,
  }) async {
    try {
      final group = _groups.firstWhere((g) => g.id == groupId);
      if (group.adminIds.contains(userId)) {
        final updatedGroup = group.copyWith(
          adminIds: group.adminIds.where((id) => id != userId).toList(),
        );
        return await updateGroup(updatedGroup);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la rétrogradation: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Sélectionner un groupe
  void selectGroup(String groupId) {
    _selectedGroup = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => _groups.first,
    );
    notifyListeners();
  }

  /// Désélectionner le groupe
  void clearSelectedGroup() {
    _selectedGroup = null;
    notifyListeners();
  }

  /// Nettoyer les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== MÉTHODES PRIVÉES ====================

  /// Convertir un document Firestore en Group
  Group _groupFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Group(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      photoUrl: data['photoUrl'] as String?,
      creatorId: data['creatorId'] as String,
      memberIds: List<String>.from(data['memberIds'] ?? []),
      adminIds: List<String>.from(data['adminIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      settings: _settingsFromMap(data['settings'] as Map<String, dynamic>?),
    );
  }

  /// Convertir GroupSettings en Map
  Map<String, dynamic> _settingsToMap(GroupSettings settings) {
    return {
      'isPrivate': settings.isPrivate,
      'allowMemberInvite': settings.allowMemberInvite,
    };
  }

  /// Convertir Map en GroupSettings
  GroupSettings _settingsFromMap(Map<String, dynamic>? data) {
    if (data == null) return const GroupSettings();

    return GroupSettings(
      isPrivate: data['isPrivate'] as bool? ?? false,
      allowMemberInvite: data['allowMemberInvite'] as bool? ?? false,
    );
  }
}
