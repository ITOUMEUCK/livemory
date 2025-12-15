package com.livemory.livemory_api.template;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.livemory.livemory_api.event.EventType;
import com.livemory.livemory_api.user.User;
import com.livemory.livemory_api.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class EventTemplateService {

    private final EventTemplateRepository templateRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    public EventTemplateService(EventTemplateRepository templateRepository,
            UserRepository userRepository,
            ObjectMapper objectMapper) {
        this.templateRepository = templateRepository;
        this.userRepository = userRepository;
        this.objectMapper = objectMapper;
    }

    public EventTemplate createTemplate(CreateTemplateRequest request) {
        EventTemplate template = new EventTemplate();
        template.setName(request.name());
        template.setDescription(request.description());
        template.setEventType(request.eventType());
        template.setIcon(request.icon());
        template.setDefaultDurationHours(request.defaultDurationHours());
        template.setIsSystemTemplate(false);

        if (request.suggestedTasks() != null) {
            template.setSuggestedTasks(toJson(request.suggestedTasks()));
        }

        if (request.suggestedBudgetCategories() != null) {
            template.setSuggestedBudgetCategories(toJson(request.suggestedBudgetCategories()));
        }

        if (request.createdById() != null) {
            User creator = userRepository.findById(request.createdById())
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            template.setCreatedBy(creator);
        }

        return templateRepository.save(template);
    }

    @Transactional(readOnly = true)
    public List<EventTemplate> getAllSystemTemplates() {
        return templateRepository.findByIsSystemTemplate(true);
    }

    @Transactional(readOnly = true)
    public List<EventTemplate> getTemplatesByType(EventType eventType) {
        return templateRepository.findByEventType(eventType);
    }

    @Transactional(readOnly = true)
    public List<EventTemplate> getUserTemplates(Long userId) {
        return templateRepository.findByCreatedById(userId);
    }

    @Transactional(readOnly = true)
    public EventTemplate getTemplateById(Long id) {
        return templateRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Template not found"));
    }

    public void deleteTemplate(Long id, Long userId) {
        EventTemplate template = getTemplateById(id);

        if (template.getIsSystemTemplate()) {
            throw new IllegalArgumentException("Cannot delete system template");
        }

        if (template.getCreatedBy() != null && !template.getCreatedBy().getId().equals(userId)) {
            throw new IllegalArgumentException("You can only delete your own templates");
        }

        templateRepository.delete(template);
    }

    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize to JSON", e);
        }
    }
}
