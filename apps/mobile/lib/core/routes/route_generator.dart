import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/groups/presentation/screens/groups_list_screen.dart';
import '../../features/groups/presentation/screens/create_group_screen.dart';
import '../../features/groups/presentation/screens/group_detail_screen.dart';
import '../../features/events/presentation/screens/events_list_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/polls/presentation/screens/polls_list_screen.dart';
import '../../features/polls/presentation/screens/create_poll_screen.dart';
import '../../features/polls/presentation/screens/poll_detail_screen.dart';
import '../../features/budgets/presentation/screens/budgets_list_screen.dart';
import '../../features/budgets/presentation/screens/create_budget_screen.dart';
import '../../features/budgets/presentation/screens/budget_detail_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

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

      case AppRoutes.groups:
        return _buildRoute(const GroupsListScreen());

      case AppRoutes.createGroup:
        return _buildSlideRoute(const CreateGroupScreen(), fromBottom: true);

      case AppRoutes.events:
        return _buildRoute(const EventsListScreen());

      case AppRoutes.createEvent:
        final groupId = settings.arguments as String?;
        return _buildSlideRoute(
          CreateEventScreen(groupId: groupId),
          fromBottom: true,
        );

      case AppRoutes.polls:
        final eventId = settings.arguments as String?;
        return _buildRoute(PollsListScreen(eventId: eventId));

      case AppRoutes.createPoll:
        final eventId = settings.arguments as String?;
        return _buildSlideRoute(
          CreatePollScreen(eventId: eventId),
          fromBottom: true,
        );

      case AppRoutes.budget:
        final eventId = settings.arguments as String?;
        return _buildRoute(BudgetsListScreen(eventId: eventId));

      case AppRoutes.notifications:
        return _buildRoute(const NotificationsScreen());

      case '/profile':
        return _buildRoute(const ProfileScreen());

      case '/edit-profile':
        return _buildRoute(const EditProfileScreen());

      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen());

      case AppRoutes.createBudget:
        final eventId = settings.arguments as String?;
        return _buildSlideRoute(
          CreateBudgetScreen(eventId: eventId),
          fromBottom: true,
        );

      default:
        // Vérifier si c'est une route avec paramètres
        if (settings.name?.startsWith('/groups/') == true &&
            settings.name != AppRoutes.createGroup) {
          final groupId = settings.name!.split('/').last;
          return _buildRoute(GroupDetailScreen(groupId: groupId));
        }

        if (settings.name?.startsWith('/events/') == true &&
            settings.name != AppRoutes.createEvent) {
          final eventId = settings.name!.split('/').last;
          return _buildRoute(EventDetailScreen(eventId: eventId));
        }

        if (settings.name?.startsWith('/polls/') == true &&
            settings.name != AppRoutes.createPoll) {
          final pollId = settings.name!.split('/').last;
          return _buildRoute(PollDetailScreen(pollId: pollId));
        }

        if (settings.name?.startsWith('/budget/') == true &&
            settings.name != AppRoutes.createBudget) {
          final budgetId = settings.name!.split('/').last;
          return _buildRoute(BudgetDetailScreen(budgetId: budgetId));
        }

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
