package com.livemory.livemory_api.guest;

import com.livemory.livemory_api.invitation.Invitation;
import com.livemory.livemory_api.invitation.InvitationRepository;
import com.livemory.livemory_api.user.User;
import com.livemory.livemory_api.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@Transactional
public class GuestUserService {

    private final GuestUserRepository guestUserRepository;
    private final InvitationRepository invitationRepository;
    private final UserRepository userRepository;

    public GuestUserService(GuestUserRepository guestUserRepository,
            InvitationRepository invitationRepository,
            UserRepository userRepository) {
        this.guestUserRepository = guestUserRepository;
        this.invitationRepository = invitationRepository;
        this.userRepository = userRepository;
    }

    public GuestUser createGuest(CreateGuestRequest request) {
        GuestUser guest = new GuestUser();
        guest.setGuestToken(generateUniqueToken());
        guest.setName(request.name());
        guest.setEmail(request.email());
        guest.setPhone(request.phone());

        if (request.invitationToken() != null) {
            Invitation invitation = invitationRepository.findByToken(request.invitationToken())
                    .orElse(null);
            guest.setCreatedFromInvitation(invitation);
        }

        return guestUserRepository.save(guest);
    }

    @Transactional(readOnly = true)
    public GuestUser getGuestByToken(String token) {
        GuestUser guest = guestUserRepository.findByGuestToken(token)
                .orElseThrow(() -> new IllegalArgumentException("Guest user not found"));

        guest.updateActivity();
        guestUserRepository.save(guest);

        return guest;
    }

    public User convertToFullUser(String guestToken, String email, String password) {
        GuestUser guest = getGuestByToken(guestToken);

        if (guest.isConverted()) {
            throw new IllegalArgumentException("Guest has already been converted");
        }

        // Check if email already exists
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("Email already in use");
        }

        User user = new User();
        // Split name into first and last name (simple split on first space)
        String[] nameParts = guest.getName().split(" ", 2);
        user.setFirstName(nameParts[0]);
        user.setLastName(nameParts.length > 1 ? nameParts[1] : "");
        user.setEmail(email);
        // Note: In a real app, you'd hash the password here
        // user.setPasswordHash(passwordEncoder.encode(password));

        user = userRepository.save(user);

        guest.setConvertedToUser(user);
        guestUserRepository.save(guest);

        return user;
    }

    private String generateUniqueToken() {
        String token;
        do {
            token = "guest_" + UUID.randomUUID().toString().replace("-", "");
        } while (guestUserRepository.findByGuestToken(token).isPresent());
        return token;
    }
}
