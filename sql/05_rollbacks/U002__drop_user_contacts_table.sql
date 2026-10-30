-- U002: Rollback V002 — Drop user_contacts table
-- WARNING: Destructive. Run only in controlled recovery (ADR-017).

REVOKE ALL ON ticketing_fulfillment.user_contacts FROM ticketing_writer, ticketing_reader;
DROP TABLE IF EXISTS ticketing_fulfillment.user_contacts;