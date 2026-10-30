-- Test: status check constraint on ticketing_fulfillments
-- Expected: INSERT with invalid status fails

\set ON_ERROR_STOP on

-- Valid insert
INSERT INTO ticketing_fulfillment.tickets (user_id, user_contact_id, reservation_id, showtime_id, movie_title_snapshot, room_name_snapshot, showtime_starts_at, seat_labels_snapshot, qr_payload)
VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'Test Movie',
    'Room 1',
    '2026-10-23T20:00:00Z',
    '["A1", "A2"]',
    'CSP-bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb-A1-A2'
);

-- Valid status PENDING
INSERT INTO ticketing_fulfillment.ticketing_fulfillments (ticket_id, channel, status)
SELECT id, 'EMAIL', 'PENDING' FROM ticketing_fulfillment.tickets WHERE reservation_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

-- Valid status SENT
INSERT INTO ticketing_fulfillment.ticketing_fulfillments (ticket_id, channel, status)
SELECT id, 'EMAIL', 'SENT' FROM ticketing_fulfillment.tickets WHERE reservation_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

-- Valid status FAILED
INSERT INTO ticketing_fulfillment.ticketing_fulfillments (ticket_id, channel, status)
SELECT id, 'EMAIL', 'FAILED' FROM ticketing_fulfillment.tickets WHERE reservation_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

-- Invalid status should fail
\set EXPECT_ERROR check_violation
INSERT INTO ticketing_fulfillment.ticketing_fulfillments (ticket_id, channel, status)
SELECT id, 'EMAIL', 'INVALID_STATUS' FROM ticketing_fulfillment.tickets WHERE reservation_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
\unset EXPECT_ERROR

SELECT 'PASS: status check constraint works' AS result;