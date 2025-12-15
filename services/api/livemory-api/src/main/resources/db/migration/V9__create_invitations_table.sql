-- Create invitations table
CREATE TABLE invitations (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(255) NOT NULL UNIQUE,
    group_id BIGINT REFERENCES groups(id) ON DELETE CASCADE,
    event_id BIGINT REFERENCES events(id) ON DELETE CASCADE,
    invited_by_id BIGINT NOT NULL REFERENCES users(id),
    invited_email VARCHAR(255),
    invited_phone VARCHAR(50),
    role VARCHAR(50) NOT NULL DEFAULT 'MEMBER',
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    expires_at TIMESTAMP NOT NULL,
    accepted_at TIMESTAMP,
    accepted_by_id BIGINT REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_group_or_event CHECK (
        (group_id IS NOT NULL AND event_id IS NULL) OR 
        (group_id IS NULL AND event_id IS NOT NULL)
    )
);

CREATE INDEX idx_invitations_token ON invitations(token);
CREATE INDEX idx_invitations_group ON invitations(group_id);
CREATE INDEX idx_invitations_event ON invitations(event_id);
CREATE INDEX idx_invitations_status ON invitations(status);
