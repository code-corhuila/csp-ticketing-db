-- Test: unique event_id constraint on inbox_event
-- Expected: INSERT with duplicate event_id fails

\set ON_ERROR_STOP on

-- First insert
INSERT INTO ticketing_fulfillment.inbox_event (event_id, event_type)
VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'UserRegistered');

-- Second insert with same event_id should fail
\set EXPECT_ERROR unique_violation
INSERT INTO ticketing_fulfillment.inbox_event (event_id, event_type)
VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'UserEmailChanged');
\unset EXPECT_ERROR

SELECT 'PASS: unique event_id constraint works' AS result;