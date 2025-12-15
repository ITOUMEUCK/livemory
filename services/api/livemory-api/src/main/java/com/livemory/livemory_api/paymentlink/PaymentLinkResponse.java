package com.livemory.livemory_api.paymentlink;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record PaymentLinkResponse(
        Long id,
        Long eventId,
        String eventTitle,
        Long budgetId,
        PaymentProvider paymentProvider,
        String paymentUrl,
        BigDecimal amount,
        String description,
        Long createdById,
        String createdByName,
        PaymentLinkStatus status,
        LocalDateTime expiresAt,
        LocalDateTime createdAt) {
    public static PaymentLinkResponse from(PaymentLink paymentLink) {
        String createdByName = paymentLink.getCreatedBy().getFirstName() + " "
                + paymentLink.getCreatedBy().getLastName();
        return new PaymentLinkResponse(
                paymentLink.getId(),
                paymentLink.getEvent().getId(),
                paymentLink.getEvent().getTitle(),
                paymentLink.getBudget() != null ? paymentLink.getBudget().getId() : null,
                paymentLink.getPaymentProvider(),
                paymentLink.getPaymentUrl(),
                paymentLink.getAmount(),
                paymentLink.getDescription(),
                paymentLink.getCreatedBy().getId(),
                createdByName,
                paymentLink.getCreatedBy().getName(),
                paymentLink.getStatus(),
                paymentLink.getExpiresAt(),
                paymentLink.getCreatedAt());
    }
}
