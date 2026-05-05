ANALYZE;
--48
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

--41. Выбрать id и фамилию и инициалы спортсменов, название разряда на начало прошлого года.
--на 01.01
--можно попробовать через оконки, выбрать первое или через максимум по разрядам
EXPLAIN ANALYZE
SELECT a.athlete_id,
       a.last_name || ' ' || LEFT(a.first_name, 1) || '.' AS fio,
       r.assignment_date,
       rt.rank_title
FROM Athlete a
         JOIN Rank r ON r.athlete_id = a.athlete_id
         JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
WHERE EXTRACT(YEAR FROM r.assignment_date) = 2024
ORDER BY a.athlete_id, r.assignment_date DESC;

--альтернативный вариант
--через  >= < самый результативный, если есть индекс по дате присвоения

EXPLAIN ANALYZE
SELECT a.athlete_id,
       a.last_name || ' ' || LEFT(a.first_name, 1) || '.' AS fio,
       r.assignment_date,
       rt.rank_title
FROM Athlete a
         JOIN Rank r ON r.athlete_id = a.athlete_id
         JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
WHERE r.assignment_date >= '2024-01-01'
  AND r.assignment_date < '2025-01-01'
ORDER BY a.athlete_id, r.assignment_date DESC;