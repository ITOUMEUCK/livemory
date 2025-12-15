package com.livemory.livemory_api.guest;

import jakarta.validation.constraints.NotBlank;

public record CreateGuestRequest(
        @NotBlank(message = "Name is required") String name,
        String email,
        String phone,
        String invitationToken) {
}
