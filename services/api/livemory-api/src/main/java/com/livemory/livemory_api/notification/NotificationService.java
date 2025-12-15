package com.livemory.livemory_api.notification;

import com.livemory.livemory_api.guest.GuestUser;
import com.livemory.livemory_api.guest.GuestUserRepository;
import com.livemory.livemory_api.user.User;
import com.livemory.livemory_api.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationPreferencesRepository preferencesRepository;
    private final UserRepository userRepository;
    private final GuestUserRepository guestUserRepository;

    public NotificationService(NotificationRepository notificationRepository,
            NotificationPreferencesRepository preferencesRepository,
            UserRepository userRepository,
            GuestUserRepository guestUserRepository) {
        this.notificationRepository = notificationRepository;
        this.preferencesRepository = preferencesRepository;
        this.userRepository = userRepository;
        this.guestUserRepository = guestUserRepository;
    }

    public Notification createNotification(CreateNotificationRequest request) {
        Notification notification = new Notification();
        notification.setType(request.type());
        notification.setTitle(request.title());
        notification.setMessage(request.message());
        notification.setRelatedEntityType(request.relatedEntityType());
        notification.setRelatedEntityId(request.relatedEntityId());
        notification.setActionUrl(request.actionUrl());

        if (request.userId() != null) {
            User user = userRepository.findById(request.userId())
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            notification.setUser(user);
        } else if (request.guestUserId() != null) {
            GuestUser guestUser = guestUserRepository.findById(request.guestUserId())
                    .orElseThrow(() -> new IllegalArgumentException("Guest user not found"));
            notification.setGuestUser(guestUser);
        }

        return notificationRepository.save(notification);
    }

    @Transactional(readOnly = true)
    public List<Notification> getUserNotifications(Long userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Transactional(readOnly = true)
    public List<Notification> getUnreadNotifications(Long userId) {
        return notificationRepository.findUnreadByUserId(userId);
    }

    @Transactional(readOnly = true)
    public Long getUnreadCount(Long userId) {
        return notificationRepository.countUnreadByUserId(userId);
    }

    public void markAsRead(Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new IllegalArgumentException("Notification not found"));
        notification.markAsRead();
        notificationRepository.save(notification);
    }

    public void markAllAsRead(Long userId) {
        List<Notification> unreadNotifications = notificationRepository.findUnreadByUserId(userId);
        unreadNotifications.forEach(Notification::markAsRead);
        notificationRepository.saveAll(unreadNotifications);
    }

    public void deleteNotification(Long notificationId) {
        notificationRepository.deleteById(notificationId);
    }

    // Notification Preferences
    public NotificationPreferences getOrCreatePreferences(Long userId) {
        return preferencesRepository.findByUserId(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new IllegalArgumentException("User not found"));
                    NotificationPreferences prefs = new NotificationPreferences();
                    prefs.setUser(user);
                    return preferencesRepository.save(prefs);
                });
    }

    public NotificationPreferences updatePreferences(Long userId, NotificationPreferences updates) {
        NotificationPreferences prefs = getOrCreatePreferences(userId);

        if (updates.getEmailEnabled() != null) {
            prefs.setEmailEnabled(updates.getEmailEnabled());
        }
        if (updates.getPushEnabled() != null) {
            prefs.setPushEnabled(updates.getPushEnabled());
        }
        if (updates.getEventReminders() != null) {
            prefs.setEventReminders(updates.getEventReminders());
        }
        if (updates.getTaskAssignments() != null) {
            prefs.setTaskAssignments(updates.getTaskAssignments());
        }
        if (updates.getVoteNotifications() != null) {
            prefs.setVoteNotifications(updates.getVoteNotifications());
        }
        if (updates.getBudgetAlerts() != null) {
            prefs.setBudgetAlerts(updates.getBudgetAlerts());
        }
        if (updates.getGroupInvitations() != null) {
            prefs.setGroupInvitations(updates.getGroupInvitations());
        }

        return preferencesRepository.save(prefs);
    }
}
