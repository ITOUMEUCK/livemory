package com.livemory.livemory_api.group;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateGroupRequest(
        @NotBlank(message = "Name is required") @Size(max = 255, message = "Name must be less than 255 characters") String name,

        String description) {
}
