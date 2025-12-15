-- Create suggestions table for transport and accommodation
CREATE TABLE suggestions (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    suggestion_type VARCHAR(50) NOT NULL,  -- TRANSPORT, ACCOMMODATION, ACTIVITY
    provider_name VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    url TEXT,
    price_per_person DECIMAL(10, 2),
    group_discount_available BOOLEAN NOT NULL DEFAULT FALSE,
    min_group_size INT,
    discount_percentage DECIMAL(5, 2),
    location VARCHAR(255),
    departure_location VARCHAR(255),
    arrival_location VARCHAR(255),
    departure_time TIMESTAMP,
    arrival_time TIMESTAMP,
    created_by_id BIGINT REFERENCES users(id),
    is_system_suggestion BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_suggestions_event ON suggestions(event_id);
CREATE INDEX idx_suggestions_type ON suggestions(suggestion_type);
CREATE INDEX idx_suggestions_group_discount ON suggestions(group_discount_available);
