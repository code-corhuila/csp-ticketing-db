-- U005: Rollback V005 — Drop ticketing_fulfillments table
-- WARNING: Destructive. Run only in controlled recovery (ADR-017).

REVOKE ALL ON ticketing_fulfillment.ticketing_fulfillments FROM ticketing_writer, ticketing_reader;
DROP TABLE IF EXISTS ticketing_fulfillment.ticketing_fulfillments;