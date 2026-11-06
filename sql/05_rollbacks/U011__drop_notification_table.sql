-- U011: Rollback V011 — Drop notification table
-- WARNING: Destructive, the notifications of the users are lost. Run only in controlled recovery (ADR-017).

REVOKE ALL ON ticketing_fulfillment.notification FROM ticketing_writer, ticketing_reader;
DROP TABLE IF EXISTS ticketing_fulfillment.notification;
