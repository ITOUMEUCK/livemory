package com.livemory.livemory_api.group;

import java.time.LocalDateTime;

public record GroupMemberResponse(
        Long id,
        Long userId,
        String userName,
        String userEmail,
        GroupRole role,
        LocalDateTime joinedAt) {
    public static GroupMemberResponse from(GroupMember member) {
        String userName = member.getUser().getFirstName() + " " + member.getUser().getLastName();
        return new GroupMemberResponse(
                member.getId(),
                member.getUser().getId(),
                userName,
                member.getUser().getEmail(),
                member.getRole(),
                member.getJoinedAt());
    }
}
