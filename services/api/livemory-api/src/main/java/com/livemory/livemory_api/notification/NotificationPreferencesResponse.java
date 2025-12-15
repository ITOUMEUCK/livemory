package com.livemory.livemory_api.notification;

import java.time.LocalDateTime;

public record NotificationPreferencesResponse(
        Long id,
        Long userId,
        Boolean emailEnabled,
        Boolean pushEnabled,
        Boolean eventReminders,
        Boolean taskAssignments,
        Boolean voteNotifications,
        Boolean budgetAlerts,
        Boolean groupInvitations,
        LocalDateTime updatedAt) {
    public static NotificationPreferencesResponse from(NotificationPreferences prefs) {
        return new NotificationPreferencesResponse(
                prefs.getId(),
                prefs.getUser().getId(),
                prefs.getEmailEnabled(),
                prefs.getPushEnabled(),
                prefs.getEventReminders(),
                prefs.getTaskAssignments(),
                prefs.getVoteNotifications(),
                prefs.getBudgetAlerts(),
                prefs.getGroupInvitations(),
                prefs.getUpdatedAt());
    }
}
