-- V009: Allow a ticket whose showtime start is not known yet (HU-TICKETING-002)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-002, ADR-057 (decision 6), ADR-020
-- Booking sends showtimeStartsAt as null until Catalog exists; the ticket is issued anyway.

ALTER TABLE ticketing_fulfillment.tickets ALTER COLUMN showtime_starts_at DROP NOT NULL;
