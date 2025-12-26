import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/event.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/domain/entities/notification.dart'
    as app_notification;

/// Provider pour gérer l'état des événements
class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  NotificationProvider? _notificationProvider;

  // Injecter le NotificationProvider
  void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Event> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupérer tous les événements accessibles à l'utilisateur
  /// (événements où il est participant OU événements des groupes dont il est membre)
  Future<void> fetchEvents({
    String? groupId,
    String? userId,
    List<String>? userGroupIds,
  }) async {
    print('EventProvider.fetchEvents - Début');
    print('  groupId: $groupId');
    print('  userId: $userId');
    print('  userGroupIds: $userGroupIds');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (groupId != null) {
        // Récupérer les événements d'un groupe spécifique
        print('  Mode: événements d\'un groupe spécifique');
        final querySnapshot = await _firestoreService.query(
          'events',
          field: 'groupId',
          isEqualTo: groupId,
          orderBy: 'startDate',
          descending: false,
        );
        _events = querySnapshot.docs.map(_eventFromFirestore).toList();
        print('  Événements trouvés: ${_events.length}');
      } else if (userId != null) {
        print('  Mode: tous les événements de l\'utilisateur');
        // Charger tous les événements accessibles à l'utilisateur
        final allEvents = <Event>[];

        // 1. Événements où l'utilisateur est participant
        print('  1. Recherche événements où userId est participant...');
        print('  1. Recherche événements où userId est participant...');
        final participantQuery = await _firestoreService.query(
          'events',
          field: 'participantIds',
          arrayContains: userId,
        );
        allEvents.addAll(participantQuery.docs.map(_eventFromFirestore));
        print('     -> ${participantQuery.docs.length} événements trouvés');

        // 2. Événements des groupes dont l'utilisateur est membre
        if (userGroupIds != null && userGroupIds.isNotEmpty) {
          print('  2. Recherche événements des groupes: $userGroupIds');
          for (final groupId in userGroupIds) {
            print('     Groupe $groupId...');
            final groupEventsQuery = await _firestoreService.query(
              'events',
              field: 'groupId',
              isEqualTo: groupId,
            );
            print('       -> ${groupEventsQuery.docs.length} événements');
            final groupEvents = groupEventsQuery.docs
                .map(_eventFromFirestore)
                .toList();
            // Ajouter seulement les événements qui ne sont pas déjà dans la liste
            for (final event in groupEvents) {
              if (!allEvents.any((e) => e.id == event.id)) {
                allEvents.add(event);
                print('       Ajouté: ${event.title}');
              } else {
                print('       Déjà présent: ${event.title}');
              }
            }
          }
        } else {
          print('  2. Aucun groupe fourni, skip recherche par groupes');
        }

        print('  Total événements avant tri: ${allEvents.length}');

        print('  Total événements avant tri: ${allEvents.length}');

        // Trier par date
        allEvents.sort((a, b) {
          final aDate = a.startDate ?? a.createdAt;
          final bDate = b.startDate ?? b.createdAt;
          return aDate.compareTo(bDate);
        });

        _events = allEvents;
        print('  Total événements final: ${_events.length}');
      } else {
        print('  Mode: tous les événements (pas de filtre)');
        // Récupérer tous les événements
        final querySnapshot = await _firestoreService.query(
          'events',
          orderBy: 'startDate',
          descending: false,
        );
        _events = querySnapshot.docs.map(_eventFromFirestore).toList();
        print('  Événements trouvés: ${_events.length}');
      }

      _isLoading = false;
      notifyListeners();
      print('EventProvider.fetchEvents - Fin avec succès');
    } catch (e) {
      print('EventProvider.fetchEvents - ERREUR: $e');
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

      // Notifier tous les membres du groupe de la création de l'événement
      if (_notificationProvider != null) {
        print(
          'EventProvider: Envoi des notifications aux membres du groupe $groupId',
        );
        final groupDoc = await _firestoreService.read('groups', groupId);
        if (groupDoc.exists) {
          final groupData = groupDoc.data() as Map<String, dynamic>;
          final groupName = groupData['name'] as String;
          final memberIds = List<String>.from(groupData['memberIds'] ?? []);

          // Notifier tous les membres sauf le créateur
          for (final memberId in memberIds) {
            if (memberId != creatorId) {
              await _notificationProvider!.createNotification(
                userId: memberId,
                type: app_notification.NotificationType.eventUpdate,
                title: 'Nouvel événement',
                message:
                    'Un nouvel événement "$title" a été créé dans le groupe "$groupName"',
                metadata: {
                  'eventId': eventId,
                  'eventTitle': title,
                  'groupId': groupId,
                  'groupName': groupName,
                  'creatorId': creatorId,
                },
              );
            }
          }
          print(
            'EventProvider: ${memberIds.length - 1} notifications envoyées',
          );
        }
      }

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
      print('respondToEvent: eventId=$eventId, userId=$userId, status=$status');

      final index = _events.indexWhere((e) => e.id == eventId);
      if (index == -1) {
        print('respondToEvent: Événement non trouvé');
        return false;
      }

      final event = _events[index];
      print('respondToEvent: Événement trouvé - ${event.title}');
      print('  participantIds avant: ${event.participantIds}');
      print('  maybeIds avant: ${event.maybeIds}');
      print('  declinedIds avant: ${event.declinedIds}');

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
          print('  ✅ Ajouté à participantIds');
          break;
        case ParticipationStatus.maybe:
          newMaybeIds.add(userId);
          print('  🤔 Ajouté à maybeIds');
          break;
        case ParticipationStatus.declined:
          newDeclinedIds.add(userId);
          print('  ❌ Ajouté à declinedIds');
          break;
      }

      print('  participantIds après: $newParticipantIds');
      print('  maybeIds après: $newMaybeIds');
      print('  declinedIds après: $newDeclinedIds');

      final updatedEvent = event.copyWith(
        participantIds: newParticipantIds,
        maybeIds: newMaybeIds,
        declinedIds: newDeclinedIds,
        updatedAt: DateTime.now(),
      );

      final result = await updateEvent(updatedEvent);
      print('respondToEvent: Mise à jour réussie = $result');
      return result;
    } catch (e) {
      print('respondToEvent ERROR: $e');
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

  /// Récupérer les événements à venir et en cours (excluant ceux refusés par l'utilisateur)
  List<Event> getUpcomingEventsForUser(String userId) {
    final now = DateTime.now();
    return _events.where((e) {
      // Exclure les événements refusés par cet utilisateur
      if (e.declinedIds.contains(userId)) {
        return false;
      }

      final startDate = e.startDate ?? e.createdAt;
      final endDate = e.endDate;

      // Événement à venir/en cours si :
      // 1. Il a une date de fin et elle est dans le futur (événement en cours ou futur)
      if (endDate != null && endDate.isAfter(now)) {
        return true;
      }

      // 2. OU il a une date de début future
      if (e.startDate != null && e.startDate!.isAfter(now)) {
        return true;
      }

      return false;
    }).toList()..sort((a, b) {
      final aDate = a.startDate ?? a.createdAt;
      final bDate = b.startDate ?? b.createdAt;
      return aDate.compareTo(bDate);
    });
  }

  /// Récupérer les événements à venir (et en cours)
  List<Event> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((e) {
      final startDate = e.startDate ?? e.createdAt;
      final endDate = e.endDate;

      // Événement à venir/en cours si :
      // 1. Il a une date de fin et elle est dans le futur (événement en cours ou futur)
      if (endDate != null && endDate.isAfter(now)) {
        return true;
      }

      // 2. OU il a une date de début future
      if (e.startDate != null && e.startDate!.isAfter(now)) {
        return true;
      }

      return false;
    }).toList()..sort((a, b) {
      final aDate = a.startDate ?? a.createdAt;
      final bDate = b.startDate ?? b.createdAt;
      return aDate.compareTo(bDate);
    });
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
