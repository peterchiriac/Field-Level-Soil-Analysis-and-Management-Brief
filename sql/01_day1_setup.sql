-- Day 1: PostGIS setup + first field boundary

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS dim_fields (
  field_id   TEXT PRIMARY KEY,
  farm_name  TEXT,
  field_name TEXT,
  crop       TEXT,
  geom       geometry(Polygon, 4326)
);

INSERT INTO dim_fields (field_id, farm_name, field_name, crop, geom)
VALUES (
  'F001',
  'Demo Farm',
  'North Field',
  'Wheat',
  ST_GeomFromText('POLYGON((-0.15 51.50, -0.15 51.52, -0.12 51.52, -0.12 51.50, -0.15 51.50))', 4326)
)
ON CONFLICT (field_id) DO NOTHING;

-- Checks
SELECT
  field_id,
  ST_IsValid(geom) AS is_valid,
  ST_IsValidReason(geom) AS validity_reason
FROM dim_fields
WHERE field_id = 'F001';

SELECT
  field_id,
  ROUND(ST_Area(ST_Transform(geom, 3857))::numeric, 2) AS area_m2,
  ROUND((ST_Area(ST_Transform(geom, 3857)) / 10000.0)::numeric, 2) AS area_ha
FROM dim_fields
WHERE field_id = 'F001';
