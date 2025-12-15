package com.livemory.livemory_api.suggestion;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record SuggestionResponse(
        Long id,
        Long eventId,
        SuggestionType suggestionType,
        String providerName,
        String title,
        String description,
        String url,
        BigDecimal pricePerPerson,
        Boolean groupDiscountAvailable,
        Integer minGroupSize,
        BigDecimal discountPercentage,
        String location,
        String departureLocation,
        String arrivalLocation,
        LocalDateTime departureTime,
        LocalDateTime arrivalTime,
        Long createdById,
        Boolean isSystemSuggestion,
        LocalDateTime createdAt) {
    public static SuggestionResponse from(Suggestion suggestion) {
        return new SuggestionResponse(
                suggestion.getId(),
                suggestion.getEvent().getId(),
                suggestion.getSuggestionType(),
                suggestion.getProviderName(),
                suggestion.getTitle(),
                suggestion.getDescription(),
                suggestion.getUrl(),
                suggestion.getPricePerPerson(),
                suggestion.getGroupDiscountAvailable(),
                suggestion.getMinGroupSize(),
                suggestion.getDiscountPercentage(),
                suggestion.getLocation(),
                suggestion.getDepartureLocation(),
                suggestion.getArrivalLocation(),
                suggestion.getDepartureTime(),
                suggestion.getArrivalTime(),
                suggestion.getCreatedBy() != null ? suggestion.getCreatedBy().getId() : null,
                suggestion.getIsSystemSuggestion(),
                suggestion.getCreatedAt());
    }
}
