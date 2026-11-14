-- U001: Rollback V001 — Drop ticketing_fulfillment schema and roles
-- WARNING: Destructive. Run only in controlled recovery (ADR-017).
-- Order: reverse of V001

-- 1. Drop schema and all objects (cascades to tables, sequences, flyway_schema_history)
DROP SCHEMA IF EXISTS ticketing_fulfillment CASCADE;

-- 2. Drop roles (only if no other objects depend on them)
DROP ROLE IF EXISTS ticketing_writer;
DROP ROLE IF EXISTS ticketing_reader;