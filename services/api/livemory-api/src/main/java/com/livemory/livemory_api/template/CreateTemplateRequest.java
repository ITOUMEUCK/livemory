package com.livemory.livemory_api.template;

import com.livemory.livemory_api.event.EventType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record CreateTemplateRequest(
        @NotBlank(message = "Name is required") String name,
        String description,
        @NotNull(message = "Event type is required") EventType eventType,
        String icon,
        Integer defaultDurationHours,
        List<String> suggestedTasks,
        List<String> suggestedBudgetCategories,
        Long createdById) {
}
