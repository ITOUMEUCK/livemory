-- Create guest_users table for lightweight authentication
CREATE TABLE guest_users (
    id BIGSERIAL PRIMARY KEY,
    guest_token VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    created_from_invitation_id BIGINT REFERENCES invitations(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_active_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    converted_to_user_id BIGINT REFERENCES users(id)
);

CREATE INDEX idx_guest_users_token ON guest_users(guest_token);
CREATE INDEX idx_guest_users_email ON guest_users(email);
