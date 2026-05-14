--45. Выбрать фамилии, имена, отчества трех самых высоких
--спортсменов.
--вариант где оконка не лучше
--без оконки
EXPLAIN ANALYZE
SELECT last_name, first_name, middle_name
FROM Athlete
ORDER BY height DESC
LIMIT 3;

-- с ней
EXPLAIN ANALYZE
SELECT last_name, first_name, middle_name
FROM (
         SELECT *, ROW_NUMBER() OVER (ORDER BY height DESC) AS rn
         FROM Athlete
     ) t
WHERE rn <= 3;

--51. Выбрать все данные соревнования, в котором приняло
--участие наибольшее количество клубов. 
--вариант где оконка лучше
--без оконки
EXPLAIN ANALYZE
SELECT t.*
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

--с ней
EXPLAIN ANALYZE
WITH tournament_rank AS (
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