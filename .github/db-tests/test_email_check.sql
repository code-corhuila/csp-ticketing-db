-- Test: email format check constraint on user_contact
-- Expected: INSERT with invalid email fails

\set ON_ERROR_STOP on

-- Valid email should succeed
INSERT INTO ticketing_fulfillment.user_contact (user_id, email)
VALUES ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'valid@example.com');

-- Invalid email (no @) should fail
\set EXPECT_ERROR check_violation
INSERT INTO ticketing_fulfillment.user_contact (user_id, email)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'invalid-email');
\unset EXPECT_ERROR

-- Invalid email (no domain) should fail
\set EXPECT_ERROR check_violation
INSERT INTO ticketing_fulfillment.user_contact (user_id, email)
VALUES ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'invalid@');
\unset EXPECT_ERROR

-- Invalid email (no TLD) should fail
\set EXPECT_ERROR check_violation
INSERT INTO ticketing_fulfillment.user_contact (user_id, email)
VALUES ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'invalid@domain');
\unset EXPECT_ERROR

-- Email too short should fail
\set EXPECT_ERROR check_violation
INSERT INTO ticketing_fulfillment.user_contact (user_id, email)
VALUES ('11111111-1111-1111-1111-111111111111', 'a@b');
\unset EXPECT_ERROR

SELECT 'PASS: email format check constraint works' AS result;