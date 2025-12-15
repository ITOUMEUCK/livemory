package com.livemory.livemory_api.group;

import com.livemory.livemory_api.user.User;
import com.livemory.livemory_api.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class GroupService {

    private final GroupRepository groupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final UserRepository userRepository;

    public GroupService(GroupRepository groupRepository,
            GroupMemberRepository groupMemberRepository,
            UserRepository userRepository) {
        this.groupRepository = groupRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.userRepository = userRepository;
    }

    public Group createGroup(CreateGroupRequest request, Long createdById) {
        User creator = userRepository.findById(createdById)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Group group = new Group();
        group.setName(request.name());
        group.setDescription(request.description());
        group.setCreatedBy(creator);

        group = groupRepository.save(group);

        // Add creator as OWNER
        GroupMember ownerMember = new GroupMember();
        ownerMember.setGroup(group);
        ownerMember.setUser(creator);
        ownerMember.setRole(GroupRole.OWNER);
        groupMemberRepository.save(ownerMember);

        return group;
    }

    @Transactional(readOnly = true)
    public List<Group> getUserGroups(Long userId) {
        return groupRepository.findGroupsByUserId(userId);
    }

    @Transactional(readOnly = true)
    public Group getGroupById(Long id) {
        return groupRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Group not found"));
    }

    public GroupMember addMember(Long groupId, AddMemberRequest request) {
        Group group = getGroupById(groupId);
        User user = userRepository.findById(request.userId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (groupMemberRepository.existsByGroupIdAndUserId(groupId, request.userId())) {
            throw new IllegalArgumentException("User is already a member of this group");
        }

        GroupMember member = new GroupMember();
        member.setGroup(group);
        member.setUser(user);
        member.setRole(request.role() != null ? request.role() : GroupRole.MEMBER);

        return groupMemberRepository.save(member);
    }

    @Transactional(readOnly = true)
    public List<GroupMember> getGroupMembers(Long groupId) {
        return groupMemberRepository.findByGroupId(groupId);
    }

    public void removeMember(Long groupId, Long userId) {
        GroupMember member = groupMemberRepository.findByGroupIdAndUserId(groupId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Member not found"));

        if (member.getRole() == GroupRole.OWNER) {
            throw new IllegalArgumentException("Cannot remove group owner");
        }

        groupMemberRepository.delete(member);
    }

    public void deleteGroup(Long groupId, Long userId) {
        Group group = getGroupById(groupId);

        if (!group.getCreatedBy().getId().equals(userId)) {
            throw new IllegalArgumentException("Only group owner can delete the group");
        }

        groupRepository.delete(group);
    }
}
