package com.livemory.livemory_api.paymentlink;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/v1/payment-links")
public class PaymentLinkController {

    private final PaymentLinkService paymentLinkService;

    public PaymentLinkController(PaymentLinkService paymentLinkService) {
        this.paymentLinkService = paymentLinkService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PaymentLinkResponse createPaymentLink(@Valid @RequestBody CreatePaymentLinkRequest request) {
        PaymentLink paymentLink = paymentLinkService.createPaymentLink(request);
        return PaymentLinkResponse.from(paymentLink);
    }

    @GetMapping("/event/{eventId}")
    public List<PaymentLinkResponse> getEventPaymentLinks(@PathVariable Long eventId) {
        return paymentLinkService.getEventPaymentLinks(eventId).stream()
                .map(PaymentLinkResponse::from)
                .toList();
    }

    @GetMapping("/event/{eventId}/active")
    public List<PaymentLinkResponse> getActivePaymentLinks(@PathVariable Long eventId) {
        return paymentLinkService.getActivePaymentLinks(eventId).stream()
                .map(PaymentLinkResponse::from)
                .toList();
    }

    @GetMapping("/{id}")
    public PaymentLinkResponse getPaymentLink(@PathVariable Long id) {
        PaymentLink paymentLink = paymentLinkService.getPaymentLinkById(id);
        return PaymentLinkResponse.from(paymentLink);
    }

    @PutMapping("/{id}/status")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void updateStatus(@PathVariable Long id, @RequestParam PaymentLinkStatus status) {
        paymentLinkService.updateStatus(id, status);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deletePaymentLink(@PathVariable Long id) {
        paymentLinkService.deletePaymentLink(id);
    }

    // Helper endpoints to generate URLs
    @GetMapping("/generate/lydia")
    public String generateLydiaUrl(@RequestParam String recipient,
            @RequestParam BigDecimal amount,
            @RequestParam String message) {
        return paymentLinkService.generateLydiaUrl(recipient, amount, message);
    }

    @GetMapping("/generate/paypal")
    public String generatePayPalUrl(@RequestParam String email,
            @RequestParam BigDecimal amount,
            @RequestParam String description) {
        return paymentLinkService.generatePayPalUrl(email, amount, description);
    }
}
