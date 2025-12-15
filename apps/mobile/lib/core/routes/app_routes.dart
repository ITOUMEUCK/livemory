/// Routes de l'application
class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // Main app routes
  static const String home = '/home';
  static const String groups = '/groups';
  static const String groupDetail = '/groups/:groupId';
  static const String createGroup = '/groups/create';

  static const String events = '/events';
  static const String eventDetail = '/events/:eventId';
  static const String createEvent = '/events/create';

  static const String polls = '/polls';
  static const String pollDetail = '/polls/:pollId';
  static const String createPoll = '/polls/create';

  static const String budget = '/budget';
  static const String budgetDetail = '/budget/:budgetId';
  static const String createBudget = '/budget/create';

  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  /// Génère un path avec paramètres
  static String groupDetailPath(String groupId) => '/groups/$groupId';
  static String eventDetailPath(String eventId) => '/events/$eventId';
  static String pollDetailPath(String pollId) => '/polls/$pollId';
  static String budgetDetailPath(String budgetId) => '/budget/$budgetId';
}
