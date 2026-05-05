BEGIN;

-- Additive benchmark dataset for plan_queries.sql.
-- No existing data is deleted.
-- The script is intended to create a noticeably larger working set for:
-- 48: rank chain with missing previous rank
-- 49: club stats over athletes and matches
-- 51: tournament with maximum number of distinct clubs

INSERT INTO Country (name)
VALUES ('PLAN_BENCH_COUNTRY')
ON CONFLICT (name) DO NOTHING;

INSERT INTO Region (name, country_id)
SELECT 'PLAN_BENCH_REGION', c.country_id
FROM Country c
WHERE c.name = 'PLAN_BENCH_COUNTRY'
ON CONFLICT (name, country_id) DO NOTHING;

INSERT INTO City (name, region_id)
SELECT 'PLAN_BENCH_CITY', r.region_id
FROM Region r
JOIN Country c ON c.country_id = r.country_id
WHERE r.name = 'PLAN_BENCH_REGION'
  AND c.name = 'PLAN_BENCH_COUNTRY'
ON CONFLICT (name, region_id) DO NOTHING;

INSERT INTO Stadion (name, address)
SELECT s.name, s.address
FROM (
    VALUES
        ('PLAN_STADION_1', 'PLAN Address 1'),
        ('PLAN_STADION_2', 'PLAN Address 2'),
        ('PLAN_STADION_3', 'PLAN Address 3')
) AS s(name, address)
WHERE NOT EXISTS (
    SELECT 1
    FROM Stadion st
    WHERE st.name = s.name
      AND st.address = s.address
);

DO $$
DECLARE
    rank_1_id INTEGER;
    rank_2_id INTEGER;
    rank_3_id INTEGER;
    rank_4_id INTEGER;
    rank_5_id INTEGER;
    rank_6_id INTEGER;
    rank_7_id INTEGER;
BEGIN
    INSERT INTO Rank_title (rank_title, previous_rank_id)
    VALUES ('PLAN_RANK_1', NULL)
    ON CONFLICT (rank_title) DO NOTHING;

    SELECT rank_title_id INTO rank_1_id
    FROM Rank_title
    WHERE rank_title = 'PLAN_RANK_1';

    INSERT INTO Rank_title (rank_title, previous_rank_id)
    VALUES ('PLAN_RANK_2', rank_1_id)
    ON CONFLICT (rank_title) DO NOTHING;

    SELECT rank_title_id INTO rank_2_id
    FROM Rank_title
    WHERE rank_title = 'PLAN_RANK_2';

    INSERT INTO Rank_title (rank_title, previous_rank_id)
    VALUES ('PLAN_RANK_3', rank_2_id)
    ON CONFLICT (rank_title) DO NOTHING;

    SELECT rank_title_id INTO rank_3_id
    FROM Rank_title
    WHERE rank_title = 'PLAN_RANK_3';

    INSERT INTO Rank_title (rank_title, previous_rank_id)
    VALUES ('PLAN_RANK_4', rank_3_id)
    ON CONFLICT (rank_title) DO NOTHING;

    SELECT rank_title_id INTO rank_4_id
    FROM Rank_title
    WHERE rank_title = 'PLAN_RANK_4';

    INSERT INTO Rank_title (rank_title, previous_rank_id)
    VALUES ('PLAN_RANK_5', rank_4_id)
    ON CONFLICT (rank_title) DO NOTHING;

    SELECT rank_title_id INTO rank_5_id
    FROM Rank_title
    WHERE rank_title = 'PLAN_RANK_5';

    INSERT INTO Rank_title (rank_title, previous_rank_id)
    VALUES ('PLAN_RANK_6', rank_5_id)
    ON CONFLICT (rank_title) DO NOTHING;

    SELECT rank_title_id INTO rank_6_id
    FROM Rank_title
    WHERE rank_title = 'PLAN_RANK_6';

    INSERT INTO Rank_title (rank_title, previous_rank_id)
    VALUES ('PLAN_RANK_7', rank_6_id)
    ON CONFLICT (rank_title) DO NOTHING;

    SELECT rank_title_id INTO rank_7_id
    FROM Rank_title
    WHERE rank_title = 'PLAN_RANK_7';

    UPDATE Rank_title
    SET previous_rank_id = NULL
    WHERE rank_title = 'PLAN_RANK_1';

    UPDATE Rank_title
    SET previous_rank_id = rank_1_id
    WHERE rank_title = 'PLAN_RANK_2';

    UPDATE Rank_title
    SET previous_rank_id = rank_2_id
    WHERE rank_title = 'PLAN_RANK_3';

    UPDATE Rank_title
    SET previous_rank_id = rank_3_id
    WHERE rank_title = 'PLAN_RANK_4';

    UPDATE Rank_title
    SET previous_rank_id = rank_4_id
    WHERE rank_title = 'PLAN_RANK_5';

    UPDATE Rank_title
    SET previous_rank_id = rank_5_id
    WHERE rank_title = 'PLAN_RANK_6';

    UPDATE Rank_title
    SET previous_rank_id = rank_6_id
    WHERE rank_title = 'PLAN_RANK_7';
