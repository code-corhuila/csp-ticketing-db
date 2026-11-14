-- V013: Grant the outbox reader role to the login of csp-worker
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-002, ADR-057, ADR-014
-- The ticketing outbox relay of csp-worker connects as worker_app, which csp-infra-postgres creates when the instance starts,
-- before any migration runs. Only a member of ticketing_outbox_reader (created in V007) can read the outbox, so without this
-- grant the relay fails with "permission denied for schema ticketing_fulfillment" and no TicketIssued event is published.
-- worker_app receives this role and no other: it is not a member of ticketing_writer or ticketing_reader (ADR-014).
-- Where the login does not exist yet (a bare database) nothing is granted.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'worker_app') THEN
    GRANT ticketing_outbox_reader TO worker_app;
  END IF;
END
$$;
