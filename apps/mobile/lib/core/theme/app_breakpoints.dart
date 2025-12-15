/// Breakpoints pour le responsive design
class AppBreakpoints {
  // Tailles d'écran
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1600;

  // Helpers statiques
  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
  static bool isWide(double width) => width >= wide;

  // Nombre de colonnes pour GridView
  static int getGridColumns(double width) {
    if (width >= wide) return 4;
    if (width >= desktop) return 3;
    if (width >= tablet) return 2;
    return 1;
  }

  // Padding horizontal adaptatif
  static double getHorizontalPadding(double width) {
    if (width >= desktop) return 48.0;
    if (width >= tablet) return 32.0;
    return 16.0;
  }

  // Max width du contenu (pour éviter lignes trop longues)
  static double getMaxContentWidth(double width) {
    if (width >= wide) return 1400;
    if (width >= desktop) return 1200;
    return double.infinity;
  }
}
