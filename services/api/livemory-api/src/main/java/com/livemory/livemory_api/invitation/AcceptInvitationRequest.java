package com.livemory.livemory_api.invitation;

import jakarta.validation.constraints.NotBlank;

public record AcceptInvitationRequest(
        @NotBlank(message = "Token is required") String token,
        Long userId // Null si invité sans compte
) {
}
