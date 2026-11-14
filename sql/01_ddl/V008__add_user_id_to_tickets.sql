-- V008: Store the owner of a ticket by user_id so a ticket can exist before its contact (HU-TICKETING-002)
-- Owner: csp-ticketing-db | Engine: PostgreSQL 16 | Tool: Flyway
-- Related: HU-TICKETING-002, ADR-057 (decision 1)
-- The contact is resolved by user_id when the email is dispatched; user_contact_id is no
-- longer required at creation.

ALTER TABLE ticketing_fulfillment.tickets ADD COLUMN user_id UUID;

UPDATE ticketing_fulfillment.tickets t
   SET user_id = c.user_id
  FROM ticketing_fulfillment.user_contact c
 WHERE c.id = t.user_contact_id;

ALTER TABLE ticketing_fulfillment.tickets ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE ticketing_fulfillment.tickets ALTER COLUMN user_contact_id DROP NOT NULL;

-- "My tickets" queries are by user_id.
CREATE INDEX idx_tickets_user_id ON ticketing_fulfillment.tickets (user_id);
