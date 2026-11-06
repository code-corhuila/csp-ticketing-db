-- U010: Rollback V010 — Revoke the writer role from the login of the service
-- WARNING: the service cannot read or write its tables afterwards. Run only in controlled recovery (ADR-017).

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ticketing_app') THEN
    REVOKE ticketing_writer FROM ticketing_app;
  END IF;
END
$$;
