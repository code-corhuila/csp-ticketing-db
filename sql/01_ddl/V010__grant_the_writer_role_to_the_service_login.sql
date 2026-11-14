-- V010: Grant the writer role to the login of the service
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: ADR-017, csp-infra-postgres#41
-- The login of the service (ticketing_app) is created by csp-infra-postgres when the instance starts, before any migration
-- runs, and only a member of ticketing_writer can read and write the tables. The migration executor created the role in V001,
-- so it may grant it. Where the login does not exist yet (a bare database, the CI of this repository) nothing is granted.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ticketing_app') THEN
    GRANT ticketing_writer TO ticketing_app;
  END IF;
END
$$;
