BEGIN;

-- Additive benchmark dataset for the current plan_queries.sql.
-- No existing data is deleted.
-- The script is designed specifically for these queries:
--
-- 48: athletes who skipped a required previous rank.
--     Creates a deeper PLAN_Q_RANK_* hierarchy and many Rank rows with both
--     complete and intentionally incomplete rank chains.
--
-- 45: top 3 athletes by height.
--     Creates many athletes and three clearly highest athletes so ORDER BY
--     height DESC LIMIT 3 and ROW_NUMBER() plans have enough rows to process.
--
-- 41: ranks assigned in 2024.
--     Creates many Rank rows across different years and a controlled subset
--     in 2024 so EXTRACT(YEAR FROM assignment_date) can be compared with a
--     date range predicate.

INSERT INTO Country (name)
VALUES ('PLAN_Q_COUNTRY')
ON CONFLICT (name) DO NOTHING;

INSERT INTO Region (name, country_id)
SELECT 'PLAN_Q_REGION', c.country_id
FROM Country c
WHERE c.name = 'PLAN_Q_COUNTRY'
ON CONFLICT (name, country_id) DO NOTHING;

INSERT INTO City (name, region_id)
SELECT 'PLAN_Q_CITY', r.region_id
FROM Region r
JOIN Country c ON c.country_id = r.country_id
WHERE r.name = 'PLAN_Q_REGION'
  AND c.name = 'PLAN_Q_COUNTRY'
ON CONFLICT (name, region_id) DO NOTHING;

DO $$
DECLARE
    prev_id INTEGER;
    cur_id INTEGER;
    i INTEGER;
BEGIN
    prev_id := NULL;

    FOR i IN 1..10 LOOP
        INSERT INTO Rank_title (rank_title, previous_rank_id)
        VALUES (format('PLAN_Q_RANK_%s', i), prev_id)
        ON CONFLICT (rank_title) DO NOTHING;

        SELECT rank_title_id INTO cur_id
        FROM Rank_title
        WHERE rank_title = format('PLAN_Q_RANK_%s', i);

        UPDATE Rank_title
        SET previous_rank_id = prev_id
        WHERE rank_title_id = cur_id;

        prev_id := cur_id;
    END LOOP;
END $$;

WITH bench_city AS (
    SELECT ci.city_id
    FROM City ci
    JOIN Region r ON r.region_id = ci.region_id
    JOIN Country c ON c.country_id = r.country_id
    WHERE ci.name = 'PLAN_Q_CITY'
      AND r.name = 'PLAN_Q_REGION'
      AND c.name = 'PLAN_Q_COUNTRY'
),
club_source AS (
    SELECT
        format('PQ_CLUB_%s', lpad(gs::text, 4, '0')) AS name,
        bc.city_id,
        DATE '1980-01-01' + ((gs % 9000) * INTERVAL '1 day') AS foundation_date
    FROM bench_city bc
    CROSS JOIN generate_series(1, 600) AS gs
)
INSERT INTO Club (name, city_id, foundation_date)
SELECT cs.name, cs.city_id, cs.foundation_date
FROM club_source cs
WHERE NOT EXISTS (
    SELECT 1
    FROM Club c
    WHERE c.name = cs.name
      AND c.city_id = cs.city_id
);

WITH bench_clubs AS (
    SELECT
        c.club_id,
        ROW_NUMBER() OVER (ORDER BY c.club_id) AS club_no
    FROM Club c
    JOIN City ci ON ci.city_id = c.city_id
    JOIN Region r ON r.region_id = ci.region_id
    JOIN Country co ON co.country_id = r.country_id
    WHERE c.name LIKE 'PQ_CLUB_%'
      AND ci.name = 'PLAN_Q_CITY'
      AND r.name = 'PLAN_Q_REGION'
      AND co.name = 'PLAN_Q_COUNTRY'
),
athlete_source AS (
    SELECT
        bc.club_id,
        bc.club_no,
        a_no,
        ((bc.club_no - 1) * 60 + a_no) AS athlete_seq
    FROM bench_clubs bc
    CROSS JOIN generate_series(1, 60) AS a_no
),
regular_athletes AS (
    SELECT
        src.club_id,
        format('PQ_Last_%s', src.athlete_seq) AS last_name,
        format('PQ_First_%s', src.a_no) AS first_name,
        NULL::VARCHAR(50) AS middle_name,
        CASE WHEN src.athlete_seq % 2 = 0 THEN 'male' ELSE 'female' END AS gender,
        DATE '1990-01-01' + ((src.athlete_seq % 9000) * INTERVAL '1 day') AS birth_date,
        '+7888' || lpad(src.athlete_seq::text, 7, '0') AS phone,
        CASE
            WHEN src.athlete_seq % 120 = 0 THEN 215
            ELSE 155 + (src.athlete_seq % 58)
        END AS height,
        50 + (src.athlete_seq % 45) AS weight
    FROM athlete_source src
),
top_athletes AS (
    SELECT
        bc.club_id,
        v.last_name,
        v.first_name,
        NULL::VARCHAR(50) AS middle_name,
        v.gender,
        v.birth_date,
        v.phone,
        v.height,
        v.weight
    FROM (
        VALUES
            (1, 'PQ_Top_One', 'Height', 'male', DATE '1998-01-01', '+78889999991', 245, 95),
            (2, 'PQ_Top_Two', 'Height', 'female', DATE '1999-01-01', '+78889999992', 242, 88),
            (3, 'PQ_Top_Three', 'Height', 'male', DATE '2000-01-01', '+78889999993', 239, 92)
    ) AS v(club_no, last_name, first_name, gender, birth_date, phone, height, weight)
    JOIN bench_clubs bc ON bc.club_no = v.club_no
),
all_athletes AS (
    SELECT *
    FROM regular_athletes

    UNION ALL

    SELECT *
    FROM top_athletes
)
INSERT INTO Athlete (
    club_id,
    last_name,
    first_name,
    middle_name,
    gender,
    birth_date,
    phone,
    height,
    weight
)
SELECT
    club_id,
    last_name,
    first_name,
    middle_name,
    gender,
    birth_date,
    phone,
    height,
    weight
