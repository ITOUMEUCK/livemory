package com.livemory.livemory_api.invitation;

import com.livemory.livemory_api.event.Event;
import com.livemory.livemory_api.event.EventRepository;
import com.livemory.livemory_api.group.Group;
import com.livemory.livemory_api.group.GroupMember;
import com.livemory.livemory_api.group.GroupMemberRepository;
import com.livemory.livemory_api.group.GroupRepository;
import com.livemory.livemory_api.group.GroupRole;
import com.livemory.livemory_api.participant.Participant;
import com.livemory.livemory_api.participant.ParticipantRepository;
import com.livemory.livemory_api.user.User;
import com.livemory.livemory_api.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class InvitationService {

    private final InvitationRepository invitationRepository;
    private final GroupRepository groupRepository;
    private final EventRepository eventRepository;
    private final UserRepository userRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final ParticipantRepository participantRepository;

    public InvitationService(InvitationRepository invitationRepository,
            GroupRepository groupRepository,
            EventRepository eventRepository,
            UserRepository userRepository,
            GroupMemberRepository groupMemberRepository,
            ParticipantRepository participantRepository) {
        this.invitationRepository = invitationRepository;
        this.groupRepository = groupRepository;
        this.eventRepository = eventRepository;
        this.userRepository = userRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.participantRepository = participantRepository;
    }

    public Invitation createInvitation(CreateInvitationRequest request) {
        User invitedBy = userRepository.findById(request.invitedById())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Invitation invitation = new Invitation();
        invitation.setToken(generateUniqueToken());
        invitation.setInvitedBy(invitedBy);
        invitation.setInvitedEmail(request.invitedEmail());
        invitation.setInvitedPhone(request.invitedPhone());
        invitation.setRole(request.role() != null ? request.role() : "MEMBER");
        invitation.setStatus(InvitationStatus.PENDING);

        int expiresInDays = request.expiresInDays() != null ? request.expiresInDays() : 7;
        invitation.setExpiresAt(LocalDateTime.now().plusDays(expiresInDays));

        if (request.groupId() != null) {
            Group group = groupRepository.findById(request.groupId())
                    .orElseThrow(() -> new IllegalArgumentException("Group not found"));
            invitation.setGroup(group);
        } else if (request.eventId() != null) {
            Event event = eventRepository.findById(request.eventId())
                    .orElseThrow(() -> new IllegalArgumentException("Event not found"));
            invitation.setEvent(event);
        }

        return invitationRepository.save(invitation);
    }

    @Transactional(readOnly = true)
    public Invitation getInvitationByToken(String token) {
        Invitation invitation = invitationRepository.findByToken(token)
                .orElseThrow(() -> new IllegalArgumentException("Invitation not found"));

        if (invitation.isExpired() && invitation.getStatus() == InvitationStatus.PENDING) {
            invitation.setStatus(InvitationStatus.EXPIRED);
            invitationRepository.save(invitation);
        }

        return invitation;
    }

    public void acceptInvitation(AcceptInvitationRequest request) {
        Invitation invitation = getInvitationByToken(request.token());

        if (invitation.getStatus() != InvitationStatus.PENDING) {
            throw new IllegalArgumentException("Invitation is not pending");
        }

        if (invitation.isExpired()) {
            invitation.setStatus(InvitationStatus.EXPIRED);
            invitationRepository.save(invitation);
            throw new IllegalArgumentException("Invitation has expired");
        }

        User acceptedBy = null;
        if (request.userId() != null) {
            acceptedBy = userRepository.findById(request.userId())
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
        }

        invitation.setStatus(InvitationStatus.ACCEPTED);
        invitation.setAcceptedAt(LocalDateTime.now());
        invitation.setAcceptedBy(acceptedBy);

        if (invitation.getGroup() != null && acceptedBy != null) {
            // Add to group
            if (!groupMemberRepository.existsByGroupIdAndUserId(
                    invitation.getGroup().getId(), acceptedBy.getId())) {
                GroupMember member = new GroupMember();
                member.setGroup(invitation.getGroup());
                member.setUser(acceptedBy);
                member.setRole(GroupRole.valueOf(invitation.getRole()));
                groupMemberRepository.save(member);
            }
        } else if (invitation.getEvent() != null && acceptedBy != null) {
            // Add to event
            if (!participantRepository.existsByEventIdAndUserId(
                    invitation.getEvent().getId(), acceptedBy.getId())) {
                Participant participant = new Participant();
                participant.setEvent(invitation.getEvent());
                participant.setUser(acceptedBy);
                // Map invitation role to ParticipantRole
                com.livemory.livemory_api.participant.ParticipantRole participantRole = "ORGANIZER"
                        .equals(invitation.getRole()) ? com.livemory.livemory_api.participant.ParticipantRole.ORGANIZER
                                : com.livemory.livemory_api.participant.ParticipantRole.PARTICIPANT;
                participant.setRole(participantRole);
                participantRepository.save(participant);
            }
        }

        invitationRepository.save(invitation);
    }

    public void declineInvitation(String token) {
        Invitation invitation = getInvitationByToken(token);

        if (invitation.getStatus() != InvitationStatus.PENDING) {
            throw new IllegalArgumentException("Invitation is not pending");
        }

        invitation.setStatus(InvitationStatus.DECLINED);
        invitationRepository.save(invitation);
    }

    @Transactional(readOnly = true)
    public List<Invitation> getInvitationsByEmail(String email) {
        return invitationRepository.findByInvitedEmail(email);
    }

    @Transactional(readOnly = true)
    public List<Invitation> getInvitationsByGroup(Long groupId) {
        return invitationRepository.findByGroupId(groupId);
    }

    @Transactional(readOnly = true)
    public List<Invitation> getInvitationsByEvent(Long eventId) {
        return invitationRepository.findByEventId(eventId);
    }

    private String generateUniqueToken() {
        String token;
        do {
            token = UUID.randomUUID().toString().replace("-", "");
        } while (invitationRepository.findByToken(token).isPresent());
        return token;
    }
}
