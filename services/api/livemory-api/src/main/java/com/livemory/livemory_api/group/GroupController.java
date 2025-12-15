package com.livemory.livemory_api.group;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/groups")
public class GroupController {

    private final GroupService groupService;

    public GroupController(GroupService groupService) {
        this.groupService = groupService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public GroupResponse createGroup(@Valid @RequestBody CreateGroupRequest request,
            @RequestParam Long createdById) {
        Group group = groupService.createGroup(request, createdById);
        return GroupResponse.from(group);
    }

    @GetMapping("/user/{userId}")
    public List<GroupResponse> getUserGroups(@PathVariable Long userId) {
        return groupService.getUserGroups(userId).stream()
                .map(GroupResponse::from)
                .toList();
    }

    @GetMapping("/{id}")
    public GroupResponse getGroup(@PathVariable Long id) {
        Group group = groupService.getGroupById(id);
        return GroupResponse.from(group);
    }

    @PostMapping("/{groupId}/members")
    @ResponseStatus(HttpStatus.CREATED)
    public GroupMemberResponse addMember(@PathVariable Long groupId,
            @Valid @RequestBody AddMemberRequest request) {
        GroupMember member = groupService.addMember(groupId, request);
        return GroupMemberResponse.from(member);
    }

    @GetMapping("/{groupId}/members")
    public List<GroupMemberResponse> getGroupMembers(@PathVariable Long groupId) {
        return groupService.getGroupMembers(groupId).stream()
                .map(GroupMemberResponse::from)
                .toList();
    }

    @DeleteMapping("/{groupId}/members/{userId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void removeMember(@PathVariable Long groupId, @PathVariable Long userId) {
        groupService.removeMember(groupId, userId);
    }

    @DeleteMapping("/{groupId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteGroup(@PathVariable Long groupId, @RequestParam Long userId) {
        groupService.deleteGroup(groupId, userId);
    }
}
