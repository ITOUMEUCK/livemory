package com.livemory.livemory_api.notification;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public NotificationResponse createNotification(@Valid @RequestBody CreateNotificationRequest request) {
        Notification notification = notificationService.createNotification(request);
        return NotificationResponse.from(notification);
    }

    @GetMapping("/user/{userId}")
    public List<NotificationResponse> getUserNotifications(@PathVariable Long userId) {
        return notificationService.getUserNotifications(userId).stream()
                .map(NotificationResponse::from)
                .toList();
    }

    @GetMapping("/user/{userId}/unread")
    public List<NotificationResponse> getUnreadNotifications(@PathVariable Long userId) {
        return notificationService.getUnreadNotifications(userId).stream()
                .map(NotificationResponse::from)
                .toList();
    }

    @GetMapping("/user/{userId}/unread/count")
    public Long getUnreadCount(@PathVariable Long userId) {
        return notificationService.getUnreadCount(userId);
    }

    @PutMapping("/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
    }

    @PutMapping("/user/{userId}/read-all")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markAllAsRead(@PathVariable Long userId) {
        notificationService.markAllAsRead(userId);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteNotification(@PathVariable Long id) {
        notificationService.deleteNotification(id);
    }

    // Preferences endpoints
    @GetMapping("/preferences/{userId}")
    public NotificationPreferencesResponse getPreferences(@PathVariable Long userId) {
        NotificationPreferences prefs = notificationService.getOrCreatePreferences(userId);
        return NotificationPreferencesResponse.from(prefs);
    }

    @PutMapping("/preferences/{userId}")
    public NotificationPreferencesResponse updatePreferences(
            @PathVariable Long userId,
            @RequestBody NotificationPreferences updates) {
        NotificationPreferences prefs = notificationService.updatePreferences(userId, updates);
        return NotificationPreferencesResponse.from(prefs);
    }
}
