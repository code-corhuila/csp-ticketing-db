-- V007: Create outbox_event table for the transactional outbox (HU-TICKETING-002)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-002, ADR-057, ADR-014, norm 5.3.11
-- The API inserts the row in the same transaction as the change; csp-worker only reads it
-- and keeps its publication state in its own schema, so this table has no processed_at.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ticketing_outbox_reader') THEN
    CREATE ROLE ticketing_outbox_reader NOLOGIN;
  END IF;
END $$;

CREATE TABLE ticketing_fulfillment.outbox_event (
    id             UUID        NOT NULL DEFAULT gen_random_uuid(),
    aggregate_type TEXT        NOT NULL,
    aggregate_id   UUID        NOT NULL,
    event_type     TEXT        NOT NULL,
    payload        JSONB       NOT NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_outbox_event PRIMARY KEY (id),
    CONSTRAINT chk_outbox_event_aggregate_type_length CHECK (char_length(aggregate_type) BETWEEN 1 AND 100),
    CONSTRAINT chk_outbox_event_event_type_length CHECK (char_length(event_type) BETWEEN 1 AND 100)
);

-- The relay query of csp-worker: oldest pending rows first.
CREATE INDEX idx_outbox_event_created_at_id ON ticketing_fulfillment.outbox_event (created_at, id);

-- Grants (Annex G/J). The writer cannot update or delete: published rows are never rewritten.
GRANT SELECT, INSERT ON ticketing_fulfillment.outbox_event TO ticketing_writer;
-- The default privileges of V001 would also give the writer UPDATE and DELETE on a new table.
REVOKE UPDATE, DELETE, TRUNCATE ON ticketing_fulfillment.outbox_event FROM ticketing_writer;
GRANT SELECT ON ticketing_fulfillment.outbox_event TO ticketing_reader;
-- Narrower on purpose: csp-worker reads the outbox and nothing else (ADR-014).
GRANT USAGE ON SCHEMA ticketing_fulfillment TO ticketing_outbox_reader;
GRANT SELECT ON ticketing_fulfillment.outbox_event TO ticketing_outbox_reader;
