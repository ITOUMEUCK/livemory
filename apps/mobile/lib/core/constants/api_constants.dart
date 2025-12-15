/// Configuration des endpoints API
class ApiConstants {
  ApiConstants._();

  // ============ Base URLs ============

  /// Base URL selon l'environnement (à configurer via env_config.dart)
  static const String devBaseUrl = 'http://localhost:3000/api';
  static const String stagingBaseUrl = 'https://staging-api.livemory.app';
  static const String prodBaseUrl = 'https://api.livemory.app';

  /// WebSocket URL pour real-time
  static const String devSocketUrl = 'ws://localhost:3000';
  static const String stagingSocketUrl = 'wss://staging-api.livemory.app';
  static const String prodSocketUrl = 'wss://api.livemory.app';

  // ============ API Version ============
  static const String apiVersion = 'v1';

  // ============ Auth Endpoints ============
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Social Auth
  static const String googleAuth = '/auth/google';
  static const String appleAuth = '/auth/apple';
  static const String facebookAuth = '/auth/facebook';

  // ============ User Endpoints ============
  static const String currentUser = '/users/me';
  static const String updateProfile = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';
  static const String deleteAccount = '/users/me';

  // ============ Groups Endpoints ============
  static const String groups = '/groups';
  static String groupDetail(String id) => '/groups/$id';
  static String groupMembers(String id) => '/groups/$id/members';
  static String inviteToGroup(String id) => '/groups/$id/invite';
  static String joinGroup(String id) => '/groups/$id/join';
  static String leaveGroup(String id) => '/groups/$id/leave';

  // ============ Events Endpoints ============
  static const String events = '/events';
  static String eventDetail(String id) => '/events/$id';
  static String eventsByGroup(String groupId) => '/groups/$groupId/events';
  static const String eventTemplates = '/events/templates';

  // Event Actions
  static String rsvpEvent(String id) => '/events/$id/rsvp';
  static String eventChecklist(String id) => '/events/$id/checklist';
  static String eventGallery(String id) => '/events/$id/gallery';
  static String uploadEventPhoto(String id) => '/events/$id/photos';

  // ============ Polls Endpoints ============
  static const String polls = '/polls';
  static String pollDetail(String id) => '/polls/$id';
  static String voteOnPoll(String id) => '/polls/$id/vote';
  static String pollResults(String id) => '/polls/$id/results';
  static String closePoll(String id) => '/polls/$id/close';

  // ============ Budget Endpoints ============
  static String eventBudget(String eventId) => '/events/$eventId/budget';
  static const String expenses = '/expenses';
  static String expenseDetail(String id) => '/expenses/$id';
  static String balances(String eventId) => '/events/$eventId/balances';
  static String exportBudget(String eventId) =>
      '/events/$eventId/budget/export';

  // ============ Logistics Endpoints ============
  static String eventLocation(String eventId) => '/events/$eventId/location';
  static const String searchAccommodations = '/logistics/accommodations';
  static const String searchActivities = '/logistics/activities';
  static const String transportOptions = '/logistics/transport';

  // ============ Notifications Endpoints ============
  static const String notifications = '/notifications';
  static String markAsRead(String id) => '/notifications/$id/read';
  static const String markAllAsRead = '/notifications/read-all';
  static const String notificationSettings = '/notifications/settings';
  static const String registerDevice = '/notifications/devices';

  // ============ Search Endpoints ============
  static const String search = '/search';
  static const String searchEvents = '/search/events';
  static const String searchGroups = '/search/groups';
  static const String searchUsers = '/search/users';

  // ============ External Services ============

  // Payment Links
  static String lydiaPaymentLink(String userId, double amount) =>
      'https://lydia-app.com/collect/$userId/$amount';

  static String paypalPaymentLink(String email, double amount) =>
      'https://paypal.me/$email/$amount';

  // Maps
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_KEY';
  static String googleMapsDirections(String origin, String destination) =>
      'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination';

  // Booking
  static String bookingSearch(
    String location,
    String checkIn,
    String checkOut,
  ) =>
      'https://www.booking.com/searchresults.html?ss=$location&checkin=$checkIn&checkout=$checkOut';

  // Trainline
  static String trainlineSearch(String from, String to, String date) =>
      'https://www.trainline.fr/search/$from/$to/$date';
}
