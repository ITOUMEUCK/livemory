package com.livemory.livemory_api.notification;

import java.time.LocalDateTime;

public record NotificationResponse(
        Long id,
        NotificationType type,
        String title,
        String message,
        String relatedEntityType,
        Long relatedEntityId,
        String actionUrl,
        Boolean isRead,
        Boolean isSent,
        LocalDateTime createdAt) {
    public static NotificationResponse from(Notification notification) {
        return new NotificationResponse(
                notification.getId(),
                notification.getType(),
                notification.getTitle(),
                notification.getMessage(),
                notification.getRelatedEntityType(),
                notification.getRelatedEntityId(),
                notification.getActionUrl(),
                notification.getIsRead(),
                notification.getIsSent(),
                notification.getCreatedAt());
    }
}
