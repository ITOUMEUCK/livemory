import 'package:flutter/foundation.dart';
import '../../domain/entities/poll.dart';

/// Provider pour gérer l'état des sondages
class PollProvider extends ChangeNotifier {
  List<Poll> _polls = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Poll> get polls => List.unmodifiable(_polls);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupérer tous les sondages
  Future<void> fetchPolls() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data - sondages de test
      _polls = [
        Poll(
          id: 'poll_1',
          question: 'Quelle date pour le week-end ski ?',
          description: 'Choisissez la date qui vous convient le mieux',
          eventId: 'event_1',
          creatorId: 'user_1',
          type: PollType.date,
          deadline: DateTime.now().add(const Duration(days: 3)),
          options: [
            PollOption(
              id: 'opt_1',
              text: '20-21 décembre',
              voterIds: ['user_1', 'user_2', 'user_3', 'user_4', 'user_5'],
              metadata: '2024-12-20',
            ),
            PollOption(
              id: 'opt_2',
              text: '27-28 décembre',
              voterIds: ['user_6', 'user_7'],
              metadata: '2024-12-27',
            ),
            PollOption(
              id: 'opt_3',
              text: '3-4 janvier',
              voterIds: ['user_8'],
              metadata: '2025-01-03',
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Poll(
          id: 'poll_2',
          question: 'Où pour la soirée jeux ?',
          description: 'Vote pour le lieu de la soirée',
          eventId: 'event_2',
          creatorId: 'user_2',
          type: PollType.location,
          options: [
            PollOption(
              id: 'opt_4',
              text: 'Chez Marc',
              voterIds: ['user_1', 'user_2', 'user_3'],
            ),
            PollOption(
              id: 'opt_5',
              text: 'Chez Julie',
              voterIds: ['user_4', 'user_5'],
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Poll(
          id: 'poll_3',
          question: 'Quelle activité pour samedi ?',
          eventId: 'event_3',
          creatorId: 'user_1',
          type: PollType.activity,
          allowMultipleChoices: true,
          options: [
            PollOption(
              id: 'opt_6',
              text: 'Randonnée 🥾',
              voterIds: ['user_1', 'user_2', 'user_3', 'user_4'],
            ),
            PollOption(
              id: 'opt_7',
              text: 'Vélo 🚴',
              voterIds: ['user_1', 'user_5'],
            ),
            PollOption(id: 'opt_8', text: 'Piscine 🏊', voterIds: ['user_6']),
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ];
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des sondages';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer un nouveau sondage
  Future<Poll?> createPoll({
    required String question,
    String? description,
    required String eventId,
    required String creatorId,
    required PollType type,
    required List<String> optionTexts,
    DateTime? deadline,
    bool allowMultipleChoices = false,
    bool isAnonymous = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final options = optionTexts
          .asMap()
          .entries
          .map(
            (entry) => PollOption(
              id: 'opt_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
              text: entry.value,
            ),
          )
          .toList();

      final newPoll = Poll(
        id: 'poll_${DateTime.now().millisecondsSinceEpoch}',
        question: question,
        description: description,
        eventId: eventId,
        creatorId: creatorId,
        type: type,
        options: options,
        deadline: deadline,
        allowMultipleChoices: allowMultipleChoices,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
      );

      _polls.insert(0, newPoll);
      notifyListeners();
      return newPoll;
    } catch (e) {
      _errorMessage = 'Erreur lors de la création du sondage';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Voter pour une ou plusieurs options
  Future<bool> vote({
    required String pollId,
    required String userId,
    required List<String> optionIds,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final pollIndex = _polls.indexWhere((p) => p.id == pollId);
      if (pollIndex == -1) return false;

      final poll = _polls[pollIndex];

      // Vérifier si le sondage est fermé
      if (poll.isClosed) {
        _errorMessage = 'Ce sondage est fermé';
        notifyListeners();
        return false;
      }

      // Retirer les votes précédents de l'utilisateur
      final updatedOptions = poll.options.map((option) {
        final newVoterIds = List<String>.from(option.voterIds)..remove(userId);
        return option.copyWith(voterIds: newVoterIds);
      }).toList();

      // Ajouter les nouveaux votes
      final finalOptions = updatedOptions.map((option) {
        if (optionIds.contains(option.id)) {
          final newVoterIds = List<String>.from(option.voterIds)..add(userId);
          return option.copyWith(voterIds: newVoterIds);
        }
        return option;
      }).toList();

      _polls[pollIndex] = poll.copyWith(
        options: finalOptions,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors du vote';
      notifyListeners();
      return false;
    }
  }

  /// Supprimer un vote
  Future<bool> removeVote({
    required String pollId,
    required String userId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final pollIndex = _polls.indexWhere((p) => p.id == pollId);
      if (pollIndex == -1) return false;

      final poll = _polls[pollIndex];

      final updatedOptions = poll.options.map((option) {
        final newVoterIds = List<String>.from(option.voterIds)..remove(userId);
        return option.copyWith(voterIds: newVoterIds);
      }).toList();

      _polls[pollIndex] = poll.copyWith(
        options: updatedOptions,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du vote';
      notifyListeners();
      return false;
    }
  }

  /// Supprimer un sondage
  Future<bool> deletePoll(String pollId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _polls.removeWhere((p) => p.id == pollId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du sondage';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer les sondages d'un événement
  List<Poll> getPollsByEvent(String eventId) {
    return _polls.where((p) => p.eventId == eventId).toList();
  }

  /// Récupérer les sondages actifs (non fermés)
  List<Poll> get activePolls {
    return _polls.where((p) => !p.isClosed).toList();
  }

  /// Récupérer les sondages fermés
  List<Poll> get closedPolls {
    return _polls.where((p) => p.isClosed).toList();
  }
}
