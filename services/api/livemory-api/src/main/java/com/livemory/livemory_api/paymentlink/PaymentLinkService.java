package com.livemory.livemory_api.paymentlink;

import com.livemory.livemory_api.budget.Budget;
import com.livemory.livemory_api.budget.BudgetRepository;
import com.livemory.livemory_api.event.Event;
import com.livemory.livemory_api.event.EventRepository;
import com.livemory.livemory_api.user.User;
import com.livemory.livemory_api.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
public class PaymentLinkService {

    private final PaymentLinkRepository paymentLinkRepository;
    private final EventRepository eventRepository;
    private final BudgetRepository budgetRepository;
    private final UserRepository userRepository;

    public PaymentLinkService(PaymentLinkRepository paymentLinkRepository,
            EventRepository eventRepository,
            BudgetRepository budgetRepository,
            UserRepository userRepository) {
        this.paymentLinkRepository = paymentLinkRepository;
        this.eventRepository = eventRepository;
        this.budgetRepository = budgetRepository;
        this.userRepository = userRepository;
    }

    public PaymentLink createPaymentLink(CreatePaymentLinkRequest request) {
        Event event = eventRepository.findById(request.eventId())
                .orElseThrow(() -> new IllegalArgumentException("Event not found"));

        User createdBy = userRepository.findById(request.createdById())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        PaymentLink paymentLink = new PaymentLink();
        paymentLink.setEvent(event);
        paymentLink.setPaymentProvider(request.paymentProvider());
        paymentLink.setPaymentUrl(request.paymentUrl());
        paymentLink.setAmount(request.amount());
        paymentLink.setDescription(request.description());
        paymentLink.setCreatedBy(createdBy);

        if (request.budgetId() != null) {
            Budget budget = budgetRepository.findById(request.budgetId())
                    .orElseThrow(() -> new IllegalArgumentException("Budget not found"));
            paymentLink.setBudget(budget);
        }

        if (request.expiresInDays() != null) {
            paymentLink.setExpiresAt(LocalDateTime.now().plusDays(request.expiresInDays()));
        }

        return paymentLinkRepository.save(paymentLink);
    }

    @Transactional(readOnly = true)
    public List<PaymentLink> getEventPaymentLinks(Long eventId) {
        return paymentLinkRepository.findByEventId(eventId);
    }

    @Transactional(readOnly = true)
    public List<PaymentLink> getActivePaymentLinks(Long eventId) {
        return paymentLinkRepository.findByEventIdAndStatus(eventId, PaymentLinkStatus.ACTIVE);
    }

    @Transactional(readOnly = true)
    public PaymentLink getPaymentLinkById(Long id) {
        PaymentLink paymentLink = paymentLinkRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Payment link not found"));

        // Auto-expire if needed
        if (paymentLink.isExpired() && paymentLink.getStatus() == PaymentLinkStatus.ACTIVE) {
            paymentLink.setStatus(PaymentLinkStatus.EXPIRED);
            paymentLinkRepository.save(paymentLink);
        }

        return paymentLink;
    }

    public void updateStatus(Long id, PaymentLinkStatus status) {
        PaymentLink paymentLink = getPaymentLinkById(id);
        paymentLink.setStatus(status);
        paymentLinkRepository.save(paymentLink);
    }

    public void deletePaymentLink(Long id) {
        paymentLinkRepository.deleteById(id);
    }

    /**
     * Generate Lydia payment URL
     * Note: This is a simplified version. Real implementation would use Lydia API
     */
    public String generateLydiaUrl(String recipient, BigDecimal amount, String message) {
        // Lydia URL format: lydia://pay?recipient=PHONE&amount=AMOUNT&message=MESSAGE
        return String.format("lydia://pay?recipient=%s&amount=%.2f&message=%s",
                recipient, amount, message);
    }

    /**
     * Generate PayPal payment URL
     * Note: This is a simplified version. Real implementation would use PayPal API
     */
    public String generatePayPalUrl(String email, BigDecimal amount, String description) {
        // PayPal.me format or full checkout URL
        return String.format("https://www.paypal.me/%s/%.2f", email, amount);
    }
}
