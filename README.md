# csp-ticketing-db

> ticketing bounded context: database (schema, seeds, migrations)

Part of the **Cinesync Platform** distributed system — team `cinesync-platform`, Group 1.
Governance and documentation live in [`csp-docs`](https://github.com/code-corhuila/csp-docs).

## Run the migrations

`deploy/compose.yml` defines the migration executor (`ticketing-db-migrate`, Flyway, profile `tooling`). It has no database
service and no volume: the single PostgreSQL instance of the environment belongs to `csp-infra-postgres` (Annex J), which
includes this file and joins the `platform` network. The executor reads `sql/01_ddl` and connects as the owner of the
schema, never as the instance administrator.

```bash
docker compose --profile tooling run --rm ticketing-db-migrate
```

Variables, passed from the platform environment (never written in a file of this repository):

| Variable | Meaning |
|---|---|
| `PG_DATABASE` | Database of the instance |
| `TICKETING_DB_USER` | Login of the executor, `ticketing_migrator` |
| `TICKETING_DB_PASSWORD` | Its password |
| `FLYWAY_CONNECT_RETRIES` | Connection attempts while the instance starts (60 by default) |

## Branching

Three permanent branches. **None of them accepts a direct commit** — you enter through a child
branch and leave through a Pull Request.

```
develop  <--PR--  feat/... fix/... chore/...
qa       <--PR--  qa/...
main     <--PR--  release/...  hotfix/...
```

Promotion happens **by re-application** (`git cherry-pick -x`), never by merging one permanent
branch into another: `merge develop -> qa` and `merge qa -> main` do not exist in this model.

`main` requires **1 approval from `ariel5253`**. On `develop` and `qa` the team sets its own review
rule.

Full policy: `00-governance/git-conventions.md` in `csp-docs`.
