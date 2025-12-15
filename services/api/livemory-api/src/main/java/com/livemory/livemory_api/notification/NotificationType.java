package com.livemory.livemory_api.notification;

public enum NotificationType {
    EVENT_REMINDER, // Rappel J-7, J-1
    EVENT_UPDATED, // Événement modifié
    TASK_ASSIGNED, // Tâche assignée
    TASK_COMPLETED, // Tâche complétée
    VOTE_CREATED, // Nouveau vote
    VOTE_CLOSING_SOON, // Vote bientôt clos
    BUDGET_ALERT, // Budget dépassé
    PAYMENT_REQUEST, // Demande de paiement
    GROUP_INVITATION, // Invitation groupe
    EVENT_INVITATION, // Invitation événement
    NEW_COMMENT, // Nouveau commentaire
    PARTICIPANT_JOINED // Nouveau participant
}
