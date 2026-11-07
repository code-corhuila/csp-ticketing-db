-- Test: unique user_id constraint on user_contact
-- Expected: INSERT with duplicate user_id fails

\set ON_ERROR_STOP on

-- First insert
INSERT INTO ticketing_fulfillment.user_contact (user_id, email)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'test@example.com');

-- Second insert with same user_id should fail
\set EXPECT_ERROR unique_violation
INSERT INTO ticketing_fulfillment.user_contact (user_id, email)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'other@example.com');
\unset EXPECT_ERROR

SELECT 'PASS: unique user_id constraint works' AS result;