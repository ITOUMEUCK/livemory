package com.livemory.livemory_api.paymentlink;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record CreatePaymentLinkRequest(
        @NotNull(message = "Event ID is required") Long eventId,
        Long budgetId,
        @NotNull(message = "Payment provider is required") PaymentProvider paymentProvider,
        @NotBlank(message = "Payment URL is required") String paymentUrl,
        BigDecimal amount,
        String description,
        @NotNull(message = "Created by user ID is required") Long createdById,
        Integer expiresInDays) {
}
