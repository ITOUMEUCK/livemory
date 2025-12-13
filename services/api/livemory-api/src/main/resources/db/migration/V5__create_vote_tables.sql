-- Create votes table
CREATE TABLE votes (
  id BIGSERIAL PRIMARY KEY,
  event_id BIGINT NOT NULL,
  step_id BIGINT,
  question VARCHAR(200) NOT NULL,
  type VARCHAR(50) NOT NULL,
  multiple_choice BOOLEAN NOT NULL,
  ends_at TIMESTAMP NOT NULL,
  status VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY (step_id) REFERENCES steps(id) ON DELETE CASCADE
);

-- Create vote_options table
CREATE TABLE vote_options (
  id BIGSERIAL PRIMARY KEY,
  vote_id BIGINT NOT NULL,
  option_text VARCHAR(200) NOT NULL,
  vote_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (vote_id) REFERENCES votes(id) ON DELETE CASCADE
);

-- Create user_votes table (tracks which users voted for which options)
CREATE TABLE user_votes (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  vote_option_id BIGINT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (vote_option_id) REFERENCES vote_options(id) ON DELETE CASCADE,
  UNIQUE (user_id, vote_option_id)
);

-- Create indexes
CREATE INDEX idx_votes_event ON votes(event_id);
CREATE INDEX idx_votes_step ON votes(step_id);
CREATE INDEX idx_vote_options_vote ON vote_options(vote_id);
CREATE INDEX idx_user_votes_user ON user_votes(user_id);
CREATE INDEX idx_user_votes_option ON user_votes(vote_option_id);
