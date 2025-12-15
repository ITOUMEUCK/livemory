package com.livemory.livemory_api.guest;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface GuestUserRepository extends JpaRepository<GuestUser, Long> {

    Optional<GuestUser> findByGuestToken(String guestToken);

    Optional<GuestUser> findByEmail(String email);

    Optional<GuestUser> findByPhone(String phone);
}
