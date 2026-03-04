# QA — Day 1 (2026-03-02)

## What ran
- PostGIS enabled
- Table created: `dim_fields`
- Demo field inserted: `F001`
- Checks: validity + area (m² and ha)

## Results (F001)
- Validity: `ST_IsValid = true` (“Valid Geometry”)
- Area:
  - `area_m2 = 11946465.24`
  - `area_ha = 1194.65`

## Notes
- Geometry stored in EPSG:4326 (`geometry(Polygon, 4326)`).
- Area computed by transforming to EPSG:3857 for metres, then converting to hectares.
