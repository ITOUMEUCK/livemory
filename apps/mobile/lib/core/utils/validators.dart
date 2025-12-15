/// Validateurs de formulaires
class Validators {
  Validators._();

  /// Validateur d'email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }

    return null;
  }

  /// Validateur de mot de passe
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }

    return null;
  }

  /// Validateur de confirmation de mot de passe
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'La confirmation est requise';
      }

      if (value != password) {
        return 'Les mots de passe ne correspondent pas';
      }

      return null;
    };
  }

  /// Validateur de champ requis
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName est requis'
          : 'Ce champ est requis';
    }
    return null;
  }

  /// Validateur de longueur minimale
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Use required() for empty check
    }

    if (value.length < min) {
      return fieldName != null
          ? '$fieldName doit contenir au moins $min caractères'
          : 'Minimum $min caractères requis';
    }

    return null;
  }

  /// Validateur de longueur maximale
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > max) {
      return fieldName != null
          ? '$fieldName ne peut pas dépasser $max caractères'
          : 'Maximum $max caractères autorisés';
    }

    return null;
  }

  /// Validateur de nombre
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (double.tryParse(value) == null) {
      return fieldName != null
          ? '$fieldName doit être un nombre valide'
          : 'Nombre invalide';
    }

    return null;
  }

  /// Validateur de montant (budget)
  static String? amount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Le montant est requis';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Montant invalide';
    }

    if (min != null && amount < min) {
      return 'Le montant minimum est ${min.toStringAsFixed(2)} €';
    }

    if (max != null && amount > max) {
      return 'Le montant maximum est ${max.toStringAsFixed(2)} €';
    }

    return null;
  }

  /// Validateur de téléphone
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le téléphone est requis';
    }

    // Format français: 0X XX XX XX XX
    final phoneRegex = RegExp(r'^0[1-9](\d{2}){4}$');
    final cleanedValue = value.replaceAll(RegExp(r'\s+'), '');

    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Numéro de téléphone invalide';
    }

    return null;
  }

  /// Validateur d'URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'URL invalide';
      }
    } catch (e) {
      return 'URL invalide';
    }

    return null;
  }

  /// Validateur de date (ne doit pas être dans le passé)
  static String? futureDate(DateTime? value) {
    if (value == null) {
      return 'La date est requise';
    }

    if (value.isBefore(DateTime.now())) {
      return 'La date ne peut pas être dans le passé';
    }

    return null;
  }

  /// Combinateur de validateurs
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
