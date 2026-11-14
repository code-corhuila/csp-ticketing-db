-- Test: unique reservation_id constraint on tickets
-- Expected: INSERT with duplicate reservation_id fails

\set ON_ERROR_STOP on

-- First insert
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

-- Second insert with same reservation_id should fail
\set EXPECT_ERROR unique_violation
INSERT INTO ticketing_fulfillment.tickets (user_id, user_contact_id, reservation_id, showtime_id, movie_title_snapshot, room_name_snapshot, showtime_starts_at, seat_labels_snapshot, qr_payload)
VALUES (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'Other Movie',
    'Room 2',
    '2026-10-24T20:00:00Z',
    '["B1", "B2"]',
    'CSP-bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb-B1-B2'
);
\unset EXPECT_ERROR

SELECT 'PASS: unique reservation_id constraint works' AS result;