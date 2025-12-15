import 'package:equatable/equatable.dart';

/// Types de notifications
enum NotificationType {
  invitation('invitation', 'Invitation', '📨'),
  eventUpdate('event_update', 'Événement', '📅'),
  eventReminder('event_reminder', 'Rappel', '⏰'),
  pollCreated('poll_created', 'Sondage', '📊'),
  pollClosed('poll_closed', 'Résultat', '✅'),
  expenseAdded('expense_added', 'Dépense', '💰'),
  paymentRequest('payment_request', 'Paiement', '💳'),
  paymentReceived('payment_received', 'Remboursement', '✨'),
  memberJoined('member_joined', 'Nouveau membre', '👋'),
  memberLeft('member_left', 'Départ', '👤');

  final String value;
  final String label;
  final String emoji;

  const NotificationType(this.value, this.label, this.emoji);

  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.invitation,
    );
  }
}

/// Entité Notification
class Notification extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.metadata = const {},
    this.isRead = false,
    required this.createdAt,
  });

  /// Copie avec modifications
  Notification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Marquer comme lu
  Notification markAsRead() => copyWith(isRead: true);

  /// Marquer comme non lu
  Notification markAsUnread() => copyWith(isRead: false);

  /// Récupérer l'ID du groupe depuis les métadonnées
  String? get groupId => metadata['groupId'] as String?;

  /// Récupérer l'ID de l'événement depuis les métadonnées
  String? get eventId => metadata['eventId'] as String?;

  /// Récupérer l'ID du sondage depuis les métadonnées
  String? get pollId => metadata['pollId'] as String?;

  /// Récupérer l'ID du budget depuis les métadonnées
  String? get budgetId => metadata['budgetId'] as String?;

  /// Récupérer l'ID de l'utilisateur concerné depuis les métadonnées
  String? get userId => metadata['userId'] as String?;

  /// Récupérer le nom de l'utilisateur depuis les métadonnées
  String? get userName => metadata['userName'] as String?;

  /// Récupérer le montant depuis les métadonnées
  double? get amount => metadata['amount'] as double?;

  /// Obtenir la route de navigation appropriée
  String? get navigationRoute {
    switch (type) {
      case NotificationType.invitation:
        return groupId != null ? '/groups/$groupId' : null;
      case NotificationType.eventUpdate:
      case NotificationType.eventReminder:
        return eventId != null ? '/events/$eventId' : null;
      case NotificationType.pollCreated:
      case NotificationType.pollClosed:
        return pollId != null ? '/polls/$pollId' : null;
      case NotificationType.expenseAdded:
      case NotificationType.paymentRequest:
      case NotificationType.paymentReceived:
        return budgetId != null ? '/budget/$budgetId' : null;
      case NotificationType.memberJoined:
      case NotificationType.memberLeft:
        return groupId != null ? '/groups/$groupId' : null;
    }
  }

  /// Obtenir la couleur associée au type
  String get colorHex {
    switch (type) {
      case NotificationType.invitation:
        return '#0A66C2'; // Bleu LinkedIn
      case NotificationType.eventUpdate:
      case NotificationType.eventReminder:
        return '#25D366'; // Vert WhatsApp
      case NotificationType.pollCreated:
      case NotificationType.pollClosed:
        return '#9C27B0'; // Violet
      case NotificationType.expenseAdded:
      case NotificationType.paymentRequest:
        return '#FF9800'; // Orange
      case NotificationType.paymentReceived:
        return '#4CAF50'; // Vert
      case NotificationType.memberJoined:
        return '#2196F3'; // Bleu
      case NotificationType.memberLeft:
        return '#757575'; // Gris
    }
  }

  /// Temps relatif depuis la création
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a ${weeks}sem';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'Il y a ${months}mois';
    }
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    message,
    metadata,
    isRead,
    createdAt,
  ];

  @override
  String toString() =>
      'Notification(id: $id, type: ${type.label}, title: $title, isRead: $isRead)';
}
