-- Test: the login of csp-worker reads the outbox and nothing else (HU-TICKETING-002, ADR-057, ADR-014)
-- Expected: worker_app is a member of ticketing_outbox_reader only; it can SELECT outbox_event and cannot write it
-- Needs the worker_app login, which csp-infra-postgres creates before the migrations (the workflow creates it too).

\set ON_ERROR_STOP on

DO $$
BEGIN
  IF NOT pg_has_role('worker_app', 'ticketing_outbox_reader', 'MEMBER') THEN
    RAISE EXCEPTION 'FAIL: worker_app is not a member of ticketing_outbox_reader';
  END IF;
  IF pg_has_role('worker_app', 'ticketing_writer', 'MEMBER') THEN
    RAISE EXCEPTION 'FAIL: worker_app is a member of ticketing_writer';
  END IF;
  IF pg_has_role('worker_app', 'ticketing_reader', 'MEMBER') THEN
    RAISE EXCEPTION 'FAIL: worker_app is a member of ticketing_reader';
  END IF;
END $$;

SET ROLE worker_app;

SELECT count(*) AS outbox_rows_visible FROM ticketing_fulfillment.outbox_event;

DO $$
BEGIN
  BEGIN
    INSERT INTO ticketing_fulfillment.outbox_event (aggregate_type, aggregate_id, event_type, payload)
    VALUES ('Ticket', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'TicketIssued', '{}');
    RAISE EXCEPTION 'FAIL: worker_app inserted into outbox_event';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  BEGIN
    UPDATE ticketing_fulfillment.outbox_event SET event_type = 'x';
    RAISE EXCEPTION 'FAIL: worker_app updated outbox_event';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  BEGIN
    DELETE FROM ticketing_fulfillment.outbox_event;
    RAISE EXCEPTION 'FAIL: worker_app deleted from outbox_event';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  BEGIN
    PERFORM 1 FROM ticketing_fulfillment.tickets;
    RAISE EXCEPTION 'FAIL: worker_app read tickets';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END $$;

RESET ROLE;

SELECT 'PASS: worker_app reads the outbox only through ticketing_outbox_reader' AS result;
