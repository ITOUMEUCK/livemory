import 'package:flutter/material.dart';
import 'core/config/env_config.dart';
import 'app.dart';

void main() {
  // Configuration de l'environnement (dev par défaut)
  EnvConfig.setEnvironment(Environment.dev);

  runApp(const LivemoryApp());
}
