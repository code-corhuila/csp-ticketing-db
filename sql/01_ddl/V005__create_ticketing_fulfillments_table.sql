-- V005: Create ticketing_fulfillments table for email delivery jobs (HU-TICKETING-002)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-002, FR-TICKETING-002, FR-TICKETING-004, ADR-017

CREATE TABLE ticketing_fulfillment.ticketing_fulfillments (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    ticket_id       UUID        NOT NULL,
    channel         VARCHAR(50) NOT NULL DEFAULT 'EMAIL',
    status          VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    attempts        INT         NOT NULL DEFAULT 0,
    last_error      TEXT,
    next_retry_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_ticketing_fulfillments PRIMARY KEY (id),
    CONSTRAINT fk_ticketing_fulfillments_ticket FOREIGN KEY (ticket_id) REFERENCES ticketing_fulfillment.tickets (id) ON DELETE CASCADE,
    CONSTRAINT chk_ticketing_fulfillments_status CHECK (status IN ('PENDING', 'SENT', 'FAILED')),
    CONSTRAINT chk_ticketing_fulfillments_channel CHECK (channel IN ('EMAIL'))
);

-- Index for retry scheduler
CREATE INDEX idx_ticketing_fulfillments_status_next_retry ON ticketing_fulfillment.ticketing_fulfillments (status, next_retry_at) WHERE status = 'PENDING';
CREATE INDEX idx_ticketing_fulfillments_ticket_id ON ticketing_fulfillment.ticketing_fulfillments (ticket_id);

-- Grants
GRANT SELECT, INSERT, UPDATE ON ticketing_fulfillment.ticketing_fulfillments TO ticketing_writer;
GRANT SELECT ON ticketing_fulfillment.ticketing_fulfillments TO ticketing_reader;