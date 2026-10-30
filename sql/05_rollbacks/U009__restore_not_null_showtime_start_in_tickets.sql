-- U009: Rollback V009 — Require showtime_starts_at again
-- WARNING: fails while a ticket has a null showtime start. Run only in controlled recovery (ADR-017).

ALTER TABLE ticketing_fulfillment.tickets ALTER COLUMN showtime_starts_at SET NOT NULL;