END $$;

WITH bench_city AS (
    SELECT ci.city_id
    FROM City ci
    JOIN Region r ON r.region_id = ci.region_id
    JOIN Country c ON c.country_id = r.country_id
    WHERE ci.name = 'PLAN_BENCH_CITY'
      AND r.name = 'PLAN_BENCH_REGION'
      AND c.name = 'PLAN_BENCH_COUNTRY'
),
club_source AS (
    SELECT
        format('PLAN_CLUB_%s', lpad(gs::text, 4, '0')) AS name,
        bc.city_id,
        DATE '1990-01-01' + ((gs % 1000) * INTERVAL '1 day') AS foundation_date
    FROM bench_city bc
    CROSS JOIN generate_series(1, 800) AS gs
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
    WHERE c.name LIKE 'PLAN_CLUB_%'
      AND ci.name = 'PLAN_BENCH_CITY'
      AND r.name = 'PLAN_BENCH_REGION'
      AND co.name = 'PLAN_BENCH_COUNTRY'
),
athlete_source AS (
    SELECT
        bc.club_id,
        bc.club_no,
        a_no,
        ((bc.club_no - 1) * 45 + a_no) AS athlete_seq
    FROM bench_clubs bc
    CROSS JOIN generate_series(1, 45) AS a_no
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
    src.club_id,
    format('PlanLast%s', src.athlete_seq),
    format('PlanFirst%s', src.a_no),
    NULL,
    CASE WHEN src.athlete_seq % 2 = 0 THEN 'male' ELSE 'female' END,
    DATE '1995-01-01' + ((src.athlete_seq % 8000) * INTERVAL '1 day'),
    '+7999' || lpad(src.athlete_seq::text, 7, '0'),
    165 + (src.athlete_seq % 30),
    55 + (src.athlete_seq % 35)
FROM athlete_source src
ON CONFLICT (phone) DO NOTHING;

WITH bench_athletes AS (
    SELECT
        a.athlete_id,
        ROW_NUMBER() OVER (ORDER BY a.athlete_id) AS athlete_no
    FROM Athlete a
    WHERE a.phone LIKE '+7999%'
),
rank_map AS (
    SELECT
        rt.rank_title_id,
        CAST(replace(rt.rank_title, 'PLAN_RANK_', '') AS INTEGER) AS rank_no
    FROM Rank_title rt
    WHERE rt.rank_title LIKE 'PLAN_RANK_%'
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
        (
            ba.athlete_no % 10 IN (0, 1, 2, 3, 4)
            AND rm.rank_no <= 5
        )
        OR (
            ba.athlete_no % 10 = 5
            AND rm.rank_no IN (1, 2, 4)
        )
        OR (
            ba.athlete_no % 10 = 6
            AND rm.rank_no IN (1, 3, 5)
        )
        OR (
            ba.athlete_no % 10 = 7
            AND rm.rank_no <= 7
        )
        OR (
            ba.athlete_no % 10 = 8
            AND rm.rank_no IN (4, 6)
        )
        OR (
            ba.athlete_no % 10 = 9
            AND rm.rank_no = 4
        )
)
INSERT INTO Rank (athlete_id, assignment_date, rank_title_id)
SELECT
    rs.athlete_id,
    DATE '2010-01-01' + (((rs.athlete_no * 11) + rs.rank_no) % 5000) * INTERVAL '1 day',
    rs.rank_title_id
FROM rank_source rs
ON CONFLICT (athlete_id, rank_title_id) DO NOTHING;

WITH stadion_map AS (
    SELECT
        s.stadion_id,
        ROW_NUMBER() OVER (ORDER BY s.stadion_id) AS stadion_no
    FROM Stadion s
    WHERE s.name LIKE 'PLAN_STADION_%'
),
tournament_source AS (
    SELECT
        gs AS tournament_no,
        format('PLAN_TOURNAMENT_%s', lpad(gs::text, 3, '0')) AS name,
        DATE '2025-01-01' + (gs * INTERVAL '10 day') AS start_ts,
        DATE '2025-01-05' + (gs * INTERVAL '10 day') AS end_ts,
        ((gs - 1) % 3) + 1 AS stadion_no,
        100000 + gs * 25000 AS prize_fund
    FROM generate_series(1, 36) AS gs
)
INSERT INTO Tournament (name, start_date, end_date, stadion_id, prize_fund)
SELECT
    ts.name,
    ts.start_ts,
    ts.end_ts,
    sm.stadion_id,
    ts.prize_fund
FROM tournament_source ts
JOIN stadion_map sm ON sm.stadion_no = ts.stadion_no
WHERE NOT EXISTS (
    SELECT 1
    FROM Tournament t
    WHERE t.name = ts.name
);

WITH bench_clubs AS (
    SELECT
        c.club_id,
        ROW_NUMBER() OVER (ORDER BY c.club_id) AS club_no
    FROM Club c
    JOIN City ci ON ci.city_id = c.city_id
    JOIN Region r ON r.region_id = ci.region_id
    JOIN Country co ON co.country_id = r.country_id
    WHERE c.name LIKE 'PLAN_CLUB_%'
      AND ci.name = 'PLAN_BENCH_CITY'
      AND r.name = 'PLAN_BENCH_REGION'
      AND co.name = 'PLAN_BENCH_COUNTRY'
),
bench_tournaments AS (
    SELECT
        t.tournament_id,
        CAST(right(t.name, 3) AS INTEGER) AS tournament_no
    FROM Tournament t
    WHERE t.name LIKE 'PLAN_TOURNAMENT_%'
),
tournament_club_pool AS (
    SELECT
        bt.tournament_id,
        bt.tournament_no,
        bc.club_id,
        ROW_NUMBER() OVER (
            PARTITION BY bt.tournament_id
            ORDER BY bc.club_no
        ) AS local_club_no
    FROM bench_tournaments bt
    JOIN bench_clubs bc
      ON bc.club_no <= CASE
          WHEN bt.tournament_no = 36 THEN 800
          WHEN bt.tournament_no = 35 THEN 720
          WHEN bt.tournament_no = 34 THEN 640
          ELSE 80 + bt.tournament_no * 12
      END
),
match_source AS (
    SELECT
        tcp.tournament_id,
        tcp.club_id AS club1_id,
        lead(tcp.club_id, 1) OVER (
            PARTITION BY tcp.tournament_id
            ORDER BY tcp.local_club_no
        ) AS club2_id,
        tcp.local_club_no,
        1 AS round_no
    FROM tournament_club_pool tcp
    WHERE tcp.local_club_no % 2 = 1

    UNION ALL

    SELECT
        tcp.tournament_id,
        tcp.club_id AS club1_id,
        lead(tcp.club_id, 3) OVER (
            PARTITION BY tcp.tournament_id
            ORDER BY tcp.local_club_no
        ) AS club2_id,
        tcp.local_club_no,
        2 AS round_no
    FROM tournament_club_pool tcp
    WHERE tcp.local_club_no % 4 = 1

    UNION ALL

    SELECT
        tcp.tournament_id,
        tcp.club_id AS club1_id,
        lead(tcp.club_id, 5) OVER (
            PARTITION BY tcp.tournament_id
            ORDER BY tcp.local_club_no
        ) AS club2_id,
        tcp.local_club_no,
        3 AS round_no
    FROM tournament_club_pool tcp
    WHERE tcp.local_club_no % 6 = 1
),
prepared_matches AS (
    SELECT
        ms.tournament_id,
        ms.club1_id,
        ms.club2_id,
        DATE '2025-06-01'
            + ((ms.tournament_id * 13 + ms.local_club_no + ms.round_no) % 330) * INTERVAL '1 day' AS match_date,
        TIME '10:00:00'
            + (((ms.local_club_no + ms.round_no) % 8) * INTERVAL '1 hour') AS match_time,
        (ms.local_club_no + ms.round_no) % 6 AS result_1,
        (ms.local_club_no + ms.round_no + 2) % 6 AS result_2
    FROM match_source ms
    WHERE ms.club2_id IS NOT NULL
      AND ms.club1_id <> ms.club2_id
)
INSERT INTO Match (
    tournament_id,
    club1_id,
    club2_id,
    match_date,
    match_time,
    result_1,
    result_2
)
SELECT
    pm.tournament_id,
    pm.club1_id,
    pm.club2_id,
    pm.match_date,
    pm.match_time,
    pm.result_1,
    pm.result_2
FROM prepared_matches pm
WHERE NOT EXISTS (
    SELECT 1
    FROM Match m
    WHERE m.tournament_id = pm.tournament_id
      AND m.club1_id = pm.club1_id
      AND m.club2_id = pm.club2_id
      AND m.match_date = pm.match_date
      AND m.match_time = pm.match_time
);

COMMIT;
