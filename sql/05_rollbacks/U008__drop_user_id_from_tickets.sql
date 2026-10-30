-- U008: Rollback V008 — Drop tickets.user_id and require user_contact_id again
-- WARNING: fails while a ticket has no contact. Run only in controlled recovery (ADR-017).

DROP INDEX IF EXISTS ticketing_fulfillment.idx_tickets_user_id;
ALTER TABLE ticketing_fulfillment.tickets ALTER COLUMN user_contact_id SET NOT NULL;
ALTER TABLE ticketing_fulfillment.tickets DROP COLUMN IF EXISTS user_id;
