package com.livemory.livemory_api.event;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/events")
public class EventController {
    private final EventService eventService;

    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public EventResponse createEvent(@Valid @RequestBody CreateEventRequest request) {
        return eventService.createEvent(request);
    }

    @GetMapping
    public List<EventResponse> getAllEvents() {
        return eventService.getAllEvents();
    }

    @GetMapping("/{id}")
    public EventResponse getEvent(@PathVariable Long id) {
        return eventService.getEvent(id);
    }

    @GetMapping("/by-creator/{userId}")
    public List<EventResponse> getEventsByCreator(@PathVariable Long userId) {
        return eventService.getEventsByCreator(userId);
    }

    @GetMapping("/by-type/{type}")
    public List<EventResponse> getEventsByType(@PathVariable EventType type) {
        return eventService.getEventsByType(type);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteEvent(@PathVariable Long id) {
        eventService.deleteEvent(id);
    }
}
