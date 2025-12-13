package com.livemory.livemory_api.payment;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    List<Payment> findByEventId(Long eventId);

    List<Payment> findByPaidById(Long userId);

    List<Payment> findByEventIdAndCategory(Long eventId, PaymentCategory category);
}
