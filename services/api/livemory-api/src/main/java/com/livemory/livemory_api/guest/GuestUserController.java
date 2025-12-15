package com.livemory.livemory_api.guest;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/guests")
public class GuestUserController {

    private final GuestUserService guestUserService;

    public GuestUserController(GuestUserService guestUserService) {
        this.guestUserService = guestUserService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public GuestUserResponse createGuest(@Valid @RequestBody CreateGuestRequest request) {
        GuestUser guest = guestUserService.createGuest(request);
        return GuestUserResponse.from(guest);
    }

    @GetMapping("/{token}")
    public GuestUserResponse getGuest(@PathVariable String token) {
        GuestUser guest = guestUserService.getGuestByToken(token);
        return GuestUserResponse.from(guest);
    }

    @PostMapping("/{token}/convert")
    public Long convertToFullUser(@PathVariable String token,
            @RequestParam String email,
            @RequestParam String password) {
        return guestUserService.convertToFullUser(token, email, password).getId();
    }
}
