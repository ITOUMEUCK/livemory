package com.livemory.livemory_api.suggestion;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record CreateSuggestionRequest(
        @NotNull(message = "Event ID is required") Long eventId,
        @NotNull(message = "Suggestion type is required") SuggestionType suggestionType,
        @NotBlank(message = "Provider name is required") String providerName,
        @NotBlank(message = "Title is required") String title,
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
        Long createdById) {
}
