package com.livemory.livemory_api.vote;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VoteOptionRepository extends JpaRepository<VoteOption, Long> {
    List<VoteOption> findByVoteId(Long voteId);
}
