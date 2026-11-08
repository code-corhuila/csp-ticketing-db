-- U013: Rollback V013 — Revoke the outbox reader role from the login of csp-worker
-- WARNING: the ticketing outbox relay cannot read the outbox afterwards. Run only in controlled recovery (ADR-057).

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'worker_app') THEN
    REVOKE ticketing_outbox_reader FROM worker_app;
  END IF;
END
$$;
