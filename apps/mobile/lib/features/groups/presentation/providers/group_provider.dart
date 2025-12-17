import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group.dart';
import '../../../../core/services/firestore_service.dart';

/// Provider pour gérer les groupes
class GroupProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

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
