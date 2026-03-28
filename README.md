# Field Boundary QA + Soil Variability Brief

A hireable, audit-ready spatial analytics project that ingests real field boundaries, validates them, summarises soil properties at field level, and produces modest decision-support outputs.

## Project Objective

This project was built to demonstrate a practical agritech-style workflow:

- ingest real field-boundary data
- validate and quality-check the spatial layer
- add a real external soil source
- summarise soil properties at field level
- derive modest screening flags
- produce map-based and written outputs

The aim was not to build a full production agronomy platform, but to create a credible v1 that reflects real analytical work: structured ingest, QA, reproducibility, field-level summaries, and restrained interpretation.

## Core Deliverables

### 1. Field boundary quality report
- invalid geometries
- overlaps between fields
- missing / duplicated IDs
- area outliers

### 2. Soil summary per field
- SoilGrids-based field summaries for:
  - pH
  - SOC
  - clay
  - sand
- depth interval: 0–5 cm

### 3. Field screening flags
- pH band
- low SOC flag
- simple texture note

### 4. Outputs
- field-level mart-style output layer
- 2–3 exported QGIS maps
- `docs/findings.md`
- `docs/field_brief_sample.md`

## Data Sources

### Field boundaries
- Irish LPIS parcel sample
- source format: Shapefile
- source CRS: EPSG:2157
- ingested into PostGIS and reprojected to EPSG:4326 for canonical storage

### Soil layer
- SoilGrids rasters
- variables used:
  - pH
  - SOC
  - clay
  - sand
- depth used:
  - 0–5 cm

## Tech Stack

- PostgreSQL 17
- PostGIS
- QGIS
- GDAL / `ogrinfo` / `ogr2ogr`
- SQL
- Markdown documentation

## Workflow

### 1. Setup
- created project repo
- created `field_brief` database
- enabled PostGIS
- created `dim_fields`

### 2. Ingest
- imported Irish LPIS parcel sample into staging:
  - `stg_lpis_2023_parcels_raw`
- promoted unique parcel rows into:
  - `dim_fields`

### 3. Spatial QA
- geometry validity checks
- overlap checks
- area outlier checks

### 4. Soil workflow
- loaded SoilGrids rasters into QGIS
- identified usable overlap area
- confirmed `NoData` limitation in part of south-west Ireland
- generated field-level zonal statistics on a covered subset

### 5. Interpretation
- converted SoilGrids values into readable units
- created:
  - `ph_band`
  - `soc_flag`
  - `texture_note`

### 6. Outputs
- exported screening maps
- wrote findings summary
- wrote sample field brief

## Project Structure

```text
field-qa-soil-brief/
├── data/
│   ├── raw/
│   └── processed/
├── docs/
│   ├── findings.md
│   ├── field_brief_sample.md
│   ├── qa_day2.txt
│   ├── qa_day3_overlaps.txt
│   ├── qa_day4_area_outliers.txt
│   └── maps/
├── sql/
│   ├── 01_day1_setup.sql
│   ├── 02_import_fields.sql
│   ├── 03_qa_overlaps.sql
│   └── 04_qa_area_outliers.sql
└── runbook.md
```

## Key Findings

See `docs/findings.md` for the core findings summary.

### Highlights
- invalid geometries in `dim_fields`: 0
- overlap QA found 11 intersecting field pairs involving 16 fields
- maximum overlap area was only 0.000075 m², indicating negligible slivers rather than material overlaps
- area-outlier QA identified 50 low-area and 50 high-area outliers using 1st and 99th percentile thresholds
- SoilGrids field summaries were generated for pH, SOC, clay, and sand at 0–5 cm depth
- a sample field brief was produced using the enriched output layer

## Example Outputs
- thematic map: pH band
- thematic map: low SOC screening flag
- thematic map: simple texture note
- findings page: `docs/findings.md`￼
- sample field brief: `docs/field_brief_sample.md`￼

## QA Summary

### Geometry validity
- invalid geometries: 0

### Overlaps
- overlapping pairs: 11
- affected fields: 16
- maximum overlap: 0.000075 m²

### Area outliers
- min area: 0.0071 ha
- max area: 33.4782 ha
- median area: 2.2373 ha
- P01: 0.0562 ha
- P99: 14.8479 ha
- low outliers: 50
- high outliers: 50

## Soil Variable Conversions

For interpretation, SoilGrids values were converted into more readable units:
- `ph_val = ph_mean / 10`
- `soc_gkg = soc_mean / 10`
- `clay_pct = clay_mean / 10`
- `sand_pct = sand_mean / 10`

## Limitations
- SoilGrids is modelled gridded soil data rather than direct field sampling
- only the 0–5 cm depth interval was used for v1
- part of south-west Ireland returned `NoData` across all four SoilGrids variables
- because full-layer WCS processing was too slow, the soil workflow used a covered working subset rather than the full LPIS extent
- interpretation fields are screening-level outputs, not agronomic prescriptions

## Why This Project Matters

This project demonstrates the ability to take real spatial data from ingest and QA through to field-level summarisation, screening outputs, and clear communication of limitations.

It shows:
- raw → staging → canonical thinking
- spatial QA and auditability
- field-level summarisation
- restrained interpretation
- communication through maps and written outputs

In short, it shows how spatial data can be turned into a trustworthy field-level decision-support artefact.

## Next Possible Extensions
- formalise a `mart_field` table in Postgres
- extend beyond the covered subset
- add weather-based field context
- add NDVI / raster vegetation signals
- compare external soil surfaces with direct soil samples
