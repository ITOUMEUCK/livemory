import 'package:flutter/material.dart';

/// Palette de couleurs Livemory
/// Inspirée de l'identité visuelle de l'application
class AppColors {
  AppColors._();

  // ============ Couleurs Principales ============

  /// Rouge Livemory - Couleur primaire de la marque
  static const Color primary = Color(0xFFFF5252);
  static const Color primaryLight = Color(0xFFFF7979);
  static const Color primaryDark = Color(0xFFE63946);

  /// Corail Livemory - Couleur secondaire pour accents
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryLight = Color(0xFFFF9999);
  static const Color secondaryDark = Color(0xFFEE5A52);

  // ============ Couleurs Neutres ============

  /// Background principal de l'app
  static const Color background = Color(0xFFF5F7FA);

  /// Surface des cards et conteneurs
  static const Color surface = Color(0xFFFFFFFF);

  /// Variante surface (backgrounds secondaires)
  static const Color surfaceVariant = Color(0xFFEFF2F5);

  // ============ Couleurs de Texte ============

  /// Texte principal (titres, contenu important)
  static const Color textPrimary = Color(0xFF1C1E21);

  /// Texte secondaire (descriptions, labels)
  static const Color textSecondary = Color(0xFF65676B);

  /// Texte tertiaire (annotations, hints)
  static const Color textTertiary = Color(0xFFB0B3B8);

  // ============ Couleurs d'État ============

  /// Succès (actions validées)
  static const Color success = Color(0xFF4CAF50);

  /// Erreur (messages d'erreur, validation)
  static const Color error = Color(0xFFE63946);

  /// Avertissement (alertes budget, etc.)
  static const Color warning = Color(0xFFFF9800);

  /// Information (tips, notifications)
  static const Color info = Color(0xFFFF7979);

  // ============ Couleurs Spéciales ============

  /// Divider entre éléments
  static const Color divider = Color(0xFFE4E6EB);

  /// Overlay pour modals (avec opacity)
  static const Color overlay = Color(0x80000000);

  /// Shimmer loading effect
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ============ Dégradés ============

  /// Dégradé primaire (pour FAB, headers spéciaux)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dégradé secondaire (pour éléments ludiques)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Couleurs par Catégorie Événement ============

  static const Color categoryParty = Color(0xFFFF6B9D);
  static const Color categoryTrip = Color(0xFFFF9770);
  static const Color categoryRestaurant = Color(0xFFFFB366);
  static const Color categoryHome = Color(0xFFFF7979);
  static const Color categoryCultural = Color(0xFFFF8FA3);

  // ============ Mode Sombre (TODO) ============
  // À implémenter pour version 1.1
}
