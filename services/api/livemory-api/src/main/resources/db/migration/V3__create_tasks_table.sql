-- Create tasks table
CREATE TABLE tasks (
  id BIGSERIAL PRIMARY KEY,
  event_id BIGINT NOT NULL,
  step_id BIGINT,
  title VARCHAR(200) NOT NULL,
  description VARCHAR(2000),
  assigned_to_user_id BIGINT,
  status VARCHAR(50) NOT NULL,
  priority VARCHAR(50) NOT NULL,
  due_date TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY (step_id) REFERENCES steps(id) ON DELETE CASCADE,
  FOREIGN KEY (assigned_to_user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Create indexes
CREATE INDEX idx_tasks_event ON tasks(event_id);
CREATE INDEX idx_tasks_step ON tasks(step_id);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to_user_id);
CREATE INDEX idx_tasks_status ON tasks(status);
