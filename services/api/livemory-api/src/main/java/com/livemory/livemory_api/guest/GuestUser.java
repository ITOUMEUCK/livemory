package com.livemory.livemory_api.guest;

import com.livemory.livemory_api.invitation.Invitation;
import com.livemory.livemory_api.user.User;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "guest_users")
public class GuestUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "guest_token", nullable = false, unique = true)
    private String guestToken;

    @Column(nullable = false)
    private String name;

    private String email;

    private String phone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_from_invitation_id")
    private Invitation createdFromInvitation;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "last_active_at", nullable = false)
    private LocalDateTime lastActiveAt = LocalDateTime.now();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "converted_to_user_id")
    private User convertedToUser;

    // Getters and setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getGuestToken() {
        return guestToken;
    }

    public void setGuestToken(String guestToken) {
        this.guestToken = guestToken;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public Invitation getCreatedFromInvitation() {
        return createdFromInvitation;
    }

    public void setCreatedFromInvitation(Invitation createdFromInvitation) {
        this.createdFromInvitation = createdFromInvitation;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getLastActiveAt() {
        return lastActiveAt;
    }

    public void setLastActiveAt(LocalDateTime lastActiveAt) {
        this.lastActiveAt = lastActiveAt;
    }

    public User getConvertedToUser() {
        return convertedToUser;
    }

    public void setConvertedToUser(User convertedToUser) {
        this.convertedToUser = convertedToUser;
    }

    public boolean isConverted() {
        return convertedToUser != null;
    }

    public void updateActivity() {
        this.lastActiveAt = LocalDateTime.now();
    }
}
