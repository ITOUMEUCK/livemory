package com.livemory.livemory_api.group;

import java.time.LocalDateTime;
import java.util.List;

public record GroupResponse(
        Long id,
        String name,
        String description,
        Long createdById,
        String createdByName,
        int memberCount,
        LocalDateTime createdAt,
        LocalDateTime updatedAt) {
    public static GroupResponse from(Group group) {
        String createdByName = group.getCreatedBy().getFirstName() + " " + group.getCreatedBy().getLastName();
        return new GroupResponse(
                group.getId(),
                group.getName(),
                group.getDescription(),
                group.getCreatedBy().getId(),
                createdByName,
                group.getMembers().size(),
                group.getCreatedAt(),
                group.getUpdatedAt());
    }
}
