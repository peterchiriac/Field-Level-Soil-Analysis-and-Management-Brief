# Farm Alpha — Soil Analysis & Management Recommendations  

## Executive Summary

This project implements a field-level agritech workflow that transforms spatial and soil data into management recommendations using spatial QA, field-level aggregation, and decision mapping.

Farm Alpha was defined from a subset of Irish LPIS parcels and used as the analysis unit for integrating SoilGrids data into field-level outputs.

![Recommended Action Map](docs/maps/farm_alpha_recommended_action.png)

## Key Results

* Soil pH is consistently low across the farm → whole-farm liming required
* Soil organic carbon (SOC) is moderate to high → generally good soil condition
* Clay-influenced parcels require additional structural caution

These findings were consolidated into a Recommended Action Map identifying where intervention is required and where standard management is sufficient.

---

## Project Objective

This project implements an end-to-end agritech workflow that transforms raw spatial and soil data into field-level management recommendations.

raw spatial data → validated dataset → field-level summaries → interpretable outputs → actionable recommendations

The workflow prioritises data trustworthiness, clear interpretation, and decision-oriented outputs over model complexity.

## Use Case

This workflow supports early-stage field assessment by identifying farm-wide constraints (e.g. acidity) and field-level operational risks (e.g. clay structure), enabling prioritised intervention planning.

---

## Key Outputs

### Farm Alpha Overview

Defines the analysis unit used for field-level soil assessment within a subset of Irish LPIS parcels.

---

### Soil pH Status

Field-level pH classification showing consistently acidic conditions across most parcels.

Interpretation: acidity is a farm-wide constraint requiring broad liming intervention rather than isolated treatment.

---

### Soil Organic Carbon (SOC) Status

Field-level SOC classification (g/kg) derived from SoilGrids aggregation.

Interpretation: SOC levels are moderate to high across the farm and are not currently a primary management constraint.

---

### Recommended Action Map

Primary decision-support output combining pH status and texture signals into field-level recommendations.

Decision categories:

* **Lime + Monitor Structure** → low pH + clay-influenced fields
* **Lime (Standard)** → low pH + normal structure
* **Monitor** → near-threshold pH

The resulting map identifies where intervention is required and where standard management is sufficient.

---

## Key Findings

* Soil pH is consistently low across the farm, indicating a need for liming at scale
* SOC levels are moderate to high, suggesting generally good organic matter status
* Spatial variation in SOC exists but is not a primary constraint
* Clay-influenced parcels present additional operational risk (drainage, compaction)

---

## Recommended Actions

* Apply lime across all fields to address acidity
* Prioritise structural caution and monitoring on clay-influenced parcels
* Maintain current practices supporting SOC levels

---

## Data Sources

Field Boundaries

* Irish LPIS parcel sample
* Source CRS: EPSG:2157
* Stored in PostGIS as EPSG:4326 (canonical)

Soil Data

* SoilGrids raster layers
* Variables:
    * pH
    * SOC
    * clay
    * sand
* Depth:
    * 0–5 cm

---

## Method Overview

### Data Ingest

* LPIS parcel data loaded into PostGIS
* Canonical `dim_fields` table established in EPSG:4326

---

### Spatial QA

* Geometry validity checks
* Overlap detection
* Area outlier analysis

---

### Soil Integration

* SoilGrids raster layers processed in QGIS
* Zonal statistics applied to field polygons

---

### Field-Level Interpretation

* Soil variables converted into interpretable field-level indicators
* Classification layers derived for:
    * `pH_band`
    * `SOC_band`
    * `texture_note`

---

### Decision Layer

* Soil indicators synthesised into a `recommended_action` layer for operational decision support

---

## Technical Implementation

* PostgreSQL 17
* PostGIS
* QGIS
* GDAL (ogr2ogr, ogrinfo)
* SQL
* Markdown documentation

Full workflow and SQL scripts are available in:

* sql/
* runbook.md
* docs/qa_*

---

## QA Summary

Spatial QA checks were performed prior to soil aggregation to ensure field-level outputs were technically reliable and operationally interpretable.

Key QA results:

* Invalid geometries detected: **0**
* Overlapping field pairs identified: **11**
    * overlaps were negligible sliver artefacts rather than materially conflicting geometries
* Area outliers screened using **P01 / P99 threshold analysis**
* Soil summaries successfully generated across the covered analysis subset

---

## Limitations

* SoilGrids provides modelled estimates, not direct sampling
* Only 0–5 cm depth used for v1
* Partial NoData coverage in south-west Ireland
* Soil workflow applied to a subset, not full national coverage
* Outputs are screening-level, not full agronomic prescriptions

---

## Why This Project Matters

This project demonstrates the ability to:

* transform raw spatial data into trustworthy field-level outputs
* apply QA discipline to geospatial datasets
* summarise raster data into operational units (fields)
* produce clear, restrained interpretations
* deliver decision-support artefacts, not just analysis

In essence, it bridges:

data → insight → action

---

## Next Steps / Extensions

* Formalise a mart_field table in Postgres
* Extend soil coverage beyond current subset
* Integrate weather data (rainfall windows, temperature)
* Add NDVI / vegetation signals
* Compare SoilGrids outputs with real soil samples