FROM all_athletes
ON CONFLICT (phone) DO NOTHING;

WITH bench_athletes AS (
    SELECT
        a.athlete_id,
        ROW_NUMBER() OVER (ORDER BY a.athlete_id) AS athlete_no
    FROM Athlete a
    WHERE a.phone LIKE '+7888%'
),
rank_map AS (
    SELECT
        rt.rank_title_id,
        CAST(replace(rt.rank_title, 'PLAN_Q_RANK_', '') AS INTEGER) AS rank_no
    FROM Rank_title rt
    WHERE rt.rank_title LIKE 'PLAN_Q_RANK_%'
),
rank_source AS (
    SELECT
        ba.athlete_id,
        ba.athlete_no,
        rm.rank_title_id,
        rm.rank_no
    FROM bench_athletes ba
    CROSS JOIN rank_map rm
    WHERE
        -- Complete chains. These athletes should not be reported by query 48.
        (
            ba.athlete_no % 12 IN (0, 1, 2, 3)
            AND rm.rank_no <= 7
        )
        OR
        (
            ba.athlete_no % 12 = 4
            AND rm.rank_no <= 10
        )
        -- Skipped rank 3 before rank 4.
        OR
        (
            ba.athlete_no % 12 = 5
            AND rm.rank_no IN (1, 2, 4, 5, 6)
        )
        -- Skipped rank 2 before rank 3 and rank 4.
        OR
        (
            ba.athlete_no % 12 = 6
            AND rm.rank_no IN (1, 3, 4, 5)
        )
        -- Only high ranks, many missing previous ranks.
        OR
        (
            ba.athlete_no % 12 = 7
            AND rm.rank_no IN (6, 8, 10)
        )
        -- Sparse chain with several violations.
        OR
        (
            ba.athlete_no % 12 = 8
            AND rm.rank_no IN (2, 5, 9)
        )
        -- Mostly complete lower chain, skipped rank 6 before rank 7.
        OR
        (
            ba.athlete_no % 12 = 9
            AND rm.rank_no IN (1, 2, 3, 4, 5, 7)
        )
        -- Single non-root rank, definitely skipped previous rank.
        OR
        (
            ba.athlete_no % 12 IN (10, 11)
            AND rm.rank_no = 4
        )
),
dated_ranks AS (
    SELECT
        rs.athlete_id,
        rs.rank_title_id,
        CASE
            -- Around one sixth of inserted Rank rows are in 2024.
            WHEN (rs.athlete_no + rs.rank_no) % 6 = 0 THEN
                DATE '2024-01-01'
                + (((rs.athlete_no * 17) + rs.rank_no) % 366) * INTERVAL '1 day'
            WHEN rs.athlete_no % 3 = 0 THEN
                DATE '2018-01-01'
                + (((rs.athlete_no * 13) + rs.rank_no) % 1800) * INTERVAL '1 day'
            WHEN rs.athlete_no % 3 = 1 THEN
                DATE '2020-01-01'
                + (((rs.athlete_no * 19) + rs.rank_no) % 1200) * INTERVAL '1 day'
            ELSE
                DATE '2025-01-01'
                + (((rs.athlete_no * 23) + rs.rank_no) % 500) * INTERVAL '1 day'
        END AS assignment_date
    FROM rank_source rs
)
INSERT INTO Rank (athlete_id, assignment_date, rank_title_id)
SELECT
    athlete_id,
    assignment_date,
    rank_title_id
FROM dated_ranks
ON CONFLICT (athlete_id, rank_title_id) DO NOTHING;

ANALYZE Country;
ANALYZE Region;
ANALYZE City;
ANALYZE Club;
ANALYZE Athlete;
ANALYZE Rank_title;
ANALYZE Rank;

COMMIT;
