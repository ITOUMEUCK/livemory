import 'package:flutter/material.dart';

/// Extensions utiles pour String
extension StringExtensions on String {
  /// Capitalise la première lettre
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalise chaque mot
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Vérifie si l'email est valide
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Vérifie si le mot de passe est fort
  bool get isStrongPassword {
    // Au moins 8 caractères, 1 majuscule, 1 minuscule, 1 chiffre
    return length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(this) &&
        RegExp(r'[a-z]').hasMatch(this) &&
        RegExp(r'[0-9]').hasMatch(this);
  }

  /// Nettoie les espaces superflus
  String get cleaned {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Tronque à une longueur max avec ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
}

/// Extensions pour DateTime
extension DateTimeExtensions on DateTime {
  /// Vérifie si la date est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Vérifie si la date est demain
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Vérifie si la date est dans le passé
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Vérifie si la date est dans le futur
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Format relatif (il y a 2h, demain, etc.)
  String get relativeTime {
    final now = DateTime.now();
    final diff = difference(now);

    if (isToday) return 'Aujourd\'hui';
    if (isTomorrow) return 'Demain';

    if (diff.inDays.abs() < 7) {
      if (diff.inDays > 0) {
        return 'Dans ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
      } else {
        return 'Il y a ${diff.inDays.abs()} jour${diff.inDays.abs() > 1 ? 's' : ''}';
      }
    }

    if (diff.inHours.abs() < 24) {
      if (diff.inHours > 0) {
        return 'Dans ${diff.inHours}h';
      } else {
        return 'Il y a ${diff.inHours.abs()}h';
      }
    }

    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year}';
  }

  /// Début de la journée (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Fin de la journée (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }
}

/// Extensions pour BuildContext
extension ContextExtensions on BuildContext {
  /// Accès rapide au ThemeData
  ThemeData get theme => Theme.of(this);

  /// Accès rapide au ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Accès rapide au TextTheme
  TextTheme get textTheme => theme.textTheme;

  /// Taille de l'écran
  Size get screenSize => MediaQuery.of(this).size;

  /// Largeur de l'écran
  double get screenWidth => screenSize.width;

  /// Hauteur de l'écran
  double get screenHeight => screenSize.height;

  /// Padding système (SafeArea)
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Vérifie si le clavier est visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Navigation rapide
  void push(Widget page) {
    Navigator.of(this).push(MaterialPageRoute(builder: (_) => page));
  }

  void pushReplacement(Widget page) {
    Navigator.of(this).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  void pop([dynamic result]) {
    Navigator.of(this).pop(result);
  }

  /// Affiche un SnackBar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), duration: duration, action: action),
    );
  }

  /// Affiche un SnackBar d'erreur
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Affiche un SnackBar de succès
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche un SnackBar d'information
  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Extensions pour List
extension ListExtensions<T> on List<T> {
  /// Vérifie si la liste n'est pas nulle et non vide
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Retourne un élément aléatoire
  T? get random {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecondsSinceEpoch % length)];
  }

  /// Divise la liste en chunks de taille donnée
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

/// Extensions pour num (int, double)
extension NumExtensions on num {
  /// Format avec devise (€)
  String get toEuro {
    return '${toStringAsFixed(2)} €';
  }

  /// Format pourcentage
  String get toPercent {
    return '${toStringAsFixed(0)}%';
  }

  /// Arrondit à 2 décimales
  double get roundTo2 {
    return double.parse(toStringAsFixed(2));
  }
}
