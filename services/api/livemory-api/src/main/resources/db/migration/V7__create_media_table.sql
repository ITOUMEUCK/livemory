-- Create media table
CREATE TABLE media (
  id BIGSERIAL PRIMARY KEY,
  event_id BIGINT NOT NULL,
  step_id BIGINT,
  uploaded_by_user_id BIGINT NOT NULL,
  type VARCHAR(50) NOT NULL,
  url VARCHAR(500) NOT NULL,
  thumbnail_url VARCHAR(500),
  caption VARCHAR(500),
  file_size BIGINT NOT NULL,
  mime_type VARCHAR(100),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY (step_id) REFERENCES steps(id) ON DELETE CASCADE,
  FOREIGN KEY (uploaded_by_user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_media_event ON media(event_id);
CREATE INDEX idx_media_step ON media(step_id);
CREATE INDEX idx_media_uploaded_by ON media(uploaded_by_user_id);
CREATE INDEX idx_media_type ON media(type);
