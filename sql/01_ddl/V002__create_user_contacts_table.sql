-- V002: Create user_contacts table for contact projection (HU-TICKETING-001)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-001, FR-TICKETING-001, ADR-017

CREATE TABLE ticketing_fulfillment.user_contacts (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL,
    email           VARCHAR(255) NOT NULL,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Audit
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_user_contacts PRIMARY KEY (id),
    CONSTRAINT uk_user_contacts_user_id UNIQUE (user_id),
    CONSTRAINT chk_user_contacts_email_length CHECK (char_length(email) BETWEEN 3 AND 255)
);

-- Index for upsert performance
CREATE INDEX idx_user_contacts_user_id ON ticketing_fulfillment.user_contacts (user_id);

-- Grants
GRANT SELECT, INSERT, UPDATE ON ticketing_fulfillment.user_contacts TO ticketing_writer;
GRANT SELECT ON ticketing_fulfillment.user_contacts TO ticketing_reader;