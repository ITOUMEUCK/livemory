package com.livemory.livemory_api.invitation;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface InvitationRepository extends JpaRepository<Invitation, Long> {

    Optional<Invitation> findByToken(String token);

    List<Invitation> findByGroupId(Long groupId);

    List<Invitation> findByEventId(Long eventId);

    List<Invitation> findByInvitedEmail(String email);

    List<Invitation> findByInvitedPhone(String phone);

    List<Invitation> findByStatus(InvitationStatus status);
}
