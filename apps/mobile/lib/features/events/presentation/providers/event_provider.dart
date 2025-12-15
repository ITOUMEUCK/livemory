import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/event.dart';
import '../../../../core/services/firestore_service.dart';

/// Provider pour gérer l'état des événements
class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Event> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupérer tous les événements (ou par groupe)
  Future<void> fetchEvents({String? groupId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot;

      if (groupId != null) {
        // Récupérer les événements d'un groupe spécifique
        querySnapshot = await _firestoreService.query(
          'events',
          field: 'groupId',
          isEqualTo: groupId,
          orderBy: 'startDate',
          descending: false,
        );
      } else {
        // Récupérer tous les événements
        querySnapshot = await _firestoreService.query(
          'events',
          orderBy: 'startDate',
          descending: false,
        );
      }

      _events = querySnapshot.docs.map((doc) {
        return _eventFromFirestore(doc);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Erreur lors du chargement des événements: ${e.toString()}';
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
      final eventData = {
        'title': title,
        'description': description,
        'groupId': groupId,
        'creatorId': creatorId,
        'startDate': startDate != null ? Timestamp.fromDate(startDate) : null,
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'location': location,
        'status': EventStatus.planned.toString().split('.').last,
        'participantIds': [creatorId],
        'maybeIds': <String>[],
        'declinedIds': <String>[],
      };

      final eventId = await _firestoreService.create('events', eventData);

      final newEvent = Event(
        id: eventId,
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
      _isLoading = false;
      notifyListeners();
      return newEvent;
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Erreur lors de la création de l\'événement: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Mettre à jour un événement
  Future<bool> updateEvent(Event updatedEvent) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final eventData = {
        'title': updatedEvent.title,
        'description': updatedEvent.description,
        'startDate': updatedEvent.startDate != null
            ? Timestamp.fromDate(updatedEvent.startDate!)
            : null,
        'endDate': updatedEvent.endDate != null
            ? Timestamp.fromDate(updatedEvent.endDate!)
            : null,
        'location': updatedEvent.location,
        'status': updatedEvent.status.toString().split('.').last,
        'participantIds': updatedEvent.participantIds,
        'maybeIds': updatedEvent.maybeIds,
        'declinedIds': updatedEvent.declinedIds,
      };

      await _firestoreService.update('events', updatedEvent.id, eventData);

      final index = _events.indexWhere((e) => e.id == updatedEvent.id);
      if (index != -1) {
        _events[index] = updatedEvent.copyWith(updatedAt: DateTime.now());
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Erreur lors de la mise à jour de l\'événement: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Supprimer un événement
  Future<bool> deleteEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.delete('events', eventId);

      _events.removeWhere((e) => e.id == eventId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Erreur lors de la suppression de l\'événement: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Marquer la participation à un événement
  Future<bool> respondToEvent({
    required String eventId,
    required String userId,
    required ParticipationStatus status,
  }) async {
    try {
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

      final updatedEvent = event.copyWith(
        participantIds: newParticipantIds,
        maybeIds: newMaybeIds,
        declinedIds: newDeclinedIds,
        updatedAt: DateTime.now(),
      );

      return await updateEvent(updatedEvent);
    } catch (e) {
      _errorMessage =
          'Erreur lors de la réponse à l\'événement: ${e.toString()}';
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

  /// Nettoyer les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== MÉTHODES PRIVÉES ====================

  /// Convertir un document Firestore en Event
  Event _eventFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Event(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String?,
      groupId: data['groupId'] as String,
      creatorId: data['creatorId'] as String,
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      location: data['location'] as String?,
      status: _statusFromString(data['status'] as String?),
      participantIds: List<String>.from(data['participantIds'] ?? []),
      maybeIds: List<String>.from(data['maybeIds'] ?? []),
      declinedIds: List<String>.from(data['declinedIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convertir string en EventStatus
  EventStatus _statusFromString(String? status) {
    switch (status) {
      case 'planned':
        return EventStatus.planned;
      case 'ongoing':
        return EventStatus.ongoing;
      case 'completed':
        return EventStatus.completed;
      case 'cancelled':
        return EventStatus.cancelled;
      default:
        return EventStatus.planned;
    }
  }
}

/// Statut de participation à un événement
enum ParticipationStatus { participating, maybe, declined }
