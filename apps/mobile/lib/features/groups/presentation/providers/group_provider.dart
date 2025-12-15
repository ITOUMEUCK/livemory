import 'package:flutter/foundation.dart';
import '../../domain/entities/group.dart';

/// Provider pour gérer les groupes
class GroupProvider with ChangeNotifier {
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
  Future<void> fetchGroups() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // TODO: Remplacer par l'appel API réel
      await Future.delayed(const Duration(seconds: 1));

      // Données de test
      _groups = [
        Group(
          id: 'group_1',
          name: 'Famille 👨‍👩‍👧‍👦',
          description: 'Groupe familial pour organiser nos moments ensemble',
          creatorId: 'user_123',
          memberIds: List.generate(12, (i) => 'user_$i'),
          adminIds: ['user_123'],
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          settings: const GroupSettings(),
        ),
        Group(
          id: 'group_2',
          name: 'Amis Promo 2020',
          description: 'Les meilleurs souvenirs de promo !',
          creatorId: 'user_123',
          memberIds: List.generate(25, (i) => 'user_$i'),
          adminIds: ['user_123', 'user_1'],
          createdAt: DateTime.now().subtract(const Duration(days: 180)),
          settings: const GroupSettings(isPrivate: true),
        ),
        Group(
          id: 'group_3',
          name: 'Sport & Fun ⚽',
          description: 'Groupe pour nos activités sportives',
          creatorId: 'user_456',
          memberIds: List.generate(8, (i) => 'user_$i'),
          adminIds: ['user_456'],
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          settings: const GroupSettings(allowMemberInvite: true),
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors du chargement des groupes';
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

      // TODO: Remplacer par l'appel API réel
      await Future.delayed(const Duration(seconds: 1));

      final newGroup = Group(
        id: 'group_${DateTime.now().millisecondsSinceEpoch}',
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
      _errorMessage = 'Erreur lors de la création du groupe';
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

      // TODO: Remplacer par l'appel API réel
      await Future.delayed(const Duration(milliseconds: 500));

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
      _errorMessage = 'Erreur lors de la mise à jour du groupe';
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

      // TODO: Remplacer par l'appel API réel
      await Future.delayed(const Duration(milliseconds: 500));

      _groups.removeWhere((g) => g.id == groupId);
      if (_selectedGroup?.id == groupId) {
        _selectedGroup = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la suppression du groupe';
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
      _errorMessage = 'Erreur lors de l\'ajout du membre';
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
      _errorMessage = 'Erreur lors du retrait du membre';
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
      _errorMessage = 'Erreur lors de la promotion';
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
}
