package com.livemory.livemory_api.suggestion;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/suggestions")
public class SuggestionController {

    private final SuggestionService suggestionService;

    public SuggestionController(SuggestionService suggestionService) {
        this.suggestionService = suggestionService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public SuggestionResponse createSuggestion(@Valid @RequestBody CreateSuggestionRequest request) {
        Suggestion suggestion = suggestionService.createSuggestion(request);
        return SuggestionResponse.from(suggestion);
    }

    @GetMapping("/event/{eventId}")
    public List<SuggestionResponse> getEventSuggestions(@PathVariable Long eventId) {
        return suggestionService.getEventSuggestions(eventId).stream()
                .map(SuggestionResponse::from)
                .toList();
    }

    @GetMapping("/event/{eventId}/type/{type}")
    public List<SuggestionResponse> getEventSuggestionsByType(
            @PathVariable Long eventId,
            @PathVariable SuggestionType type) {
        return suggestionService.getEventSuggestionsByType(eventId, type).stream()
                .map(SuggestionResponse::from)
                .toList();
    }

    @GetMapping("/event/{eventId}/group-discounts")
    public List<SuggestionResponse> getGroupDiscountSuggestions(@PathVariable Long eventId) {
        return suggestionService.getGroupDiscountSuggestions(eventId).stream()
                .map(SuggestionResponse::from)
                .toList();
    }

    @GetMapping("/{id}")
    public SuggestionResponse getSuggestion(@PathVariable Long id) {
        Suggestion suggestion = suggestionService.getSuggestionById(id);
        return SuggestionResponse.from(suggestion);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteSuggestion(@PathVariable Long id) {
        suggestionService.deleteSuggestion(id);
    }
}
