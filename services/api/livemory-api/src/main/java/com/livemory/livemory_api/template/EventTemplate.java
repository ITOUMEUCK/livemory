package com.livemory.livemory_api.template;

import com.livemory.livemory_api.event.EventType;
import com.livemory.livemory_api.user.User;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "event_templates")
public class EventTemplate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "event_type", nullable = false)
    private EventType eventType;

    private String icon;

    @Column(name = "default_duration_hours")
    private Integer defaultDurationHours;

    @Column(name = "suggested_tasks", columnDefinition = "TEXT")
    private String suggestedTasks; // JSON array

    @Column(name = "suggested_budget_categories", columnDefinition = "TEXT")
    private String suggestedBudgetCategories; // JSON array

    @Column(name = "is_system_template", nullable = false)
    private Boolean isSystemTemplate = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_id")
    private User createdBy;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt = LocalDateTime.now();

    // Getters and setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public EventType getEventType() {
        return eventType;
    }

    public void setEventType(EventType eventType) {
        this.eventType = eventType;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public Integer getDefaultDurationHours() {
        return defaultDurationHours;
    }

    public void setDefaultDurationHours(Integer defaultDurationHours) {
        this.defaultDurationHours = defaultDurationHours;
    }

    public String getSuggestedTasks() {
        return suggestedTasks;
    }

    public void setSuggestedTasks(String suggestedTasks) {
        this.suggestedTasks = suggestedTasks;
    }

    public String getSuggestedBudgetCategories() {
        return suggestedBudgetCategories;
    }

    public void setSuggestedBudgetCategories(String suggestedBudgetCategories) {
        this.suggestedBudgetCategories = suggestedBudgetCategories;
    }

    public Boolean getIsSystemTemplate() {
        return isSystemTemplate;
    }

    public void setIsSystemTemplate(Boolean systemTemplate) {
        isSystemTemplate = systemTemplate;
    }

    public User getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(User createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
