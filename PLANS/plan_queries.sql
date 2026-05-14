--48
ANALYZE;
EXPLAIN ANALYZE
SELECT DISTINCT a.*
FROM Athlete a
         JOIN Rank r ON r.athlete_id = a.athlete_id
         JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
WHERE rt.previous_rank_id IS NOT NULL
  AND NOT EXISTS (SELECT 1
                  FROM Rank r_prev
                  WHERE r_prev.athlete_id = a.athlete_id
                    AND r_prev.rank_title_id = rt.previous_rank_id);

EXPLAIN ANALYZE
WITH RECURSIVE rank_chain AS (SELECT rank_title_id, rank_title, previous_rank_id, 1 AS lvl
                              FROM Rank_title
                              WHERE previous_rank_id IS NULL

                              UNION ALL

                              SELECT rt.rank_title_id, rt.rank_title, rt.previous_rank_id, rc.lvl + 1
                              FROM Rank_title rt
                                       JOIN rank_chain rc ON rt.previous_rank_id = rc.rank_title_id)
SELECT DISTINCT a.*
FROM Athlete a
         JOIN Rank r ON r.athlete_id = a.athlete_id
         JOIN rank_chain rc ON rc.rank_title_id = r.rank_title_id
WHERE rc.previous_rank_id IS NOT NULL
  AND NOT EXISTS (SELECT 1
                  FROM Rank r_prev
                  WHERE r_prev.athlete_id = a.athlete_id
                    AND r_prev.rank_title_id = rc.previous_rank_id);



--45. Выбрать фамилии, имена, отчества трех самых высоких
--спортсменов.

EXPLAIN ANALYZE
SELECT last_name, first_name, middle_name
FROM Athlete
ORDER BY height DESC
LIMIT 3;

--альтернативный вариант
--с использованием оконной функции ROW_NUMBER
EXPLAIN ANALYZE
SELECT last_name, first_name, middle_name
FROM (SELECT *, ROW_NUMBER() OVER (ORDER BY height DESC) AS rn
      FROM Athlete) t
WHERE rn <= 3;

--50. Выбрать все данные соревнования, в котором приняли
--участие все клубы.

EXPLAIN ANALYZE SELECT t.*
FROM Tournament t
WHERE NOT EXISTS (
    SELECT 1
    FROM Club c
    WHERE NOT EXISTS (
        SELECT 1
        FROM Match m
        WHERE m.tournament_id = t.tournament_id
        AND (m.club1_id = c.club_id OR m.club2_id = c.club_id)
    )
);

--альтернативный вариант
--через сравнение количества клубов

EXPLAIN ANALYZE SELECT t.*
FROM Tournament t
         JOIN Match m ON m.tournament_id = t.tournament_id
GROUP BY t.tournament_id
HAVING COUNT(DISTINCT
             CASE WHEN m.club1_id IS NOT NULL THEN m.club1_id
                  WHEN m.club2_id IS NOT NULL THEN m.club2_id
                 END
       ) = (SELECT COUNT(*) FROM Club);