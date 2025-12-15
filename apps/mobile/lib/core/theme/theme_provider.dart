import 'package:flutter/material.dart';

/// Mode de thème
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Provider pour la gestion du thème
class ThemeProvider with ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  
  AppThemeMode get themeMode => _themeMode;
  
  /// Obtenir le mode effectif en fonction du système
  AppThemeMode getEffectiveThemeMode(BuildContext context) {
    if (_themeMode == AppThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? AppThemeMode.dark : AppThemeMode.light;
    }
    return _themeMode;
  }
  
  /// Vérifier si le mode sombre est actif
  bool isDarkMode(BuildContext context) {
    return getEffectiveThemeMode(context) == AppThemeMode.dark;
  }
  
  /// Changer le mode de thème
  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    // TODO: Persister dans les préférences locales
  }
  
  /// Basculer entre clair et sombre
  void toggleTheme() {
    if (_themeMode == AppThemeMode.light) {
      _themeMode = AppThemeMode.dark;
    } else {
      _themeMode = AppThemeMode.light;
    }
    notifyListeners();
  }
}
