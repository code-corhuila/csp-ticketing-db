-- V002: Create user_contact table for contact projection (HU-TICKETING-001)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-001, FR-TICKETING-001, ADR-017, Annex A/G/J
-- Issue: csp-ticketing-db#1

CREATE TABLE ticketing_fulfillment.user_contact (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL,
    email           TEXT        NOT NULL,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Audit (per csp-auth-db V002/V006 pattern)
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_user_contact PRIMARY KEY (id),
    CONSTRAINT uk_user_contact_user_id UNIQUE (user_id),
    CONSTRAINT chk_user_contact_email_length CHECK (char_length(email) BETWEEN 3 AND 255),
    CONSTRAINT chk_user_contact_email_format CHECK (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$')
);

-- Full index on FK column (Annex A rule 3)
CREATE INDEX idx_user_contact_user_id ON ticketing_fulfillment.user_contact (user_id);

-- Grants (Annex G/J)
GRANT SELECT, INSERT, UPDATE ON ticketing_fulfillment.user_contact TO ticketing_writer;
GRANT SELECT ON ticketing_fulfillment.user_contact TO ticketing_reader;