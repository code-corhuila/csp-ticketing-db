-- Test: notification constraints (HU-TICKETING-005)
-- Expected: a valid row inserts; an unknown type, an empty message, a non-object metadata and a repeated
-- (reservation_id, type) are rejected; the same reservation can have one notification per type

\set ON_ERROR_STOP on

BEGIN;

INSERT INTO ticketing_fulfillment.notification (user_id, reservation_id, type, message)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'BOOKING_CONFIRMED', 'Tu reserva fue confirmada.');

INSERT INTO ticketing_fulfillment.notification (user_id, reservation_id, type, message, metadata)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'TICKET_ISSUED', 'Tu ticket esta listo.', '{"ticketId":"x"}');

DO $$
BEGIN
  BEGIN
    INSERT INTO ticketing_fulfillment.notification (user_id, reservation_id, type, message)
    VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'BOOKING_CONFIRMED', 'Otra vez.');
    RAISE EXCEPTION 'FAIL: repeated (reservation_id, type) accepted';
  EXCEPTION WHEN unique_violation THEN
    NULL;
  END;
  BEGIN
    INSERT INTO ticketing_fulfillment.notification (user_id, reservation_id, type, message)
    VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'SOMETHING_ELSE', 'x');
    RAISE EXCEPTION 'FAIL: unknown type accepted';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;
  BEGIN
    INSERT INTO ticketing_fulfillment.notification (user_id, reservation_id, type, message)
    VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'RESERVATION_EXPIRED', '');
    RAISE EXCEPTION 'FAIL: empty message accepted';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;
  BEGIN
    INSERT INTO ticketing_fulfillment.notification (user_id, reservation_id, type, message, metadata)
    VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'RESERVATION_EXPIRED', 'x', '[1]');
    RAISE EXCEPTION 'FAIL: array metadata accepted';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;
END $$;

SELECT 'PASS: notification constraints work' AS result;

ROLLBACK;
