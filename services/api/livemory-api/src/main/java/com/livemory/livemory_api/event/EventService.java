package com.livemory.livemory_api.event;

import com.livemory.livemory_api.user.User;
import com.livemory.livemory_api.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class EventService {
    private final EventRepository eventRepository;
    private final UserRepository userRepository;

    public EventService(EventRepository eventRepository, UserRepository userRepository) {
        this.eventRepository = eventRepository;
        this.userRepository = userRepository;
    }

    public EventResponse createEvent(CreateEventRequest request) {
        User creator = userRepository.findById(request.createdByUserId())
                .orElseThrow(
                        () -> new IllegalArgumentException("User not found with id: " + request.createdByUserId()));

        Event event = new Event();
        event.setTitle(request.title());
        event.setDescription(request.description());
        event.setType(request.type());
        event.setCoverImageUrl(request.coverImageUrl());
        event.setCreatedBy(creator);
        event.setStartDate(request.startDate());
        event.setEndDate(request.endDate());

        Event saved = eventRepository.save(event);
        return EventResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public EventResponse getEvent(Long id) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Event not found with id: " + id));
        return EventResponse.from(event);
    }

    @Transactional(readOnly = true)
    public List<EventResponse> getAllEvents() {
        return eventRepository.findAll().stream()
                .map(EventResponse::from)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EventResponse> getEventsByCreator(Long userId) {
        return eventRepository.findByCreatedById(userId).stream()
                .map(EventResponse::from)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EventResponse> getEventsByType(EventType type) {
        return eventRepository.findByType(type).stream()
                .map(EventResponse::from)
                .collect(Collectors.toList());
    }

    public void deleteEvent(Long id) {
        if (!eventRepository.existsById(id)) {
            throw new IllegalArgumentException("Event not found with id: " + id);
        }
        eventRepository.deleteById(id);
    }
}
