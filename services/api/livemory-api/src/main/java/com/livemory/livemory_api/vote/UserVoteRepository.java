package com.livemory.livemory_api.vote;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserVoteRepository extends JpaRepository<UserVote, Long> {
    List<UserVote> findByUserId(Long userId);

    List<UserVote> findByVoteOptionId(Long voteOptionId);

    Optional<UserVote> findByUserIdAndVoteOptionId(Long userId, Long voteOptionId);
}
