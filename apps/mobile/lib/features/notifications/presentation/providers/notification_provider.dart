import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/services/firestore_service.dart';
import 'package:mobile/features/notifications/domain/entities/notification.dart';

/// Provider pour la gestion des notifications
class NotificationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Nombre de notifications non lues
  int get unreadCount => _notifications.where((notif) => !notif.isRead).length;

  /// Notifications non lues
  List<Notification> get unreadNotifications =>
      _notifications.where((notif) => !notif.isRead).toList();

  /// Notifications lues
  List<Notification> get readNotifications =>
      _notifications.where((notif) => notif.isRead).toList();

  /// Récupérer toutes les notifications d'un utilisateur
  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firestoreService.query(
        'notifications',
        field: 'userId',
        isEqualTo: userId,
      );

      _notifications = querySnapshot.docs
          .map((doc) => _notificationFromFirestore(doc))
          .toList();

      // Trier par date décroissante
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des notifications: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Créer une nouvelle notification
  Future<Notification?> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notificationData = {
        'userId': userId,
        'type': _typeToString(type),
        'title': title,
        'message': message,
        'metadata': metadata ?? {},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final notificationId = await _firestoreService.create(
        'notifications',
        notificationData,
      );

      // Récupérer le document créé
      final docSnapshot = await _firestoreService.read(
        'notifications',
        notificationId,
      );
      final newNotification = _notificationFromFirestore(docSnapshot);

      _notifications.insert(0, newNotification);
      notifyListeners();

      return newNotification;
    } catch (e) {
      _errorMessage = 'Erreur lors de la création de la notification: $e';
      notifyListeners();
      debugPrint(_errorMessage);
      return null;
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestoreService.update('notifications', notificationId, {
        'isRead': true,
      });

      final index = _notifications.indexWhere(
        (notif) => notif.id == notificationId,
      );
      if (index != -1) {
        _notifications[index] = _notifications[index].markAsRead();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du marquage comme lu: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Marquer une notification comme non lue
  Future<void> markAsUnread(String notificationId) async {
    try {
      await _firestoreService.update('notifications', notificationId, {
        'isRead': false,
      });

      final index = _notifications.indexWhere(
        (notif) => notif.id == notificationId,
      );
      if (index != -1) {
        _notifications[index] = _notifications[index].markAsUnread();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du marquage comme non lu: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead(String userId) async {
    try {
      // Batch update pour toutes les notifications non lues de l'utilisateur
      final batch = FirebaseFirestore.instance.batch();
      final unreadNotifs = _notifications.where((n) => !n.isRead).toList();

      for (final notif in unreadNotifs) {
        final docRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc(notif.id);
        batch.update(docRef, {'isRead': true});
      }

      await batch.commit();

      _notifications = _notifications
          .map((notif) => notif.isRead ? notif : notif.markAsRead())
          .toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du marquage de toutes comme lues: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestoreService.delete('notifications', notificationId);
      _notifications.removeWhere((notif) => notif.id == notificationId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de la notification: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Supprimer toutes les notifications lues
  Future<void> deleteAllRead() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final readNotifs = _notifications.where((n) => n.isRead).toList();

      for (final notif in readNotifs) {
        final docRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc(notif.id);
        batch.delete(docRef);
      }

      await batch.commit();

      _notifications.removeWhere((notif) => notif.isRead);
      notifyListeners();
    } catch (e) {
      _errorMessage =
          'Erreur lors de la suppression des notifications lues: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Obtenir les notifications par type
  List<Notification> getNotificationsByType(NotificationType type) {
    return _notifications.where((notif) => notif.type == type).toList();
  }

  /// Obtenir une notification par ID
  Notification? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((notif) => notif.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir les notifications groupées par date
  Map<String, List<Notification>> getNotificationsGroupedByDate() {
    final Map<String, List<Notification>> grouped = {};
    final now = DateTime.now();

    for (final notification in _notifications) {
      final difference = now.difference(notification.createdAt);
      String key;

      if (difference.inDays == 0) {
        key = 'Aujourd\'hui';
      } else if (difference.inDays == 1) {
        key = 'Hier';
      } else if (difference.inDays < 7) {
        key = 'Cette semaine';
      } else if (difference.inDays < 30) {
        key = 'Ce mois-ci';
      } else {
        key = 'Plus ancien';
      }

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(notification);
    }

    return grouped;
  }

  // Méthodes de conversion Firestore

  Notification _notificationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Notification(
      id: doc.id,
      type: _typeFromString(data['type'] as String),
      title: data['title'] as String,
      message: data['message'] as String,
      metadata: Map<String, dynamic>.from(data['metadata'] as Map? ?? {}),
      isRead: data['isRead'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  String _typeToString(NotificationType type) {
    return type.toString().split('.').last;
  }

  NotificationType _typeFromString(String typeStr) {
    switch (typeStr) {
      case 'invitation':
        return NotificationType.invitation;
      case 'eventReminder':
        return NotificationType.eventReminder;
      case 'eventUpdate':
        return NotificationType.eventUpdate;
      case 'pollCreated':
        return NotificationType.pollCreated;
      case 'pollClosed':
        return NotificationType.pollClosed;
      case 'expenseAdded':
        return NotificationType.expenseAdded;
      case 'paymentRequest':
        return NotificationType.paymentRequest;
      case 'paymentReceived':
        return NotificationType.paymentReceived;
      case 'memberJoined':
        return NotificationType.memberJoined;
      case 'memberLeft':
        return NotificationType.memberLeft;
      default:
        return NotificationType.invitation;
    }
  }
}
