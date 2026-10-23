# Changelog — csp-ticketing-db

All notable changes to the `ticketing_fulfillment` schema.

## [Unreleased]

### Added
- V002: `user_contact` table for contact projection (HU-TICKETING-001)
- V003: `inbox_event` table for event idempotency (HU-TICKETING-001)

### Migration Details

#### V002__create_user_contact_table.sql
```sql
CREATE TABLE ticketing_fulfillment.user_contact (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL,
    email           TEXT        NOT NULL,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_user_contact PRIMARY KEY (id),
    CONSTRAINT uk_user_contact_user_id UNIQUE (user_id),
    CONSTRAINT chk_user_contact_email_length CHECK (char_length(email) BETWEEN 3 AND 255),
    CONSTRAINT chk_user_contact_email_format CHECK (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$')
);
CREATE INDEX idx_user_contact_user_id ON ticketing_fulfillment.user_contact (user_id);
```
**Grants:** `ticketing_writer` (SELECT, INSERT, UPDATE), `ticketing_reader` (SELECT)

#### V003__create_inbox_event_table.sql
```sql
CREATE TABLE ticketing_fulfillment.inbox_event (
    id           UUID        NOT NULL DEFAULT gen_random_uuid(),
    event_id     UUID        NOT NULL,
    event_type   TEXT        NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    error        TEXT,
    CONSTRAINT pk_inbox_event PRIMARY KEY (id),
    CONSTRAINT uk_inbox_event_event_id UNIQUE (event_id),
    CONSTRAINT chk_inbox_event_event_type_length CHECK (char_length(event_type) BETWEEN 1 AND 100)
);
CREATE INDEX idx_inbox_event_event_id ON ticketing_fulfillment.inbox_event (event_id);
```
**Grants:** `ticketing_writer` (SELECT, INSERT), `ticketing_reader` (SELECT)

### Rollback
- U003: `DROP TABLE ticketing_fulfillment.inbox_event`
- U002: `DROP TABLE ticketing_fulfillment.user_contact`

---

## [1.0.0] - 2026-10-23

### Added
- V001: `ticketing_fulfillment` schema, roles, Flyway control table
- Baseline migration structure per ADR-013/ADR-017