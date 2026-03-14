-- Day 3: QA overlaps between field polygons

WITH field_pairs AS (
    SELECT
        a.field_id AS field_id_1,
        b.field_id AS field_id_2,
        a.geom AS geom_1,
        b.geom AS geom_2
    FROM dim_fields AS a
    JOIN dim_fields AS b
      ON a.field_id < b.field_id
),
overlap_calc AS (
    SELECT
        field_id_1,
        field_id_2,
        ST_Area(
            ST_Transform(
                ST_Intersection(geom_1, geom_2),
                2157
            )
        ) AS overlap_m2
    FROM field_pairs
    WHERE ST_Intersects(geom_1, geom_2)
),
real_overlaps AS (
    SELECT *
    FROM overlap_calc
    WHERE overlap_m2 > 0
),
affected_fields AS (
    SELECT field_id_1 AS field_id FROM real_overlaps
    UNION
    SELECT field_id_2 AS field_id FROM real_overlaps
)
SELECT
    (SELECT COUNT(*) FROM real_overlaps) AS overlapping_pairs,
    (SELECT COUNT(*) FROM affected_fields) AS affected_fields,
    (SELECT ROUND(MAX(overlap_m2)::numeric, 6) FROM real_overlaps) AS max_overlap_m2;