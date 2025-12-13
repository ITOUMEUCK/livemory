package com.livemory.livemory_api.vote;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VoteRepository extends JpaRepository<Vote, Long> {
    List<Vote> findByEventId(Long eventId);

    List<Vote> findByStepId(Long stepId);

    List<Vote> findByEventIdAndStatus(Long eventId, VoteStatus status);
}
