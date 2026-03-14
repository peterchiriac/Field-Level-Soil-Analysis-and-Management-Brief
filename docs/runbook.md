# Runbook

## 1) Defaults (single source of truth)
- Canonical Postgres: 17 (Homebrew)
- Host: 127.0.0.1
- Port: 5433
- Database: field_brief
- Canonical binaries: `/opt/homebrew/opt/postgresql@17/bin/...`

Reason (short): PostGIS control files must match the Postgres major version. Mine lined up for 17, not 16.

## 2) Canonical commands (copy/paste)

### 2.0) Sanity check (run first, every session)
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

## 2.8 Session 2 — Inspect LPIS Shapefile schema/CRS

```bash
ogrinfo -so ../2023-lpis-parcels/GEOSERVICESHELP-213-PARCELS-ANON.shp GEOSERVICESHELP-213-PARCELS-ANON
```
Purpose:
    •    Confirm geometry type
    •    Confirm source CRS
    •    Inspect source columns before ingest

2.9 Session 2 — Import LPIS sample into staging with reprojection

```bash
ogr2ogr \
  -f PostgreSQL PG:"host=127.0.0.1 port=5433 dbname=field_brief user=peter" \
  ../2023-lpis-parcels/GEOSERVICESHELP-213-PARCELS-ANON.shp \
  -nln stg_lpis_2023_parcels_raw \
  -lco GEOMETRY_NAME=geom \
  -t_srs EPSG:4326 \
  -overwrite
  ```
  
  Purpose:
    •    Load LPIS source data into staging
    •    Reproject from source CRS to canonical storage CRS on ingest
    
2.10 Session 2 — Run canonical import SQL
```bash
/opt/homebrew/opt/postgresql@17/bin/psql -p 5433 -d field_brief -f sql/02_import_fields.sql
```

2.11 Session 2 — QA artefact

Output file:
    •    docs/qa_day2.txt

This file captures:
    •    staging/schema checks
    •    distinct/null checks on PAR_LAB
    •    canonical row counts
    •    geometry validity checks
    •    area sanity outputs


## 3) Known failure modes (one-line diagnosis)
	•	Address already in use / could not bind 5432 → Something else is on that port. Use 5433.
	•	postgis.control not found → PostGIS files don’t exist for that Postgres major version.
	•	password authentication failed → You’re connecting to a different server/user than you think. Confirm with SELECT version();.
 
 CRS notes
    •    Source LPIS CRS: EPSG:2157
    •    Canonical storage CRS: EPSG:4326
    •    For defensible area calculations, use an appropriate projected CRS rather than EPSG:4326   

## 4) Project Boilerplate

	•	Folders: sql/, ingest/, data/, docs/, scripts/
	•	SQL naming: 01_day1_setup.sql, 02_import_fields.sql, etc.
	•	QA outputs: docs/qa_dayN.txt (machine output) + optional docs/qa_dayN.md (short summary)
 
     Session 2 ingest caveat
     
    •    PAR_LAB was not null in the sample
    •    PAR_LAB was not unique in staging
    •    Therefore staging required a uniqueness check before promotion into dim_fields   

Two tiny notes:

1. If your `ogrinfo` layer name is not exactly `GEOSERVICESHELP-213-PARCELS-ANON`, run:

```bash
ogrinfo ../2023-lpis-parcels/GEOSERVICESHELP-213-PARCELS-ANON.shp
```
2.    If your PostgreSQL username is not peter, replace it with your actual user, or use:

```bash
user=$USER
```

## 5) Mental model reminders
	•	Two Postgres servers may exist; only one process can own a given port at a time.
	•	PostGIS must match the Postgres major version, hence 17 + PostGIS worked cleanly.

LPIS (Ireland) dataset pointers
	•	Host: 127.0.0.1
	•	Port: 5433
	•	DB: field_brief
	•	User: peter (or $USER)
	•	Shapefile: ../2023-lpis-parcels/GEOSERVICESHELP-213-PARCELS-ANON.shp


