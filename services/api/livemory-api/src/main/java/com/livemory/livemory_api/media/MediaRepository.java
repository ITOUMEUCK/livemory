package com.livemory.livemory_api.media;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MediaRepository extends JpaRepository<Media, Long> {
    List<Media> findByEventId(Long eventId);

    List<Media> findByStepId(Long stepId);

    List<Media> findByUploadedById(Long userId);

    List<Media> findByEventIdAndType(Long eventId, MediaType type);
}
