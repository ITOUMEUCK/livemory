package com.livemory.livemory_api.paymentlink;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PaymentLinkRepository extends JpaRepository<PaymentLink, Long> {

    List<PaymentLink> findByEventId(Long eventId);

    List<PaymentLink> findByBudgetId(Long budgetId);

    List<PaymentLink> findByEventIdAndStatus(Long eventId, PaymentLinkStatus status);
}
