package com.livemory.livemory_api.invitation;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/invitations")
public class InvitationController {

    private final InvitationService invitationService;

    @Value("${app.base-url:http://localhost:8080}")
    private String baseUrl;

    public InvitationController(InvitationService invitationService) {
        this.invitationService = invitationService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public InvitationResponse createInvitation(@Valid @RequestBody CreateInvitationRequest request) {
        Invitation invitation = invitationService.createInvitation(request);
        return InvitationResponse.from(invitation, baseUrl);
    }

    @GetMapping("/{token}")
    public InvitationResponse getInvitation(@PathVariable String token) {
        Invitation invitation = invitationService.getInvitationByToken(token);
        return InvitationResponse.from(invitation, baseUrl);
    }

    @PostMapping("/accept")
    public void acceptInvitation(@Valid @RequestBody AcceptInvitationRequest request) {
        invitationService.acceptInvitation(request);
    }

    @PostMapping("/{token}/decline")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void declineInvitation(@PathVariable String token) {
        invitationService.declineInvitation(token);
    }

    @GetMapping("/email/{email}")
    public List<InvitationResponse> getInvitationsByEmail(@PathVariable String email) {
        return invitationService.getInvitationsByEmail(email).stream()
                .map(inv -> InvitationResponse.from(inv, baseUrl))
                .toList();
    }

    @GetMapping("/group/{groupId}")
    public List<InvitationResponse> getInvitationsByGroup(@PathVariable Long groupId) {
        return invitationService.getInvitationsByGroup(groupId).stream()
                .map(inv -> InvitationResponse.from(inv, baseUrl))
                .toList();
    }

    @GetMapping("/event/{eventId}")
    public List<InvitationResponse> getInvitationsByEvent(@PathVariable Long eventId) {
        return invitationService.getInvitationsByEvent(eventId).stream()
                .map(inv -> InvitationResponse.from(inv, baseUrl))
                .toList();
    }
}
