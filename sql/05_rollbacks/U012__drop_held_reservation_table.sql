-- U012: Rollback V012 — Drop held_reservation table
-- WARNING: Destructive, the holds known by Ticketing are lost and no reminder is sent for them. Run only in controlled recovery (ADR-017).

REVOKE ALL ON ticketing_fulfillment.held_reservation FROM ticketing_writer, ticketing_reader;
DROP TABLE IF EXISTS ticketing_fulfillment.held_reservation;
