-- Day 4: QA area outliers for field polygons


WITH field_areas AS (
	SELECT
		field_id,
		ST_Area(ST_Transform(geom, 2157)) / 10000.0 AS area_ha
	FROM dim_fields
),
percentiles AS (
	SELECT 
		percentile_cont(0.01) WITHIN GROUP (ORDER BY area_ha) AS p01_area_ha,
		percentile_cont(0.50) WITHIN GROUP (ORDER BY area_ha) AS median_area_ha,
		percentile_cont(0.99) WITHIN GROUP (ORDER BY area_ha) AS p99_area_ha
	FROM field_areas
),
flagged_fields AS (
	SELECT
		f.field_id,
		ROUND(f.area_ha::NUMERIC, 4) AS area_ha,
		CASE
			WHEN f.area_ha < p.p01_area_ha THEN 'low_outlier'
			WHEN f.area_ha > p.p99_area_ha THEN 'high_outlier'
			ELSE 'ok'
		END AS area_flag
	FROM field_areas AS f
	CROSS JOIN percentiles AS p
)

SELECT
	(SELECT ROUND(MIN(area_ha)::NUMERIC, 4) FROM field_areas) AS min_area_ha,
	(SELECT ROUND(MAX(area_ha)::NUMERIC, 4) FROM field_areas) AS max_area_ha,
	(SELECT ROUND (median_area_ha::NUMERIC, 4) FROM percentiles) AS median_area_ha,
	(SELECT ROUND(p01_area_ha::NUMERIC, 4) FROM percentiles) AS p01_area_ha,
	(SELECT ROUND(p99_area_ha:: NUMERIC, 4) FROM percentiles) AS p99_area_ha,
	(SELECT COUNT(*) FROM flagged_fields WHERE area_flag = 'low_outlier') AS low_outlier,
	(SELECT COUNT(*) FROM flagged_fields WHERE area_flag = 'high_outlier') AS high_outlier
		