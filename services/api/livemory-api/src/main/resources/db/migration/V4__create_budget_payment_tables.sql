-- Create budgets table
CREATE TABLE budgets (
  id BIGSERIAL PRIMARY KEY,
  event_id BIGINT NOT NULL,
  total_budget DECIMAL(10, 2) NOT NULL,
  total_spent DECIMAL(10, 2) NOT NULL DEFAULT 0,
  currency VARCHAR(3),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

-- Create payments table
CREATE TABLE payments (
  id BIGSERIAL PRIMARY KEY,
  event_id BIGINT NOT NULL,
  paid_by_user_id BIGINT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3),
  description VARCHAR(200) NOT NULL,
  category VARCHAR(50) NOT NULL,
  payment_date TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY (paid_by_user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_budgets_event ON budgets(event_id);
CREATE INDEX idx_payments_event ON payments(event_id);
CREATE INDEX idx_payments_paid_by ON payments(paid_by_user_id);
