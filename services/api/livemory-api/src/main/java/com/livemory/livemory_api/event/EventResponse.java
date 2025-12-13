package com.livemory.livemory_api.event;

import java.time.LocalDateTime;

public record EventResponse(
        Long id,
        String title,
        String description,
        EventType type,
        String coverImageUrl,
        Long createdByUserId,
        LocalDateTime startDate,
        LocalDateTime endDate,
        LocalDateTime createdAt) {
    public static EventResponse from(Event event) {
        return new EventResponse(
                event.getId(),
                event.getTitle(),
                event.getDescription(),
                event.getType(),
                event.getCoverImageUrl(),
                event.getCreatedBy().getId(),
                event.getStartDate(),
                event.getEndDate(),
                event.getCreatedAt());
    }
}
