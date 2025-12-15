-- Create payment_links table
CREATE TABLE payment_links (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    budget_id BIGINT REFERENCES budgets(id) ON DELETE CASCADE,
    payment_provider VARCHAR(50) NOT NULL,  -- LYDIA, PAYPAL, STRIPE, etc.
    payment_url TEXT NOT NULL,
    amount DECIMAL(10, 2),
    description TEXT,
    created_by_id BIGINT NOT NULL REFERENCES users(id),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payment_links_event ON payment_links(event_id);
CREATE INDEX idx_payment_links_budget ON payment_links(budget_id);
CREATE INDEX idx_payment_links_provider ON payment_links(payment_provider);
