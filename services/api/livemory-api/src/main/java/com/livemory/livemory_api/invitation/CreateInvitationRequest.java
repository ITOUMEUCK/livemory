package com.livemory.livemory_api.invitation;

import jakarta.validation.constraints.NotNull;

public record CreateInvitationRequest(
        Long groupId,
        Long eventId,
        @NotNull(message = "Invited by user ID is required") Long invitedById,
        String invitedEmail,
        String invitedPhone,
        String role,
        Integer expiresInDays // Durée de validité en jours (défaut: 7)
) {
    public CreateInvitationRequest {
        if (groupId == null && eventId == null) {
            throw new IllegalArgumentException("Either groupId or eventId must be provided");
        }
        if (groupId != null && eventId != null) {
            throw new IllegalArgumentException("Cannot invite to both group and event");
        }
    }
}
