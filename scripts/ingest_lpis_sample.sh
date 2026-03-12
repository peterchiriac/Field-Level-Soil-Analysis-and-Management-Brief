#!/usr/bin/env bash
set -euo pipefail
ogr2ogr \
  -f "PostgreSQL" "PG:host=127.0.0.1 port=5433 dbname=field_brief user=$USER" \
  "../2023-lpis-parcels/GEOSERVICESHELP-213-PARCELS-ANON.shp" \
  -nln stg_lpis_2023_parcels_raw \
  -lco GEOMETRY_NAME=geom \
  -lco FID=gid \
  -nlt POLYGON \
  -s_srs EPSG:2157 \
  -t_srs EPSG:4326 \
  -limit 5000 \
  -overwrite
