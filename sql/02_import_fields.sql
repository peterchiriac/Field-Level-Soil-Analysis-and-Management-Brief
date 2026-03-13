-- Day 2: Import LPIS sample from staging into dim_fields (canonical)

-- Promote a sample from staging into dim_fields.
-- Source CRS: EPSG:2157 (ITM). Staging import reprojected to EPSG:4326.

INSERT INTO dim_fields (field_id, farm_name, field_name, crop, geom)
SELECT
  PAR_LAB::text                      AS field_id,
  APP_HERD::text                     AS farm_name,
  PAR_LAB::text                      AS field_name,
  CROP::text                         AS crop,
  geom::geometry(Polygon, 4326)      AS geom
FROM stg_lpis_2023_parcels_raw
WHERE PAR_LAB IS NOT NULL
ON CONFLICT (field_id) DO NOTHING;

-- QA: validity and area (ha)
-- Validity summary
SELECT
  COUNT(*) AS n_fields,
  SUM(CASE WHEN ST_IsValid(geom) THEN 0 ELSE 1 END) AS n_invalid
FROM dim_fields;

-- Invalid examples (if any)
SELECT
  field_id,
  ST_IsValid(geom) AS is_valid,
  ST_IsValidReason(geom) AS reason
FROM dim_fields
WHERE NOT ST_IsValid(geom)
LIMIT 25;

-- Area in hectares (top 20)
SELECT
  field_id,
  ROUND((ST_Area(ST_Transform(geom, 3857)) / 10000.0)::numeric, 2) AS area_ha
FROM dim_fields
ORDER BY area_ha DESC
LIMIT 20;
