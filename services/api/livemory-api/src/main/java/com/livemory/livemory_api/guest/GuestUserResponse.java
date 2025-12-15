package com.livemory.livemory_api.guest;

import java.time.LocalDateTime;

public record GuestUserResponse(
        Long id,
        String guestToken,
        String name,
        String email,
        String phone,
        boolean isConverted,
        LocalDateTime createdAt,
        LocalDateTime lastActiveAt) {
    public static GuestUserResponse from(GuestUser guest) {
        return new GuestUserResponse(
                guest.getId(),
                guest.getGuestToken(),
                guest.getName(),
                guest.getEmail(),
                guest.getPhone(),
                guest.isConverted(),
                guest.getCreatedAt(),
                guest.getLastActiveAt());
    }
}
