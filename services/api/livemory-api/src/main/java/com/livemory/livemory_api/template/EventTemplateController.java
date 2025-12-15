package com.livemory.livemory_api.template;

import com.livemory.livemory_api.event.EventType;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/templates")
public class EventTemplateController {

    private final EventTemplateService templateService;

    public EventTemplateController(EventTemplateService templateService) {
        this.templateService = templateService;
    }

    @GetMapping("/system")
    public List<EventTemplateResponse> getSystemTemplates() {
        return templateService.getAllSystemTemplates().stream()
                .map(EventTemplateResponse::from)
                .toList();
    }

    @GetMapping("/type/{eventType}")
    public List<EventTemplateResponse> getTemplatesByType(@PathVariable EventType eventType) {
        return templateService.getTemplatesByType(eventType).stream()
                .map(EventTemplateResponse::from)
                .toList();
    }

    @GetMapping("/user/{userId}")
    public List<EventTemplateResponse> getUserTemplates(@PathVariable Long userId) {
        return templateService.getUserTemplates(userId).stream()
                .map(EventTemplateResponse::from)
                .toList();
    }

    @GetMapping("/{id}")
    public EventTemplateResponse getTemplate(@PathVariable Long id) {
        EventTemplate template = templateService.getTemplateById(id);
        return EventTemplateResponse.from(template);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public EventTemplateResponse createTemplate(@Valid @RequestBody CreateTemplateRequest request) {
        EventTemplate template = templateService.createTemplate(request);
        return EventTemplateResponse.from(template);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteTemplate(@PathVariable Long id, @RequestParam Long userId) {
        templateService.deleteTemplate(id, userId);
    }
}
