package com.livemory.livemory_api.offer;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PartnerOfferRepository extends JpaRepository<PartnerOffer, Long> {
    List<PartnerOffer> findByIsActiveTrue();

    List<PartnerOffer> findByCategory(OfferCategory category);

    List<PartnerOffer> findByCategoryAndIsActive(OfferCategory category, Boolean isActive);
}
