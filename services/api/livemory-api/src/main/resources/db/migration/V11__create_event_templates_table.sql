-- Create event_templates table
CREATE TABLE event_templates (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) NOT NULL,
    icon VARCHAR(50),
    default_duration_hours INT,
    suggested_tasks TEXT,  -- JSON array of suggested task names
    suggested_budget_categories TEXT,  -- JSON array of budget categories
    is_system_template BOOLEAN NOT NULL DEFAULT FALSE,
    created_by_id BIGINT REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_event_templates_type ON event_templates(event_type);
CREATE INDEX idx_event_templates_system ON event_templates(is_system_template);
