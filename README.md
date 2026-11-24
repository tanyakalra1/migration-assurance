# Migration Assurance Platform

A live ERP-to-Postgres migration with continuous reconciliation and cutover checks.

Source: MariaDB (ERP-style schema, synthetic data) → Debezium → Kafka → Postgres target.
The point is not just moving data. It is proving, all the time, that source and target agree — and catching it fast when they do not.

## What it does

- Captures every insert, update, and delete from MariaDB with Debezium CDC (binlog, ROW format).
- Streams changes through Apache Kafka 4.3 (KRaft, single node).
- Writes them to Postgres with a Debezium JDBC sink (upsert, deletes enabled).
- Checks, on demand: row counts, total sales, total debit vs total credit, and total stock change — in MariaDB and in Postgres.

## Architecture
MariaDB (erp) --binlog--> Debezium Connect --> Kafka 4.3 --> JDBC Sink --> Postgres (migration_target)
customers, items, warehouses, erp.erp.* topics same 7 tables
sales_orders, sales_order_lines,
stock_ledger, gl_entries 
## Measured results (2026-11-25, MacBook Air M1, 8 GB RAM)

- Snapshot: 5 customers, 5 items, 3 warehouses replicated to Postgres. Counts matched.
- Live test: a new customer added in MariaDB appeared in Postgres. Count went 5 → 6.
- Workload: 10 synthetic orders generated in Python.
  - MariaDB: 10 orders, 10 lines, 10 stock moves, 20 GL entries
  - Postgres: 10 orders, 10 lines, 10 stock moves, 20 GL entries
  - Counts matched.
- Reconciliation totals, both databases:
  - Total sales: 28902.25
  - Total debit = total credit: 28902.25 = 28902.25
  - Total stock change: -22
- Fault injection: one order-line amount was changed in Postgres only (+200).
  - The sum check caught it at once: MariaDB 28902.25 vs Postgres 29102.25.
  - Updating the source row re-emitted the correct value through CDC and restored the match.

## Stack

MariaDB 11.4, Apache Kafka 4.3.0, Debezium Connect 3.6.4, Postgres 16, Docker Compose, Python workload generator, GitHub Actions (planned).

## How to run

1. Copy `infra/.env.example` to `infra/.env` and fill in the passwords.
2. `cd infra && docker compose up -d`
3. Create the source schema: `sql/01_schema.sql` in MariaDB.
4. Register the source connector: `connect/mariadb-source.json` via `http://localhost:8083/connectors`.
5. Create the target tables: `postgres/01_target_schema.sql` in Postgres.
6. Register the sink: `connect/postgres-sink.json` (v2, with `collection.name.format: ${source.table}`).
7. Run the workload: `python3 ingestion/workload.py --count 10 --interval 3`.

See `docs/` and `adr/` for decisions and runbook (in progress).

## Honest limits

- Data is synthetic, not a real company system. No client data was used.
- Runs on one 8 GB laptop. Throughput numbers are modest and hardware-bound.
- Postgres is Phase 1. Phase 2 ports the same Bronze/Silver logic and dbt reconciliation models to Databricks Free Edition.

## Decisions

- Postgres first, then Databricks — see `adr/` (in progress).
- Debezium as the capture layer because it is open source and exposes raw CDC mechanics. The assurance layer is tool-agnostic and would sit on top of AWS DMS or Fivetran too.
