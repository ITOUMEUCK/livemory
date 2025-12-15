import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/groups/presentation/providers/group_provider.dart';
import 'features/events/presentation/providers/event_provider.dart';
import 'features/polls/presentation/providers/poll_provider.dart';

class LivemoryApp extends StatelessWidget {
  const LivemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => PollProvider()),
      ],
      child: MaterialApp(
        title: 'Livemory',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
