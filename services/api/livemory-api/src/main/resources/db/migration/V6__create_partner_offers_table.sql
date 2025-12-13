-- Create partner_offers table
CREATE TABLE partner_offers (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description VARCHAR(2000),
  partner_name VARCHAR(200) NOT NULL,
  category VARCHAR(50) NOT NULL,
  discount_percentage DECIMAL(5, 2),
  location VARCHAR(500),
  website_url VARCHAR(500),
  image_url VARCHAR(255),
  min_group_size INTEGER NOT NULL,
  valid_from TIMESTAMP,
  valid_until TIMESTAMP,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_partner_offers_category ON partner_offers(category);
CREATE INDEX idx_partner_offers_active ON partner_offers(is_active);
CREATE INDEX idx_partner_offers_location ON partner_offers(location);
