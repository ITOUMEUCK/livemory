-- Create users table
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  avatar_url VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create events table
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description VARCHAR(2000),
  type VARCHAR(50) NOT NULL,
  cover_image_url VARCHAR(255),
  created_by_user_id BIGINT NOT NULL,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create steps table
CREATE TABLE steps (
  id BIGSERIAL PRIMARY KEY,
  event_id BIGINT NOT NULL,
  title VARCHAR(200) NOT NULL,
  description VARCHAR(2000),
  location VARCHAR(500),
  step_order INTEGER NOT NULL,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

-- Create participants table
CREATE TABLE participants (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  event_id BIGINT NOT NULL,
  step_id BIGINT,
  role VARCHAR(50) NOT NULL,
  status VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY (step_id) REFERENCES steps(id) ON DELETE CASCADE,
  UNIQUE (user_id, event_id, step_id)
);

-- Create indexes
CREATE INDEX idx_events_created_by ON events(created_by_user_id);
CREATE INDEX idx_steps_event ON steps(event_id);
CREATE INDEX idx_participants_user ON participants(user_id);
CREATE INDEX idx_participants_event ON participants(event_id);
CREATE INDEX idx_participants_step ON participants(step_id);
