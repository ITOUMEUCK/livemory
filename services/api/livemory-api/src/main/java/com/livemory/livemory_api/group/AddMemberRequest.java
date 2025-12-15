package com.livemory.livemory_api.group;

import jakarta.validation.constraints.NotNull;

public record AddMemberRequest(
        @NotNull(message = "User ID is required") Long userId,

        GroupRole role) {
}
