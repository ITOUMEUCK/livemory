/// Clés pour le stockage local (SharedPreferences)
class StorageKeys {
  StorageKeys._();

  // ============ Auth ============
  static const String accessToken = 'auth_access_token';
  static const String refreshToken = 'auth_refresh_token';
  static const String userId = 'auth_user_id';
  static const String userEmail = 'auth_user_email';
  static const String isLoggedIn = 'auth_is_logged_in';

  // ============ User Preferences ============
  static const String darkMode = 'pref_dark_mode';
  static const String language = 'pref_language';
  static const String notificationsEnabled = 'pref_notifications_enabled';
  static const String soundEnabled = 'pref_sound_enabled';

  // ============ Onboarding ============
  static const String hasSeenOnboarding = 'onboarding_completed';
  static const String onboardingVersion = 'onboarding_version';

  // ============ Cache ============
  static const String cacheTimestamp = 'cache_timestamp';
  static const String cachedEvents = 'cache_events';
  static const String cachedGroups = 'cache_groups';

  // ============ Notifications Settings ============
  static const String notifyInvitations = 'notify_invitations';
  static const String notifyTasks = 'notify_tasks';
  static const String notifyPolls = 'notify_polls';
  static const String notifyBudget = 'notify_budget';
  static const String notifyReminders = 'notify_reminders';
  static const String notifyComments = 'notify_comments';
  static const String notifyPhotos = 'notify_photos';

  // Notification Frequency
  static const String notificationFrequency =
      'notification_frequency'; // realtime, daily_digest
  static const String quietHoursStart = 'quiet_hours_start'; // 22:00
  static const String quietHoursEnd = 'quiet_hours_end'; // 08:00

  // ============ FCM ============
  static const String fcmToken = 'fcm_token';
  static const String fcmTokenTimestamp = 'fcm_token_timestamp';

  // ============ App State ============
  static const String lastSyncTime = 'last_sync_time';
  static const String pendingActions = 'pending_actions'; // For offline mode
  static const String selectedGroupId = 'selected_group_id';
}
