package com.livemory.livemory_api.template;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.livemory.livemory_api.event.EventType;

import java.time.LocalDateTime;
import java.util.List;

public record EventTemplateResponse(
        Long id,
        String name,
        String description,
        EventType eventType,
        String icon,
        Integer defaultDurationHours,
        List<String> suggestedTasks,
        List<String> suggestedBudgetCategories,
        Boolean isSystemTemplate,
        Long createdById,
        LocalDateTime createdAt) {
    private static final ObjectMapper objectMapper = new ObjectMapper();

    public static EventTemplateResponse from(EventTemplate template) {
        List<String> tasks = parseJsonArray(template.getSuggestedTasks());
        List<String> budgetCategories = parseJsonArray(template.getSuggestedBudgetCategories());

        return new EventTemplateResponse(
                template.getId(),
                template.getName(),
                template.getDescription(),
                template.getEventType(),
                template.getIcon(),
                template.getDefaultDurationHours(),
                tasks,
                budgetCategories,
                template.getIsSystemTemplate(),
                template.getCreatedBy() != null ? template.getCreatedBy().getId() : null,
                template.getCreatedAt());
    }

    private static List<String> parseJsonArray(String json) {
        if (json == null || json.isEmpty()) {
            return List.of();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {
            });
        } catch (JsonProcessingException e) {
            return List.of();
        }
    }
}
