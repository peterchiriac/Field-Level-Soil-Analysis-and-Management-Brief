# Key Findings

This page summarises the main QA results and field-level screening outputs from the project.

## 1. Boundary QA
- Invalid geometries in `dim_fields`: 0
- Overlap QA identified 11 intersecting field pairs involving 16 fields
- Maximum overlap area was only 0.000075 m², indicating negligible slivers rather than material overlaps
- Area-outlier QA identified 50 low-area and 50 high-area outliers using 1st and 99th percentile thresholds

## 2. Soil Screening Outputs
- Field-level soil summaries were successfully generated for pH, SOC, clay, and sand across the covered subset
- The analysed subset contained fields in `low` and `ok` pH bands, with no `high` pH cases observed in the mapped output
- A low-SOC screening flag was generated across the covered subset
- A simple texture note was derived from clay and sand values to support field-level comparison

## 3. Limitations
- SoilGrids is modelled gridded soil data rather than direct field sampling
- Only the 0–5 cm depth interval was used for v1
- Part of south-west Ireland returned `NoData` across all four SoilGrids variables
- Because full-layer WCS processing was too slow, the soil workflow used a covered working subset rather than the full LPIS extent

Overall, the project produced a modest but defensible field-level screening output, combining spatial QA, SoilGrids-based summaries, and simple interpretation fields.
