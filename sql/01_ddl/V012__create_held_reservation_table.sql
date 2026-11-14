-- V012: Create held_reservation table (HU-TICKETING-005)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-005, csp-docs#350 (ADR of the hold expiry reminder)
-- The active holds that Ticketing knows from the ReservationHeld event of Booking (it carries expiresAt). The reminder
-- job of csp-worker reads the unresolved and not yet warned holds ordered by expires_at; resolved_at is filled when
-- BookingConfirmed or ReservationExpired arrives for the reservation, warned_at when the HOLD_EXPIRY_WARNING
-- notification is created. No foreign keys: the reservation, the user and the showtime belong to other services.

CREATE TABLE ticketing_fulfillment.held_reservation (
    id             UUID        NOT NULL DEFAULT gen_random_uuid(),
    reservation_id UUID        NOT NULL,
    user_id        UUID        NOT NULL,
    showtime_id    UUID        NOT NULL,
    seat_labels    JSONB       NOT NULL,
    expires_at     TIMESTAMPTZ NOT NULL,
    resolved_at    TIMESTAMPTZ,
    warned_at      TIMESTAMPTZ,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_held_reservation PRIMARY KEY (id),
    CONSTRAINT uq_held_reservation_reservation_id UNIQUE (reservation_id),
    CONSTRAINT chk_held_reservation_seat_labels_array CHECK (jsonb_typeof(seat_labels) = 'array')
);

-- The walk of the reminder job: holds not resolved and not warned, by expiry. Partial on purpose, it is not on a FK column.
CREATE INDEX idx_held_reservation_pending_expires_at ON ticketing_fulfillment.held_reservation (expires_at)
    WHERE resolved_at IS NULL AND warned_at IS NULL;

-- Grants (Annex G/J): the service inserts, reads and marks a hold as resolved or warned; it never deletes one.
GRANT SELECT, INSERT, UPDATE ON ticketing_fulfillment.held_reservation TO ticketing_writer;
REVOKE DELETE, TRUNCATE ON ticketing_fulfillment.held_reservation FROM ticketing_writer;
GRANT SELECT ON ticketing_fulfillment.held_reservation TO ticketing_reader;
