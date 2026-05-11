--неоправданный цте
EXPLAIN ANALYZE
WITH athletes_for_sort AS (SELECT last_name, first_name, middle_name, height
                           FROM Athlete)
SELECT last_name, first_name, middle_name
FROM athletes_for_sort
ORDER BY height DESC
LIMIT 3;
--вариант без цте
EXPLAIN ANALYZE
SELECT last_name, first_name, middle_name
FROM Athlete
ORDER BY height DESC
LIMIT 3;
--оправданный цте
EXPLAIN ANALYZE
WITH club_counts AS (
    SELECT
        club_id,
        COUNT(*) AS athlete_count
    FROM Athlete
    GROUP BY club_id
)
SELECT
    a.last_name,
    a.first_name,
    a.middle_name,
    c.name
FROM Athlete a
         JOIN Club c ON a.club_id = c.club_id
         JOIN club_counts cc ON a.club_id = cc.club_id
WHERE cc.athlete_count = (
    SELECT MAX(athlete_count)
    FROM club_counts
)
ORDER BY a.last_name, a.first_name;