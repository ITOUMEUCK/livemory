import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Service pour surveiller la connectivité réseau
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _connectionController.stream;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  /// Initialiser le service de surveillance réseau
  Future<void> initialize() async {
    // Vérifier l'état initial
    final result = await _connectivity.checkConnectivity();
    _isOnline = result.first != ConnectivityResult.none;

    // Écouter les changements
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOnline = _isOnline;
      _isOnline =
          results.isNotEmpty && results.first != ConnectivityResult.none;

      // Notifier seulement si l'état a changé
      if (wasOnline != _isOnline) {
        _connectionController.add(_isOnline);
        debugPrint(
          _isOnline
              ? '✅ Connexion rétablie'
              : '⚠️ Connexion perdue - Mode hors ligne',
        );
      }
    });
  }

  void dispose() {
    _connectionController.close();
  }
}

/// Widget banner pour afficher le statut réseau
class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: NetworkService().onConnectivityChanged,
      initialData: NetworkService().isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        if (isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          color: Colors.orange.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Mode hors ligne - Les modifications seront synchronisées',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget indicateur de connexion simple (pour AppBar)
class NetworkStatusIndicator extends StatelessWidget {
  const NetworkStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: NetworkService().onConnectivityChanged,
      initialData: NetworkService().isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        if (isOnline) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Tooltip(
            message: 'Mode hors ligne',
            child: Icon(
              Icons.cloud_off,
              color: Colors.orange.shade700,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
