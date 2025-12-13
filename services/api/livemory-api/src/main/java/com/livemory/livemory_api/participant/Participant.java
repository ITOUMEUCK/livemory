package com.livemory.livemory_api.participant;

import com.livemory.livemory_api.event.Event;
import com.livemory.livemory_api.step.Step;
import com.livemory.livemory_api.user.User;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "participants", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "user_id", "event_id", "step_id" })
})
public class Participant {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id", nullable = false)
    private Event event;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "step_id")
    private Step step; // null if participant for entire event

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ParticipantRole role; // ORGANIZER, PARTICIPANT

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ParticipantStatus status; // INVITED, CONFIRMED, DECLINED

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
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

    public Event getEvent() {
        return event;
    }

    public void setEvent(Event event) {
        this.event = event;
    }

    public Step getStep() {
        return step;
    }

    public void setStep(Step step) {
        this.step = step;
    }

    public ParticipantRole getRole() {
        return role;
    }

    public void setRole(ParticipantRole role) {
        this.role = role;
    }

    public ParticipantStatus getStatus() {
        return status;
    }

    public void setStatus(ParticipantStatus status) {
        this.status = status;
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
}
