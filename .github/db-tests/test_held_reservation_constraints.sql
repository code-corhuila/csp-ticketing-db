-- Test: held_reservation constraints (HU-TICKETING-005)
-- Expected: a valid row inserts; a repeated reservation_id and a seat_labels that is not an array are rejected;
-- resolved_at and warned_at start null and can be set by UPDATE

\set ON_ERROR_STOP on

BEGIN;

INSERT INTO ticketing_fulfillment.held_reservation (reservation_id, user_id, showtime_id, seat_labels, expires_at)
VALUES ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        '["A1","A2"]', NOW() + INTERVAL '10 minutes');

DO $$
DECLARE
  v_resolved TIMESTAMPTZ;
  v_warned   TIMESTAMPTZ;
BEGIN
  SELECT resolved_at, warned_at INTO v_resolved, v_warned
  FROM ticketing_fulfillment.held_reservation WHERE reservation_id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
  IF v_resolved IS NOT NULL OR v_warned IS NOT NULL THEN
    RAISE EXCEPTION 'FAIL: resolved_at and warned_at must start null';
  END IF;

  UPDATE ticketing_fulfillment.held_reservation SET warned_at = NOW()
  WHERE reservation_id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
  UPDATE ticketing_fulfillment.held_reservation SET resolved_at = NOW()
  WHERE reservation_id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
  SELECT resolved_at, warned_at INTO v_resolved, v_warned
  FROM ticketing_fulfillment.held_reservation WHERE reservation_id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
  IF v_resolved IS NULL OR v_warned IS NULL THEN
    RAISE EXCEPTION 'FAIL: resolved_at and warned_at were not set by UPDATE';
  END IF;

  BEGIN
    INSERT INTO ticketing_fulfillment.held_reservation (reservation_id, user_id, showtime_id, seat_labels, expires_at)
    VALUES ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'cccccccc-cccc-cccc-cccc-cccccccccccc',
            '["B1"]', NOW() + INTERVAL '10 minutes');
    RAISE EXCEPTION 'FAIL: repeated reservation_id accepted';
  EXCEPTION WHEN unique_violation THEN
    NULL;
  END;
  BEGIN
    INSERT INTO ticketing_fulfillment.held_reservation (reservation_id, user_id, showtime_id, seat_labels, expires_at)
    VALUES ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'cccccccc-cccc-cccc-cccc-cccccccccccc',
            '{"seat":"A1"}', NOW() + INTERVAL '10 minutes');
    RAISE EXCEPTION 'FAIL: object seat_labels accepted';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;
  BEGIN
    INSERT INTO ticketing_fulfillment.held_reservation (reservation_id, user_id, showtime_id, seat_labels, expires_at)
    VALUES ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'cccccccc-cccc-cccc-cccc-cccccccccccc',
            '"A1"', NOW() + INTERVAL '10 minutes');
    RAISE EXCEPTION 'FAIL: string seat_labels accepted';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;
END $$;

SELECT 'PASS: held_reservation constraints work' AS result;

ROLLBACK;
