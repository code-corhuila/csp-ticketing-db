-- V011: Create notification table (HU-TICKETING-005)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-005, FR-TICKETING-005, ADR-008
-- One row per fact the client is told about: BOOKING_CONFIRMED and RESERVATION_EXPIRED come from the events of Booking,
-- TICKET_ISSUED from the registration of the PDF, HOLD_EXPIRY_WARNING from the reminder of csp-worker. The same fact
-- never creates two rows: (reservation_id, type) is unique, so a redelivered event is absorbed.

CREATE TABLE ticketing_fulfillment.notification (
    id             UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id        UUID        NOT NULL,
    reservation_id UUID        NOT NULL,
    type           TEXT        NOT NULL,
    message        TEXT        NOT NULL,
    metadata       JSONB       NOT NULL DEFAULT '{}'::jsonb,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_notification PRIMARY KEY (id),
    CONSTRAINT uq_notification_reservation_id_type UNIQUE (reservation_id, type),
    CONSTRAINT chk_notification_type CHECK (type IN ('HOLD_EXPIRY_WARNING', 'BOOKING_CONFIRMED', 'RESERVATION_EXPIRED', 'TICKET_ISSUED')),
    CONSTRAINT chk_notification_message_length CHECK (char_length(message) BETWEEN 1 AND 500),
    CONSTRAINT chk_notification_metadata_object CHECK (jsonb_typeof(metadata) = 'object')
);

-- The list of a user, newest first (GET /me/notifications).
CREATE INDEX idx_notification_user_id_created_at ON ticketing_fulfillment.notification (user_id, created_at DESC, id);

-- Grants (Annex G/J): the service inserts and reads; a notification is never rewritten or deleted.
GRANT SELECT, INSERT ON ticketing_fulfillment.notification TO ticketing_writer;
REVOKE UPDATE, DELETE, TRUNCATE ON ticketing_fulfillment.notification FROM ticketing_writer;
GRANT SELECT ON ticketing_fulfillment.notification TO ticketing_reader;
