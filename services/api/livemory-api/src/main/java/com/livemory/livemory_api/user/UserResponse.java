package com.livemory.livemory_api.user;

import java.time.LocalDateTime;

public record UserResponse(
        Long id,
        String firstName,
        String lastName,
        String email,
        String avatarUrl,
        LocalDateTime createdAt) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getFirstName(),
                user.getLastName(),
                user.getEmail(),
                user.getAvatarUrl(),
                user.getCreatedAt());
    }
}
