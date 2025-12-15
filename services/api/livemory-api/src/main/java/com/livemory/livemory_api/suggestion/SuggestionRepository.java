package com.livemory.livemory_api.suggestion;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SuggestionRepository extends JpaRepository<Suggestion, Long> {

    List<Suggestion> findByEventId(Long eventId);

    List<Suggestion> findByEventIdAndSuggestionType(Long eventId, SuggestionType suggestionType);

    @Query("SELECT s FROM Suggestion s WHERE s.event.id = :eventId AND s.groupDiscountAvailable = true AND s.minGroupSize <= :groupSize")
    List<Suggestion> findGroupDiscountSuggestions(@Param("eventId") Long eventId,
            @Param("groupSize") Integer groupSize);

    List<Suggestion> findByIsSystemSuggestion(Boolean isSystemSuggestion);
}
