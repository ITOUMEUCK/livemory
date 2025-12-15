package com.livemory.livemory_api.invitation;

import java.time.LocalDateTime;

public record InvitationResponse(
        Long id,
        String token,
        String invitationLink,
        InvitationType type,
        Long targetId, // groupId ou eventId
        String targetName,
        Long invitedById,
        String invitedByName,
        String invitedEmail,
        String invitedPhone,
        String role,
        InvitationStatus status,
        LocalDateTime expiresAt,
        LocalDateTime createdAt) {
    public static InvitationResponse from(Invitation invitation, String baseUrl) {
        String targetName = invitation.getGroup() != null
                ? invitation.getGroup().getName()
                : invitation.getEvent().getTitle();

        Long targetId = invitation.getGroup() != null
                ? invitation.getGroup().getId()
                : invitation.getEvent().getId();

        String invitationLink = baseUrl + "/invitations/" + invitation.getToken();
        String invitedByName = invitation.getInvitedBy().getFirstName() + " " + invitation.getInvitedBy().getLastName();

        return new InvitationResponse(
                invitation.getId(),
                invitation.getToken(),
                invitationLink,
                invitation.getType(),
                targetId,
                targetName,
                invitation.getInvitedBy().getId(),
                invitedByName,
                invitation.getInvitedEmail(),
                invitation.getInvitedPhone(),
                invitation.getRole(),
                invitation.getStatus(),
                invitation.getExpiresAt(),
                invitation.getCreatedAt());
    }
}
