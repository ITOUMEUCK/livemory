class ApiConfig {
  // À modifier selon votre configuration
  static const String baseUrl =
      'http://localhost:3000/api'; // ou votre URL d'API
  static const String apiVersion = 'v1';

  // Endpoints
  static const String eventsEndpoint = '/events';
  static const String participantsEndpoint = '/participants';
  static const String tasksEndpoint = '/tasks';
  static const String budgetsEndpoint = '/budgets';
  static const String votesEndpoint = '/votes';
  static const String dealsEndpoint = '/deals';
  static const String mediaEndpoint = '/media';
  static const String usersEndpoint = '/users';
  static const String authEndpoint = '/auth';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
