import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Hiérarchie de typographie Livemory
/// Basée sur Material Design 3 avec personnalisation
class AppTextStyles {
  AppTextStyles._();

  // ============ Display (Titres Majeurs) ============

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600, // Semi-Bold
    letterSpacing: -0.25,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Alias pour compatibilité
  static const TextStyle headlineLarge = displayLarge;

  // ============ Headline (Titres de Sections) ============

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ============ Title (Titres d'Éléments) ============

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // ============ Body (Corps de Texte) ============

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textTertiary,
  );

  // ============ Label (Labels et Boutons) ============

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
    color: AppColors.textTertiary,
  );

  // ============ Styles Spécialisés ============

  /// Pour les boutons primaires
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Pour les chips et badges
  static const TextStyle chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.2,
  );

  /// Pour les prix et montants
  static const TextStyle price = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Pour les emojis contextuels
  static const TextStyle emoji = TextStyle(fontSize: 24, height: 1.0);

  // ============ Helpers ============

  /// Applique la couleur primaire à un style
  static TextStyle withPrimaryColor(TextStyle style) {
    return style.copyWith(color: AppColors.primary);
  }

  /// Applique la couleur secondaire à un style
  static TextStyle withSecondaryColor(TextStyle style) {
    return style.copyWith(color: AppColors.secondary);
  }

  /// Applique la couleur d'erreur à un style
  static TextStyle withErrorColor(TextStyle style) {
    return style.copyWith(color: AppColors.error);
  }

  /// Applique le style blanc (pour texte sur fond coloré)
  static TextStyle withWhiteColor(TextStyle style) {
    return style.copyWith(color: Colors.white);
  }
}
