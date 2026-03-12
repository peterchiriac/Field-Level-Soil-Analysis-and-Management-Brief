# Runbook

## 1) Defaults (single source of truth)
- Canonical Postgres: 17 (Homebrew)
- Host: 127.0.0.1
- Port: 5433
- Database: field_brief
- Canonical binaries: `/opt/homebrew/opt/postgresql@17/bin/...`

Reason (short): PostGIS control files must match the Postgres major version. Mine lined up for 17, not 16.

## 2) Canonical commands (copy/paste)

### 2.0 Sanity check (run first, every session)
```bash
/opt/homebrew/opt/postgresql@17/bin/psql -p 5433 -d postgres -c "SELECT version();"
/opt/homebrew/opt/postgresql@17/bin/psql -p 5433 -d field_brief -c "SELECT PostGIS_Version();"

## 2.1 Start/stop/restart(Postgres 17)
/opt/homebrew/opt/postgresql@17/bin/pg_ctl -D /opt/homebrew/var/postgresql@17 -o "-p 5433" -l /opt/homebrew/var/postgresql@17/server.log start
/opt/homebrew/opt/postgresql@17/bin/pg_ctl -D /opt/homebrew/var/postgresql@17 stop -m fast
/opt/homebrew/opt/postgresql@17/bin/pg_ctl -D /opt/homebrew/var/postgresql@17 restart -m fast -o "-p 5433" -l /opt/homebrew/var/postgresql@17/server.log

## 2.2 Confirm what is listening on 5433

lsof -nP -iTCP:5433 | grep LISTEN

## 2.3 Create/drop databases (pointed at 5433)

/opt/homebrew/opt/postgresql@17/bin/createdb -p 5433 field_brief
/opt/homebrew/opt/postgresql@17/bin/dropdb -p 5433 field_brief

## 2.4 Connect (interactive psql shell)

/opt/homebrew/opt/postgresql@17/bin/psql -p 5433 -d field_brief

## 2.5 Run a SQL script file

/opt/homebrew/opt/postgresql@17/bin/psql -p 5433 -d field_brief -f sql/01_day1_setup.sql

## 2.6 Run one-off SQL statement

/opt/homebrew/opt/postgresql@17/bin/psql -p 5433 -d field_brief -c "SELECT NOW();"

## 2.7 Enable PostGIS (per database)

/opt/homebrew/opt/postgresql@17/bin/psql -p 5433 -d field_brief -c "CREATE EXTENSION IF NOT EXISTS postgis;"

## 3) Known failure modes (one-line diagnosis)
	•	Address already in use / could not bind 5432 → Something else is on that port. Use 5433.
	•	postgis.control not found → PostGIS files don’t exist for that Postgres major version.
	•	password authentication failed → You’re connecting to a diffrent server/user than you think. Confirm with SELECT version();.

## 4) Project Boilerplate

	•	Folders: sql/, ingest/, data/, docs/, scripts/
	•	SQL naming: 01_day1_setup.sql, 02_import_fields.sql, etc.
	•	QA outputs: docs/qa_dayN.txt (machine output) + optional docs/qa_dayN.md (short summary)

## 5) Mental model reminders
	•	Two Postgres servers may exist; only one process can own a given port at a time.
	•	PostGIS must match the Postgres major version, hence 17 + PostGIS worked cleanly.

LPIS (Ireland) dataset pointers
	•	Host: 127.0.0.1
	•	Port: 5433
	•	DB: field_brief
	•	User: peter (or $USER)
	•	Shapefile: ../2023-lpis-parcels/GEOSERVICESHELP-213-PARCELS-ANON.shp


