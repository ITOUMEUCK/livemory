import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/groups/presentation/providers/group_provider.dart';
import 'features/events/presentation/providers/event_provider.dart';
import 'features/events/presentation/providers/activity_provider.dart';
import 'features/events/presentation/providers/todo_list_provider.dart';
import 'features/polls/presentation/providers/poll_provider.dart';
import 'features/budgets/presentation/providers/budget_provider.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';
import 'core/theme/theme_provider.dart';

class LivemoryApp extends StatelessWidget {
  const LivemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            // Initialiser l'écoute des changements d'authentification
            authProvider.initAuthListener();
            return authProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => TodoListProvider()),
        ChangeNotifierProvider(create: (_) => PollProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Livemory',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode == AppThemeMode.light
                ? ThemeMode.light
                : themeProvider.themeMode == AppThemeMode.dark
                ? ThemeMode.dark
                : ThemeMode.system,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
          );
        },
      ),
    );
  }
}
