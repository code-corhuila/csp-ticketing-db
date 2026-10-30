# Changelog — csp-ticketing-db

All notable changes to the `ticketing_fulfillment` schema.

## [Unreleased]

### Fixed
- Removed the duplicate `V002__create_user_contacts_table.sql` and `U002__drop_user_contacts_table.sql` (plural, `VARCHAR`, no format check): two files with version 2 made Flyway fail validation. `V002__create_user_contact_table.sql` is the only V002 (HU-TICKETING-001)

### Added
- V002: `user_contact` table for contact projection (HU-TICKETING-001)
- V003: `inbox_event` table for event idempotency (HU-TICKETING-001)
- V004: `tickets` table for ticket issuance (HU-TICKETING-002)
- V005: `ticketing_fulfillments` table for email delivery jobs (HU-TICKETING-002)
- V007: `outbox_event` table and the `ticketing_outbox_reader` role for the transactional outbox (HU-TICKETING-002, ADR-057)
- V008: `tickets.user_id`, backfilled from `user_contact`; `user_contact_id` becomes nullable so a ticket can exist before its contact (HU-TICKETING-002, ADR-057)
- V009: `tickets.showtime_starts_at` becomes nullable, because Booking sends a null start until Catalog exists (HU-TICKETING-002, ADR-057)

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

#### V004__create_tickets_table.sql
```sql
CREATE TABLE ticketing_fulfillment.tickets (
    id                       UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_contact_id          UUID        NOT NULL,
    reservation_id           UUID        NOT NULL,
    showtime_id              UUID        NOT NULL,
    movie_title_snapshot     VARCHAR(255) NOT NULL,
    room_name_snapshot       VARCHAR(160) NOT NULL,
    showtime_starts_at       TIMESTAMPTZ NOT NULL,
    seat_labels_snapshot     JSONB       NOT NULL,
    concessions_snapshot     JSONB,
    qr_payload               TEXT        NOT NULL,
    pdf_url                  VARCHAR(500),
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_tickets PRIMARY KEY (id),
    CONSTRAINT uk_tickets_reservation_id UNIQUE (reservation_id),
    CONSTRAINT chk_tickets_qr_payload_length CHECK (char_length(qr_payload) BETWEEN 1 AND 500)
);
CREATE INDEX idx_tickets_user_contact_id ON ticketing_fulfillment.tickets (user_contact_id);
CREATE INDEX idx_tickets_showtime_id ON ticketing_fulfillment.tickets (showtime_id);
```
**Grants:** `ticketing_writer` (SELECT, INSERT, UPDATE), `ticketing_reader` (SELECT)

#### V005__create_ticketing_fulfillments_table.sql
```sql
CREATE TABLE ticketing_fulfillment.ticketing_fulfillments (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    ticket_id       UUID        NOT NULL,
    channel         VARCHAR(50) NOT NULL DEFAULT 'EMAIL',
    status          VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    attempts        INT         NOT NULL DEFAULT 0,
    last_error      TEXT,
    next_retry_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_ticketing_fulfillments PRIMARY KEY (id),
    CONSTRAINT fk_ticketing_fulfillments_ticket FOREIGN KEY (ticket_id) REFERENCES ticketing_fulfillment.tickets (id) ON DELETE CASCADE,
    CONSTRAINT chk_ticketing_fulfillments_status CHECK (status IN ('PENDING', 'SENT', 'FAILED')),
    CONSTRAINT chk_ticketing_fulfillments_channel CHECK (channel IN ('EMAIL'))
);
CREATE INDEX idx_ticketing_fulfillments_status_next_retry ON ticketing_fulfillment.ticketing_fulfillments (status, next_retry_at) WHERE status = 'PENDING';
CREATE INDEX idx_ticketing_fulfillments_ticket_id ON ticketing_fulfillment.ticketing_fulfillments (ticket_id);
```
**Grants:** `ticketing_writer` (SELECT, INSERT, UPDATE), `ticketing_reader` (SELECT)

### Rollback
- U009: `SET NOT NULL` on `tickets.showtime_starts_at` (fails while a null exists)
- U008: drop `tickets.user_id` and its index; `SET NOT NULL` on `user_contact_id` (fails while a ticket has no contact)
- U007: drop `ticketing_fulfillment.outbox_event` (the role `ticketing_outbox_reader` stays)
- U005: `DROP TABLE ticketing_fulfillment.ticketing_fulfillments`
- U004: `DROP TABLE ticketing_fulfillment.tickets`
- U003: `DROP TABLE ticketing_fulfillment.inbox_event`
- U002: `DROP TABLE ticketing_fulfillment.user_contact`

---

## [1.0.0] - 2026-10-23

### Added
- V001: `ticketing_fulfillment` schema, roles, Flyway control table
- Baseline migration structure per ADR-013/ADR-017