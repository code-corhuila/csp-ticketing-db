-- V003: Create inbox_event table for event idempotency (HU-TICKETING-001)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-001, FR-TICKETING-003, ADR-017, DEC-001
-- Issue: csp-ticketing-db#1

CREATE TABLE ticketing_fulfillment.inbox_event (
    id           UUID        NOT NULL DEFAULT gen_random_uuid(),
    event_id     UUID        NOT NULL,
    event_type   TEXT        NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    error        TEXT,

    CONSTRAINT pk_inbox_event PRIMARY KEY (id),
    CONSTRAINT uk_inbox_event_event_id UNIQUE (event_id),
    CONSTRAINT chk_inbox_event_event_type_length CHECK (char_length(event_type) BETWEEN 1 AND 100)
);

-- Index for lookup by event_id (idempotency check)
CREATE INDEX idx_inbox_event_event_id ON ticketing_fulfillment.inbox_event (event_id);

-- Grants (Annex G/J)
GRANT SELECT, INSERT ON ticketing_fulfillment.inbox_event TO ticketing_writer;
GRANT SELECT ON ticketing_fulfillment.inbox_event TO ticketing_reader;