-- Test: outbox_event constraints and tickets that exist before their contact (HU-TICKETING-002)
-- Expected: valid rows insert; invalid rows are rejected; a ticket needs no contact and no showtime start

\set ON_ERROR_STOP on

BEGIN;

INSERT INTO ticketing_fulfillment.outbox_event (aggregate_type, aggregate_id, event_type, payload)
VALUES ('Ticket', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'TicketIssued', '{"eventType":"TicketIssued"}');

DO $$
BEGIN
  BEGIN
    INSERT INTO ticketing_fulfillment.outbox_event (aggregate_type, aggregate_id, event_type, payload)
    VALUES ('', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'TicketIssued', '{}');
    RAISE EXCEPTION 'FAIL: empty aggregate_type accepted';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;
  BEGIN
    INSERT INTO ticketing_fulfillment.outbox_event (aggregate_type, aggregate_id, event_type, payload)
    VALUES ('Ticket', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'TicketIssued', NULL);
    RAISE EXCEPTION 'FAIL: null payload accepted';
  EXCEPTION WHEN not_null_violation THEN
    NULL;
  END;
END $$;

-- A ticket with no contact and no showtime start is valid; user_id is still required.
INSERT INTO ticketing_fulfillment.tickets
    (user_id, reservation_id, showtime_id, movie_title_snapshot, room_name_snapshot,
     seat_labels_snapshot, qr_payload)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
        'ffffffff-ffff-ffff-ffff-ffffffffffff', 'Movie', 'Room 1', '["A1"]', 'CSP-test');

DO $$
BEGIN
  BEGIN
    INSERT INTO ticketing_fulfillment.tickets
        (reservation_id, showtime_id, movie_title_snapshot, room_name_snapshot,
         seat_labels_snapshot, qr_payload)
    VALUES ('99999999-9999-9999-9999-999999999999', 'ffffffff-ffff-ffff-ffff-ffffffffffff',
            'Movie', 'Room 1', '["A1"]', 'CSP-test');
    RAISE EXCEPTION 'FAIL: ticket without user_id accepted';
  EXCEPTION WHEN not_null_violation THEN
    NULL;
  END;
END $$;

ROLLBACK;

SELECT 'PASS: outbox_event constraints and late-contact tickets work' AS result;
