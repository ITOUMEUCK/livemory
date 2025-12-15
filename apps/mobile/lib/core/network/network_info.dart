import 'package:connectivity_plus/connectivity_plus.dart';

/// Service pour vérifier la connexion réseau
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  /// Vérifie si l'appareil est connecté à Internet
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Stream des changements de connectivité
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
