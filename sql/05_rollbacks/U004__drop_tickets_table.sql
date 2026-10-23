-- U004: Rollback V004 — Drop tickets table
-- WARNING: Destructive. Run only in controlled recovery (ADR-017).

REVOKE ALL ON ticketing_fulfillment.tickets FROM ticketing_writer, ticketing_reader;
DROP TABLE IF EXISTS ticketing_fulfillment.tickets;