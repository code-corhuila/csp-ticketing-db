-- U003: Rollback V003 — Drop inbox_event table
-- WARNING: Destructive. Run only in controlled recovery (ADR-017).

REVOKE ALL ON ticketing_fulfillment.inbox_event FROM ticketing_writer, ticketing_reader;
DROP TABLE IF EXISTS ticketing_fulfillment.inbox_event;