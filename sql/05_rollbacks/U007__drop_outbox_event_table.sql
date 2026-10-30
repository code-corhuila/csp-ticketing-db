-- U007: Rollback V007 — Drop outbox_event table
-- WARNING: Destructive, unpublished events are lost. Run only in controlled recovery (ADR-017).
-- The cluster-wide role ticketing_outbox_reader is left in place.

REVOKE ALL ON ticketing_fulfillment.outbox_event FROM ticketing_writer, ticketing_reader, ticketing_outbox_reader;
REVOKE USAGE ON SCHEMA ticketing_fulfillment FROM ticketing_outbox_reader;
DROP TABLE IF EXISTS ticketing_fulfillment.outbox_event;
