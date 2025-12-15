/// Configuration des constantes de l'application
class AppConstants {
  AppConstants._();

  // ============ App Info ============
  static const String appName = 'Livemory';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Orchestrez vos soirées en quelques taps';

  // ============ Pagination ============
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ============ Timeouts ============
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration uploadTimeout = Duration(minutes: 2);

  // ============ Animation Durations ============
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ============ Espacements ============
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingSection = 32.0;

  // ============ Border Radius ============
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;

  // Aliases pour compatibilité
  static const double borderRadiusM = radiusM;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusFull = 24.0;

  // ============ Icon Sizes ============
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;

  // ============ Image Sizes ============
  static const double avatarSizeS = 32.0;
  static const double avatarSizeM = 48.0;
  static const double avatarSizeL = 64.0;
  static const double avatarSizeXL = 96.0;

  static const double thumbnailSize = 120.0;
  static const double imagePreviewSize = 200.0;

  // ============ Limits ============
  static const int maxDescriptionLength = 500;
  static const int maxTitleLength = 100;
  static const int maxCommentLength = 300;
  static const int maxPhotosPerEvent = 50;
  static const int maxMembersPerGroup = 100;

  // ============ Budget ============
  static const String defaultCurrency = '€';
  static const int maxBudgetAmount = 999999;
  static const int minExpenseAmount = 1;

  // ============ Notifications ============
  static const int notificationReminderDays = 7; // J-7
  static const int notificationReminderHours = 24; // J-1
  static const int pollReminderHours = 24; // 24h avant deadline

  // ============ Deep Links ============
  static const String deepLinkScheme = 'livemory';
  static const String deepLinkHost = 'app.livemory.com';

  // ============ External Services ============
  static const String supportEmail = 'contact@livemory.app';
  static const String privacyPolicyUrl = 'https://livemory.app/privacy';
  static const String termsOfServiceUrl = 'https://livemory.app/terms';
  static const String websiteUrl = 'https://livemory.app';

  // ============ Feature Flags ============
  static const bool enableDarkMode = false; // TODO: v1.1
  static const bool enableAIAssistant = false; // TODO: v2.0
  static const bool enableVideoUpload = true;
  static const bool enableOfflineMode = false; // TODO: v1.1

  // ============ Event Types ============
  static const List<String> eventTypes = [
    'party',
    'trip',
    'restaurant',
    'home',
    'cultural',
  ];

  // ============ Event Type Emojis ============
  static const Map<String, String> eventTypeEmojis = {
    'party': '🎉',
    'trip': '✈️',
    'restaurant': '🍽️',
    'home': '🏠',
    'cultural': '🎭',
  };

  // ============ Poll Types ============
  static const List<String> pollTypes = ['dates', 'locations', 'choices'];

  // ============ Vote Options ============
  static const List<String> voteOptions = ['yes', 'maybe', 'no'];

  // ============ Expense Categories ============
  static const List<String> expenseCategories = [
    'accommodation',
    'food',
    'transport',
    'activities',
    'other',
  ];

  // ============ Category Emojis ============
  static const Map<String, String> categoryEmojis = {
    'accommodation': '🏨',
    'food': '🍽️',
    'transport': '🚗',
    'activities': '🎯',
    'other': '📦',
  };

  // ============ User Roles ============
  static const String roleOwner = 'owner';
  static const String roleCoOrganizer = 'co_organizer';
  static const String roleParticipant = 'participant';
  static const String roleGuest = 'guest';

  // ============ Permissions ============
  static const Map<String, List<String>> rolePermissions = {
    'owner': [
      'edit_group',
      'delete_group',
      'manage_members',
      'edit_event',
      'delete_event',
      'manage_budget',
      'create_poll',
    ],
    'co_organizer': [
      'edit_event',
      'manage_budget',
      'create_poll',
      'manage_checklist',
    ],
    'participant': ['vote', 'add_photos', 'comment', 'complete_task'],
    'guest': ['view', 'vote'],
  };
}
