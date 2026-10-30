-- V006: Create pending_concession_order table for order-independent concession processing (HU-TICKETING-002)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-002, ADR-045, ADR-036

CREATE TABLE ticketing_fulfillment.pending_concession_order (
    reservation_id   UUID        NOT NULL,
    items_json       JSONB       NOT NULL,
    event_id         VARCHAR(36) NOT NULL,
    correlation_id   VARCHAR(100),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_pending_concession_order PRIMARY KEY (reservation_id)
);

-- Index for reservation_id lookups (also PK)
-- Unique constraint on reservation_id already enforced by PK

-- Grants
GRANT SELECT, INSERT, UPDATE, DELETE ON ticketing_fulfillment.pending_concession_order TO ticketing_writer;
GRANT SELECT ON ticketing_fulfillment.pending_concession_order TO ticketing_reader;