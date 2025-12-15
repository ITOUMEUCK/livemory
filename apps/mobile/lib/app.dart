import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';

class LivemoryApp extends StatelessWidget {
  const LivemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livemory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
