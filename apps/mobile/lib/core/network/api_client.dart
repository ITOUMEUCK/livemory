import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import '../errors/exceptions.dart';

/// Client API centralisé utilisant Dio
class ApiClient {
  late final Dio _dio;
  String? _accessToken;

  ApiClient() {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }

  /// Configuration de base de Dio
  BaseOptions get _baseOptions => BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: EnvConfig.connectTimeout,
    receiveTimeout: EnvConfig.receiveTimeout,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  /// Configuration des intercepteurs
  void _setupInterceptors() {
    // Intercepteur d'authentification
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ajouter le token d'authentification si disponible
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Gérer le refresh token en cas de 401
          if (error.response?.statusCode == 401) {
            try {
              // Tenter de refresh le token
              final refreshed = await _refreshToken();
              if (refreshed) {
                // Retry la requête originale
                final response = await _retry(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (e) {
              // Le refresh a échoué, propager l'erreur
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Intercepteur de logging (dev uniquement)
    if (EnvConfig.enableNetworkLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  /// Définir le token d'accès
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Retry d'une requête après refresh token
  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Refresh du token d'authentification
  Future<bool> _refreshToken() async {
    // TODO: Implémenter la logique de refresh token
    // 1. Récupérer le refresh token du storage
    // 2. Appeler l'endpoint /auth/refresh
    // 3. Sauvegarder le nouveau access token
    // 4. Retourner true si succès, false sinon
    return false;
  }

  // ============ Méthodes HTTP ============

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload de fichier
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    ProgressCallback? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?extraData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onProgress,
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Gestion des Erreurs ============

  /// Convertit une DioException en AppException
  AppException _handleError(DioException error) {
    if (EnvConfig.enableLogging) {
      debugPrint('API Error: ${error.message}');
      debugPrint('Status Code: ${error.response?.statusCode}');
      debugPrint('Response: ${error.response?.data}');
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Délai d\'attente dépassé');

      case DioExceptionType.connectionError:
        return NetworkException('Pas de connexion Internet');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Erreur serveur';

        switch (statusCode) {
          case 400:
            return ValidationException(message);
          case 401:
            return AuthException('Session expirée, reconnectez-vous');
          case 403:
            return PermissionException(message);
          case 404:
            return NotFoundException(message);
          case 500:
          case 502:
          case 503:
            return ServerException(message);
          default:
            return ServerException('Erreur serveur ($statusCode)');
        }

      case DioExceptionType.cancel:
        return AppException('Requête annulée');

      default:
        return AppException('Une erreur est survenue');
    }
  }
}
