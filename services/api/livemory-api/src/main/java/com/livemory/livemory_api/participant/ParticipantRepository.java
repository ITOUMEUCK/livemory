package com.livemory.livemory_api.participant;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ParticipantRepository extends JpaRepository<Participant, Long> {
    List<Participant> findByEventId(Long eventId);

    List<Participant> findByUserId(Long userId);

    List<Participant> findByStepId(Long stepId);

    Optional<Participant> findByUserIdAndEventIdAndStepId(Long userId, Long eventId, Long stepId);

    boolean existsByUserIdAndEventId(Long userId, Long eventId);
}
