--48
EXPLAIN ANALYZE SELECT DISTINCT a.*
                FROM Athlete a
                         JOIN Rank r ON r.athlete_id = a.athlete_id
                         JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
                WHERE rt.previous_rank_id IS NOT NULL
                  AND NOT EXISTS (
                    SELECT 1
                    FROM Rank r_prev
                    WHERE r_prev.athlete_id = a.athlete_id
                      AND r_prev.rank_title_id = rt.previous_rank_id
                );

EXPLAIN ANALYZE WITH RECURSIVE rank_chain AS (
    SELECT rank_title_id, rank_title, previous_rank_id, 1 AS lvl
    FROM Rank_title
    WHERE previous_rank_id IS NULL

    UNION ALL

    SELECT rt.rank_title_id, rt.rank_title, rt.previous_rank_id, rc.lvl + 1
    FROM Rank_title rt
             JOIN rank_chain rc ON rt.previous_rank_id = rc.rank_title_id
)
SELECT DISTINCT a.*
FROM Athlete a
         JOIN Rank r ON r.athlete_id = a.athlete_id
         JOIN rank_chain rc ON rc.rank_title_id = r.rank_title_id
WHERE rc.previous_rank_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM Rank r_prev
    WHERE r_prev.athlete_id = a.athlete_id
      AND r_prev.rank_title_id = rc.previous_rank_id
);


--51

EXPLAIN ANALYZE SELECT t.*
                FROM Tournament t
                         JOIN (
                    SELECT tournament_id, COUNT(DISTINCT club_id) AS club_count
                    FROM (
                             SELECT tournament_id, club1_id AS club_id
                             FROM Match
                             WHERE club1_id IS NOT NULL

                             UNION

                             SELECT tournament_id, club2_id AS club_id
                             FROM Match
                             WHERE club2_id IS NOT NULL
                         ) clubs
                    GROUP BY tournament_id
                ) tc ON tc.tournament_id = t.tournament_id
                WHERE tc.club_count = (
                    SELECT MAX(club_count)
                    FROM (
                             SELECT tournament_id, COUNT(DISTINCT club_id) AS club_count
                             FROM (
                                      SELECT tournament_id, club1_id AS club_id
                                      FROM Match
                                      WHERE club1_id IS NOT NULL

                                      UNION

                                      SELECT tournament_id, club2_id AS club_id
                                      FROM Match
                                      WHERE club2_id IS NOT NULL
                                  ) all_clubs
                             GROUP BY tournament_id
                         ) max_counts
                );

--альтернативный вариант
--с использованием оконной функции
EXPLAIN ANALYZE WITH tournament_rank AS (
    SELECT 
        t.*,
        RANK() OVER (ORDER BY tc.club_count DESC) AS rnk
    FROM Tournament t
    JOIN (
        SELECT tournament_id, COUNT(DISTINCT club_id) AS club_count
        FROM (
            SELECT tournament_id, club1_id AS club_id
            FROM Match
            WHERE club1_id IS NOT NULL

            UNION

            SELECT tournament_id, club2_id AS club_id
            FROM Match
            WHERE club2_id IS NOT NULL
        ) clubs
        GROUP BY tournament_id
    ) tc ON tc.tournament_id = t.tournament_id
)
SELECT *
FROM tournament_rank
WHERE rnk = 1;

--49
EXPLAIN ANALYZE WITH club_stats_base AS (
    SELECT
        c.club_id,
        c.name,
        a.athlete_id,
        m.match_id,
        ROW_NUMBER() OVER (
            PARTITION BY c.club_id, a.athlete_id
            ORDER BY m.match_id NULLS FIRST
        ) AS athlete_rn,
        ROW_NUMBER() OVER (
            PARTITION BY c.club_id, m.match_id
            ORDER BY a.athlete_id NULLS FIRST
        ) AS match_rn
    FROM Club c
    LEFT JOIN Athlete a ON a.club_id = c.club_id
    LEFT JOIN Match m ON c.club_id IN (m.club1_id, m.club2_id)
),
club_stats AS (
    SELECT
        club_id,
        name,
        SUM(
            CASE
                WHEN athlete_id IS NOT NULL AND athlete_rn = 1 THEN 1
                ELSE 0
            END
        ) OVER (PARTITION BY club_id) AS athletes,
        SUM(
            CASE
                WHEN match_id IS NOT NULL AND match_rn = 1 THEN 1
                ELSE 0
            END
        ) OVER (PARTITION BY club_id) AS matches,
        ROW_NUMBER() OVER (PARTITION BY club_id ORDER BY club_id) AS club_rn
    FROM club_stats_base
),
total_matches AS (
    SELECT total_matches
    FROM (
        SELECT
            COUNT(*) OVER () AS total_matches,
            ROW_NUMBER() OVER (ORDER BY match_id) AS rn
        FROM Match
    ) t
    WHERE rn = 1

    UNION ALL

    SELECT 0
    WHERE NOT EXISTS (SELECT 1 FROM Match)
)
SELECT
    cs.name,
    cs.athletes,
    cs.matches,
    tm.total_matches,
    cs.matches * 100.0 / NULLIF(tm.total_matches, 0) AS percent
FROM club_stats cs
         CROSS JOIN total_matches tm
WHERE cs.club_rn = 1
ORDER BY cs.name;

EXPLAIN ANALYZE SELECT c.name,
                       COUNT(DISTINCT a.athlete_id) AS athletes,
                       COUNT(DISTINCT m.match_id) AS matches,
                       (SELECT COUNT(*) FROM Match) AS total_matches,
                       COUNT(DISTINCT m.match_id) * 100.0 / (SELECT COUNT(*) FROM Match) AS percent
                FROM Club c
                         LEFT JOIN Athlete a ON a.club_id = c.club_id
                         LEFT JOIN Match m ON m.club1_id = c.club_id OR m.club2_id = c.club_id
                GROUP BY c.club_id;