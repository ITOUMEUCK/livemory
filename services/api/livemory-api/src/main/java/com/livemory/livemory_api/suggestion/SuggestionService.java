package com.livemory.livemory_api.suggestion;

import com.livemory.livemory_api.event.Event;
import com.livemory.livemory_api.event.EventRepository;
import com.livemory.livemory_api.participant.ParticipantRepository;
import com.livemory.livemory_api.user.User;
import com.livemory.livemory_api.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class SuggestionService {

    private final SuggestionRepository suggestionRepository;
    private final EventRepository eventRepository;
    private final UserRepository userRepository;
    private final ParticipantRepository participantRepository;

    public SuggestionService(SuggestionRepository suggestionRepository,
            EventRepository eventRepository,
            UserRepository userRepository,
            ParticipantRepository participantRepository) {
        this.suggestionRepository = suggestionRepository;
        this.eventRepository = eventRepository;
        this.userRepository = userRepository;
        this.participantRepository = participantRepository;
    }

    public Suggestion createSuggestion(CreateSuggestionRequest request) {
        Event event = eventRepository.findById(request.eventId())
                .orElseThrow(() -> new IllegalArgumentException("Event not found"));

        Suggestion suggestion = new Suggestion();
        suggestion.setEvent(event);
        suggestion.setSuggestionType(request.suggestionType());
        suggestion.setProviderName(request.providerName());
        suggestion.setTitle(request.title());
        suggestion.setDescription(request.description());
        suggestion.setUrl(request.url());
        suggestion.setPricePerPerson(request.pricePerPerson());
        suggestion.setGroupDiscountAvailable(
                request.groupDiscountAvailable() != null ? request.groupDiscountAvailable() : false);
        suggestion.setMinGroupSize(request.minGroupSize());
        suggestion.setDiscountPercentage(request.discountPercentage());
        suggestion.setLocation(request.location());
        suggestion.setDepartureLocation(request.departureLocation());
        suggestion.setArrivalLocation(request.arrivalLocation());
        suggestion.setDepartureTime(request.departureTime());
        suggestion.setArrivalTime(request.arrivalTime());

        if (request.createdById() != null) {
            User creator = userRepository.findById(request.createdById())
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            suggestion.setCreatedBy(creator);
        }

        return suggestionRepository.save(suggestion);
    }

    @Transactional(readOnly = true)
    public List<Suggestion> getEventSuggestions(Long eventId) {
        return suggestionRepository.findByEventId(eventId);
    }

    @Transactional(readOnly = true)
    public List<Suggestion> getEventSuggestionsByType(Long eventId, SuggestionType type) {
        return suggestionRepository.findByEventIdAndSuggestionType(eventId, type);
    }

    @Transactional(readOnly = true)
    public List<Suggestion> getGroupDiscountSuggestions(Long eventId) {
        // Get number of participants for the event
        int participantCount = participantRepository.findByEventId(eventId).size();

        return suggestionRepository.findGroupDiscountSuggestions(eventId, participantCount);
    }

    @Transactional(readOnly = true)
    public Suggestion getSuggestionById(Long id) {
        return suggestionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Suggestion not found"));
    }

    public void deleteSuggestion(Long id) {
        Suggestion suggestion = getSuggestionById(id);

        if (suggestion.getIsSystemSuggestion()) {
            throw new IllegalArgumentException("Cannot delete system suggestions");
        }

        suggestionRepository.delete(suggestion);
    }
}
