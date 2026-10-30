-- V001: Create ticketing_fulfillment schema, roles, and Flyway control table
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: ADR-017, ADR-013, ADR-006

-- 1. Schema
CREATE SCHEMA IF NOT EXISTS ticketing_fulfillment
  AUTHORIZATION postgres;

COMMENT ON SCHEMA ticketing_fulfillment IS
  'Ticketing & Fulfillment bounded context: contact projections, tickets, fulfillment jobs, inbox events.';

-- 2. Roles (NOLOGIN, per Norma 5.2 / ADR-013)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ticketing_reader') THEN
    CREATE ROLE ticketing_reader NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ticketing_writer') THEN
    CREATE ROLE ticketing_writer NOLOGIN;
  END IF;
END $$;

-- 3. Grants on schema
GRANT USAGE ON SCHEMA ticketing_fulfillment TO ticketing_reader, ticketing_writer;

-- Default privileges for future objects (owner = ticketing_writer via migration user)
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA ticketing_fulfillment
  GRANT SELECT ON TABLES TO ticketing_reader;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA ticketing_fulfillment
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ticketing_writer;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA ticketing_fulfillment
  GRANT USAGE, SELECT ON SEQUENCES TO ticketing_reader, ticketing_writer;

-- 4. Flyway control table (created automatically by Flyway on first migrate)
-- Explicit comment for documentation
COMMENT ON TABLE ticketing_fulfillment.flyway_schema_history IS
  'Flyway schema history table — managed by csp-ticketing-db migrations only.';

-- 5. Search path helper (documentation only; enforced by csp-infra-postgres via ALTER ROLE)
-- ALTER ROLE ticketing_app SET search_path = ticketing_fulfillment;