package com.livemory.livemory_api.event;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {
    List<Event> findByCreatedById(Long userId);

    List<Event> findByType(EventType type);
}
