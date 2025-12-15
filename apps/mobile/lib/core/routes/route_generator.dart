import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

/// Générateur de routes pour l'application
class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen());

      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen());

      case AppRoutes.login:
        return _buildRoute(const LoginScreen());

      case AppRoutes.register:
        return _buildRoute(const RegisterScreen());

      case AppRoutes.home:
        return _buildRoute(const HomeScreen());

      default:
        return _buildRoute(_ErrorScreen(routeName: settings.name ?? 'unknown'));
    }
  }

  static MaterialPageRoute _buildRoute(
    Widget screen, {
    bool fullscreen = false,
  }) {
    return MaterialPageRoute(
      builder: (_) => screen,
      fullscreenDialog: fullscreen,
    );
  }

  static PageRouteBuilder _buildFadeRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static PageRouteBuilder _buildSlideRoute(
    Widget screen, {
    bool fromBottom = false,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = fromBottom
            ? const Offset(0.0, 1.0)
            : const Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

/// Écran placeholder temporaire
class _PlaceholderScreen extends StatelessWidget {
  final String name;

  const _PlaceholderScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('$name - Coming Soon', style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

/// Écran d'erreur pour routes introuvables
class _ErrorScreen extends StatelessWidget {
  final String routeName;

  const _ErrorScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Route introuvable: $routeName'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
