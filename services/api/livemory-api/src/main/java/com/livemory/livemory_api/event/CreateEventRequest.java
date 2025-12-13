package com.livemory.livemory_api.event;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

public record CreateEventRequest(
        @NotBlank String title,
        String description,
        @NotNull EventType type,
        String coverImageUrl,
        @NotNull Long createdByUserId,
        LocalDateTime startDate,
        LocalDateTime endDate) {
}
