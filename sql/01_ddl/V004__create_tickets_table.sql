-- V004: Create tickets table for ticket issuance (HU-TICKETING-002)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-002, FR-TICKETING-002, ADR-017

CREATE TABLE ticketing_fulfillment.tickets (
    id                       UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_contact_id          UUID        NOT NULL,
    reservation_id           UUID        NOT NULL,
    showtime_id              UUID        NOT NULL,
    movie_title_snapshot     VARCHAR(255) NOT NULL,
    room_name_snapshot       VARCHAR(160) NOT NULL,
    showtime_starts_at       TIMESTAMPTZ NOT NULL,
    seat_labels_snapshot     JSONB       NOT NULL,
    concessions_snapshot     JSONB,
    qr_payload               TEXT        NOT NULL,
    pdf_url                  VARCHAR(500),
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_tickets PRIMARY KEY (id),
    CONSTRAINT uk_tickets_reservation_id UNIQUE (reservation_id),
    CONSTRAINT chk_tickets_qr_payload_length CHECK (char_length(qr_payload) BETWEEN 1 AND 500)
);

-- Index for user ticket queries
CREATE INDEX idx_tickets_user_contact_id ON ticketing_fulfillment.tickets (user_contact_id);
CREATE INDEX idx_tickets_showtime_id ON ticketing_fulfillment.tickets (showtime_id);

-- Grants
GRANT SELECT, INSERT, UPDATE ON ticketing_fulfillment.tickets TO ticketing_writer;
GRANT SELECT ON ticketing_fulfillment.tickets TO ticketing_reader;