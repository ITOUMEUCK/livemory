package com.livemory.livemory_api.template;

import com.livemory.livemory_api.event.EventType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EventTemplateRepository extends JpaRepository<EventTemplate, Long> {

    List<EventTemplate> findByIsSystemTemplate(Boolean isSystemTemplate);

    List<EventTemplate> findByEventType(EventType eventType);

    List<EventTemplate> findByCreatedById(Long createdById);
}
