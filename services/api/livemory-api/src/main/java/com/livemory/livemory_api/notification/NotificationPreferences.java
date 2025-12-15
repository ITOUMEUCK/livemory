package com.livemory.livemory_api.notification;

import com.livemory.livemory_api.user.User;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notification_preferences")
public class NotificationPreferences {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "email_enabled", nullable = false)
    private Boolean emailEnabled = true;

    @Column(name = "push_enabled", nullable = false)
    private Boolean pushEnabled = true;

    @Column(name = "event_reminders", nullable = false)
    private Boolean eventReminders = true;

    @Column(name = "task_assignments", nullable = false)
    private Boolean taskAssignments = true;

    @Column(name = "vote_notifications", nullable = false)
    private Boolean voteNotifications = true;

    @Column(name = "budget_alerts", nullable = false)
    private Boolean budgetAlerts = true;

    @Column(name = "group_invitations", nullable = false)
    private Boolean groupInvitations = true;

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

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Boolean getEmailEnabled() {
        return emailEnabled;
    }

    public void setEmailEnabled(Boolean emailEnabled) {
        this.emailEnabled = emailEnabled;
    }

    public Boolean getPushEnabled() {
        return pushEnabled;
    }

    public void setPushEnabled(Boolean pushEnabled) {
        this.pushEnabled = pushEnabled;
    }

    public Boolean getEventReminders() {
        return eventReminders;
    }

    public void setEventReminders(Boolean eventReminders) {
        this.eventReminders = eventReminders;
    }

    public Boolean getTaskAssignments() {
        return taskAssignments;
    }

    public void setTaskAssignments(Boolean taskAssignments) {
        this.taskAssignments = taskAssignments;
    }

    public Boolean getVoteNotifications() {
        return voteNotifications;
    }

    public void setVoteNotifications(Boolean voteNotifications) {
        this.voteNotifications = voteNotifications;
    }

    public Boolean getBudgetAlerts() {
        return budgetAlerts;
    }

    public void setBudgetAlerts(Boolean budgetAlerts) {
        this.budgetAlerts = budgetAlerts;
    }

    public Boolean getGroupInvitations() {
        return groupInvitations;
    }

    public void setGroupInvitations(Boolean groupInvitations) {
        this.groupInvitations = groupInvitations;
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
