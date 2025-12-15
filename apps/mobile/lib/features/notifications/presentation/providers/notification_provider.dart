import 'package:flutter/foundation.dart';
import '../../domain/entities/notification.dart';

/// Provider pour la gestion des notifications
class NotificationProvider with ChangeNotifier {
  List<Notification> _notifications = [];
  bool _isLoading = false;

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  /// Nombre de notifications non lues
  int get unreadCount => _notifications.where((notif) => !notif.isRead).length;

  /// Notifications non lues
  List<Notification> get unreadNotifications =>
      _notifications.where((notif) => !notif.isRead).toList();

  /// Notifications lues
  List<Notification> get readNotifications =>
      _notifications.where((notif) => notif.isRead).toList();

  /// Récupérer toutes les notifications
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      _notifications = _getMockNotifications();
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Erreur lors du chargement des notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer une nouvelle notification
  Future<void> createNotification({
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notification = Notification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        title: title,
        message: message,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
      );

      _notifications.insert(0, notification);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la création de la notification: $e');
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _notifications.indexWhere(
        (notif) => notif.id == notificationId,
      );
      if (index != -1) {
        _notifications[index] = _notifications[index].markAsRead();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du marquage comme lu: $e');
    }
  }

  /// Marquer une notification comme non lue
  Future<void> markAsUnread(String notificationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _notifications.indexWhere(
        (notif) => notif.id == notificationId,
      );
      if (index != -1) {
        _notifications[index] = _notifications[index].markAsUnread();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du marquage comme non lu: $e');
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _notifications = _notifications
          .map((notif) => notif.isRead ? notif : notif.markAsRead())
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du marquage de toutes comme lues: $e');
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _notifications.removeWhere((notif) => notif.id == notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la notification: $e');
    }
  }

  /// Supprimer toutes les notifications lues
  Future<void> deleteAllRead() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _notifications.removeWhere((notif) => notif.isRead);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la suppression des notifications lues: $e');
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

  /// Données mock pour les notifications
  List<Notification> _getMockNotifications() {
    final now = DateTime.now();

    return [
      // Aujourd'hui
      Notification(
        id: '1',
        type: NotificationType.paymentRequest,
        title: 'Demande de remboursement',
        message: 'Alice vous demande 35€ pour les courses du week-end ski',
        metadata: {
          'budgetId': '1',
          'userId': '2',
          'userName': 'Alice Martin',
          'amount': 35.0,
        },
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      Notification(
        id: '2',
        type: NotificationType.pollCreated,
        title: 'Nouveau sondage',
        message: 'Bob a créé un sondage "Date pour le barbecue d\'été"',
        metadata: {
          'pollId': '3',
          'eventId': '2',
          'userId': '3',
          'userName': 'Bob Wilson',
        },
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Notification(
        id: '3',
        type: NotificationType.eventReminder,
        title: 'Rappel d\'événement',
        message: 'Week-end Ski commence demain à 14h00',
        metadata: {'eventId': '1', 'groupId': '1'},
        createdAt: now.subtract(const Duration(hours: 5)),
      ),

      // Hier
      Notification(
        id: '4',
        type: NotificationType.expenseAdded,
        title: 'Nouvelle dépense',
        message: 'David a ajouté une dépense de 240€ (Forfaits ski)',
        metadata: {
          'budgetId': '1',
          'eventId': '1',
          'userId': '4',
          'userName': 'David Chen',
          'amount': 240.0,
        },
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      Notification(
        id: '5',
        type: NotificationType.memberJoined,
        title: 'Nouveau membre',
        message: 'Emma a rejoint le groupe "Amis du lycée"',
        metadata: {'groupId': '1', 'userId': '5', 'userName': 'Emma Davis'},
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 8)),
      ),

      // Cette semaine
      Notification(
        id: '6',
        type: NotificationType.invitation,
        title: 'Invitation à un groupe',
        message: 'Alice vous a invité à rejoindre "Voyage Portugal 2024"',
        metadata: {'groupId': '3', 'userId': '2', 'userName': 'Alice Martin'},
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Notification(
        id: '7',
        type: NotificationType.eventUpdate,
        title: 'Événement modifié',
        message: 'L\'heure de "Soirée jeux de société" a changé',
        metadata: {'eventId': '2', 'groupId': '1'},
        isRead: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Notification(
        id: '8',
        type: NotificationType.pollClosed,
        title: 'Résultat du sondage',
        message: 'Le sondage "Restaurant pour l\'anniversaire" est terminé',
        metadata: {'pollId': '1', 'eventId': '2'},
        isRead: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Notification(
        id: '9',
        type: NotificationType.paymentReceived,
        title: 'Remboursement reçu',
        message: 'Bob vous a remboursé 25€',
        metadata: {
          'budgetId': '2',
          'userId': '3',
          'userName': 'Bob Wilson',
          'amount': 25.0,
        },
        isRead: true,
        createdAt: now.subtract(const Duration(days: 6)),
      ),

      // Ce mois-ci
      Notification(
        id: '10',
        type: NotificationType.memberLeft,
        title: 'Membre parti',
        message: 'Frank a quitté le groupe "Collègues"',
        metadata: {'groupId': '2', 'userId': '6', 'userName': 'Frank Miller'},
        isRead: true,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Notification(
        id: '11',
        type: NotificationType.eventUpdate,
        title: 'Nouvel événement',
        message: 'Alice a créé l\'événement "Pique-nique au parc"',
        metadata: {
          'eventId': '3',
          'groupId': '1',
          'userId': '2',
          'userName': 'Alice Martin',
        },
        isRead: true,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ];
  }
}
