import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity.dart';

/// Provider pour gérer les activités des événements
class ActivityProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Récupère toutes les activités d'un événement
  Future<void> fetchActivities(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('ActivityProvider: Fetching activities for eventId=$eventId');
      final snapshot = await _firestore
          .collection('activities')
          .where('eventId', isEqualTo: eventId)
          // .orderBy('dateTime') // Retiré : nécessite un index composite
          .get();

      print('ActivityProvider: Found ${snapshot.docs.length} activities');

      _activities = snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          print('ActivityProvider: Processing activity - ${data['title']}');
          return Activity.fromMap(data);
        } catch (e) {
          print('ActivityProvider ERROR parsing activity: $e');
          print('ActivityProvider: Document data: ${doc.data()}');
          rethrow;
        }
      }).toList();

      // Trier en mémoire au lieu de dans Firestore
      _activities.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      print(
        'ActivityProvider: Successfully loaded ${_activities.length} activities',
      );
    } catch (e) {
      print('ActivityProvider ERROR: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute une nouvelle activité
  Future<void> addActivity(Activity activity) async {
    try {
      await _firestore
          .collection('activities')
          .doc(activity.id)
          .set(activity.toMap());

      _activities.add(activity);
      _activities.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Met à jour une activité
  Future<void> updateActivity(Activity activity) async {
    try {
      await _firestore
          .collection('activities')
          .doc(activity.id)
          .update(activity.toMap());

      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = activity;
        _activities.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Supprime une activité
  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore.collection('activities').doc(activityId).delete();

      _activities.removeWhere((a) => a.id == activityId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Filtre les activités par événement
  List<Activity> getActivitiesByEvent(String eventId) {
    return _activities.where((a) => a.eventId == eventId).toList();
  }

  /// Gérer la participation à une activité
  Future<bool> toggleActivityParticipation({
    required String activityId,
    required String userId,
  }) async {
    try {
      final index = _activities.indexWhere((a) => a.id == activityId);
      if (index == -1) return false;

      final activity = _activities[index];
      final participantIds = List<String>.from(activity.participantIds);

      // Toggle : si déjà participant, retirer, sinon ajouter
      if (participantIds.contains(userId)) {
        participantIds.remove(userId);
        print('🔴 Utilisateur $userId retiré de l\'activité ${activity.title}');
      } else {
        participantIds.add(userId);
        print('🟢 Utilisateur $userId ajouté à l\'activité ${activity.title}');
      }

      final updatedActivity = activity.copyWith(
        participantIds: participantIds,
        updatedAt: DateTime.now(),
      );

      await updateActivity(updatedActivity);
      return true;
    } catch (e) {
      print('toggleActivityParticipation ERROR: $e');
      _error =
          'Erreur lors de la modification de la participation: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
