import 'package:flutter/foundation.dart';
import '../../domain/entities/event.dart';

/// Provider pour gérer l'état des événements
class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Event> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupérer tous les événements
  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data - événements de test
      _events = [
        Event(
          id: 'event_1',
          title: 'Week-end à la montagne ⛷️',
          description: 'Séjour au ski dans les Alpes',
          groupId: 'group_1',
          creatorId: 'user_1',
          startDate: DateTime(2024, 12, 20, 9, 0),
          endDate: DateTime(2024, 12, 21, 18, 0),
          location: 'Chamonix, France',
          status: EventStatus.planned,
          participantIds: [
            'user_1',
            'user_2',
            'user_3',
            'user_4',
            'user_5',
            'user_6',
            'user_7',
            'user_8',
          ],
          maybeIds: ['user_9', 'user_10'],
          declinedIds: ['user_11'],
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        Event(
          id: 'event_2',
          title: 'Soirée jeux 🎮',
          description: 'Mario Kart et pizza !',
          groupId: 'group_2',
          creatorId: 'user_1',
          startDate: DateTime(2024, 12, 26, 20, 0),
          endDate: DateTime(2024, 12, 26, 23, 30),
          location: 'Chez Marc',
          status: EventStatus.planned,
          participantIds: ['user_1', 'user_2', 'user_3', 'user_4', 'user_5'],
          maybeIds: [],
          declinedIds: [],
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
        Event(
          id: 'event_3',
          title: 'Barbecue d\'été 🍖',
          description: 'Grand BBQ au parc pour fêter l\'été',
          groupId: 'group_1',
          creatorId: 'user_2',
          startDate: DateTime(2025, 1, 5, 12, 0),
          endDate: DateTime(2025, 1, 5, 17, 0),
          location: 'Parc de la Tête d\'Or',
          status: EventStatus.planned,
          participantIds: ['user_1', 'user_2', 'user_3'],
          maybeIds: ['user_4', 'user_5', 'user_6'],
          declinedIds: [],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Event(
          id: 'event_4',
          title: 'Match de foot ⚽',
          description: 'Finale de la Ligue des Champions',
          groupId: 'group_3',
          creatorId: 'user_3',
          startDate: DateTime(2024, 12, 28, 21, 0),
          endDate: DateTime(2024, 12, 28, 23, 0),
          location: 'Sports Bar',
          status: EventStatus.planned,
          participantIds: ['user_1', 'user_2', 'user_3', 'user_4'],
          maybeIds: ['user_5'],
          declinedIds: ['user_6'],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Event(
          id: 'event_5',
          title: 'Concert 🎵',
          description: 'Festival de musique électro',
          groupId: 'group_2',
          creatorId: 'user_1',
          startDate: DateTime(2025, 1, 15, 19, 0),
          endDate: DateTime(2025, 1, 16, 2, 0),
          location: 'Zénith de Paris',
          status: EventStatus.planned,
          participantIds: ['user_1', 'user_2'],
          maybeIds: ['user_3', 'user_4', 'user_5', 'user_6'],
          declinedIds: [],
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ];
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des événements';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer un nouvel événement
  Future<Event?> createEvent({
    required String title,
    String? description,
    required String groupId,
    required String creatorId,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final newEvent = Event(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        groupId: groupId,
        creatorId: creatorId,
        startDate: startDate,
        endDate: endDate,
        location: location,
        status: EventStatus.planned,
        participantIds: [creatorId],
        createdAt: DateTime.now(),
      );

      _events.insert(0, newEvent);
      notifyListeners();
      return newEvent;
    } catch (e) {
      _errorMessage = 'Erreur lors de la création de l\'événement';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mettre à jour un événement
  Future<bool> updateEvent(Event updatedEvent) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _events.indexWhere((e) => e.id == updatedEvent.id);
      if (index != -1) {
        _events[index] = updatedEvent;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de l\'événement';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprimer un événement
  Future<bool> deleteEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _events.removeWhere((e) => e.id == eventId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de l\'événement';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marquer la participation à un événement
  Future<bool> respondToEvent({
    required String eventId,
    required String userId,
    required ParticipationStatus status,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _events.indexWhere((e) => e.id == eventId);
      if (index == -1) return false;

      final event = _events[index];

      // Retirer l'utilisateur de toutes les listes
      final newParticipantIds = List<String>.from(event.participantIds)
        ..remove(userId);
      final newMaybeIds = List<String>.from(event.maybeIds)..remove(userId);
      final newDeclinedIds = List<String>.from(event.declinedIds)
        ..remove(userId);

      // Ajouter à la bonne liste
      switch (status) {
        case ParticipationStatus.participating:
          newParticipantIds.add(userId);
          break;
        case ParticipationStatus.maybe:
          newMaybeIds.add(userId);
          break;
        case ParticipationStatus.declined:
          newDeclinedIds.add(userId);
          break;
      }

      _events[index] = event.copyWith(
        participantIds: newParticipantIds,
        maybeIds: newMaybeIds,
        declinedIds: newDeclinedIds,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la réponse à l\'événement';
      notifyListeners();
      return false;
    }
  }

  /// Récupérer les événements d'un groupe spécifique
  List<Event> getEventsByGroup(String groupId) {
    return _events.where((e) => e.groupId == groupId).toList();
  }

  /// Récupérer les événements à venir
  List<Event> get upcomingEvents {
    final now = DateTime.now();
    return _events
        .where((e) => e.startDate != null && e.startDate!.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDate!.compareTo(b.startDate!));
  }

  /// Récupérer les événements passés
  List<Event> get pastEvents {
    return _events.where((e) => e.isPast).toList()..sort(
      (a, b) =>
          (b.startDate ?? b.createdAt).compareTo(a.startDate ?? a.createdAt),
    );
  }
}

/// Statut de participation à un événement
enum ParticipationStatus { participating, maybe, declined }
