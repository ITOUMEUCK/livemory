package com.livemory.livemory_api.notification;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CreateNotificationRequest(
        Long userId,
        Long guestUserId,
        @NotNull(message = "Type is required") NotificationType type,
        @NotBlank(message = "Title is required") String title,
        @NotBlank(message = "Message is required") String message,
        String relatedEntityType,
        Long relatedEntityId,
        String actionUrl) {
    public CreateNotificationRequest {
        if (userId == null && guestUserId == null) {
            throw new IllegalArgumentException("Either userId or guestUserId must be provided");
        }
    }
}
