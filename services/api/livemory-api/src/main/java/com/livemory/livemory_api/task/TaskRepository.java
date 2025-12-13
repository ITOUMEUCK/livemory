package com.livemory.livemory_api.task;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByEventId(Long eventId);

    List<Task> findByStepId(Long stepId);

    List<Task> findByAssignedToId(Long userId);

    List<Task> findByEventIdAndStatus(Long eventId, TaskStatus status);
}
