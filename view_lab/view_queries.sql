ANALYZE;
--Создаём представление, которое НЕ трансформируется (с оконной функцией)
CREATE OR REPLACE VIEW v_athlete_rank_stats AS
SELECT a.athlete_id,
       a.last_name,
       a.first_name,
       a.birth_date,
       c.name                                                           AS club_name,
       rt.rank_title,
       -- оконная функция: ранг спортсмена по возрасту в клубе
       ROW_NUMBER() OVER (PARTITION BY a.club_id ORDER BY a.birth_date) AS age_rank_in_club,
       -- оконная функция: количество спортсменов в клубе
       COUNT(*) OVER (PARTITION BY a.club_id)                           AS athletes_in_club
FROM Athlete a
         JOIN Club c ON a.club_id = c.club_id
         LEFT JOIN Rank r ON a.athlete_id = r.athlete_id
         LEFT JOIN Rank_title rt ON r.rank_title_id = rt.rank_title_id;

--Ожидаемый план: WindowAgg выполняется до фильтрации.
EXPLAIN ANALYZE
SELECT *
FROM v_athlete_rank_stats
WHERE age_rank_in_club <= 3;

--Создаём представление, которое трансформируется (простое)
CREATE OR REPLACE VIEW v_club_athlete_count AS
SELECT c.club_id,
       c.name              AS club_name,
       COUNT(a.athlete_id) AS athlete_count
FROM Club c
         LEFT JOIN Athlete a ON c.club_id = a.club_id
GROUP BY c.club_id, c.name;

EXPLAIN ANALYZE
SELECT *
FROM v_club_athlete_count
WHERE athlete_count > 5;
--Ожидаемый план: Фильтр athlete_count > 5 применяется внутри группировки (или сразу после), трансформация произошла.

/*CREATE MATERIALIZED VIEW mv_athlete_awards AS
SELECT a.athlete_id,
       a.last_name,
       a.first_name,
       a.middle_name,
       c.name                        AS club_name,
       COUNT(DISTINCT aw.award_id)   AS total_awards,
       COUNT(DISTINCT at.award_name) AS distinct_award_types,
       MAX(aw.award_date)            AS last_award_date
FROM Athlete a
         JOIN Club c ON a.club_id = c.club_id
         LEFT JOIN Award aw ON a.athlete_id = aw.athlete_id
         LEFT JOIN Award_type at ON aw.award_type_id = at.award_type_id
GROUP BY a.athlete_id, a.last_name, a.first_name, a.middle_name, c.name;*/

-- Запрос к материализованному представлению
EXPLAIN ANALYZE
SELECT *
FROM mv_athlete_awards
WHERE total_awards > 2;

-- Тот же запрос к обычным таблицам (без MV)
EXPLAIN ANALYZE
SELECT a.athlete_id,
       a.last_name,
       a.first_name,
       a.middle_name,
       c.name                        AS club_name,
       COUNT(DISTINCT aw.award_id)   AS total_awards,
       COUNT(DISTINCT at.award_name) AS distinct_award_types,
       MAX(aw.award_date)            AS last_award_date
FROM Athlete a
         JOIN Club c ON a.club_id = c.club_id
         LEFT JOIN Award aw ON a.athlete_id = aw.athlete_id
         LEFT JOIN Award_type at ON aw.award_type_id = at.award_type_id
GROUP BY a.athlete_id, a.last_name, a.first_name, a.middle_name, c.name
HAVING COUNT(DISTINCT aw.award_id) > 2;

-- Добавляем новую награду спортсмену
INSERT INTO Award (athlete_id, award_date, award_type_id)
SELECT athlete_id, CURRENT_DATE, (SELECT award_type_id FROM Award_type WHERE award_name = 'Gold Medal' LIMIT 1)
FROM Athlete
LIMIT 1;

-- Показать, что в MV данные не обновились
SELECT *
FROM mv_athlete_awards
WHERE athlete_id = (SELECT athlete_id FROM Athlete LIMIT 1);

-- Показать актуальные данные из таблиц для конкретного спортсмена
SELECT a.athlete_id, a.last_name, a.first_name, COUNT(aw.award_id) AS actual_award_count
FROM Athlete a
         LEFT JOIN Award aw ON a.athlete_id = aw.athlete_id
WHERE a.athlete_id = (SELECT athlete_id FROM Athlete ORDER BY athlete_id LIMIT 1)
GROUP BY a.athlete_id, a.last_name, a.first_name;

REFRESH MATERIALIZED VIEW mv_athlete_awards;
SELECT *
FROM mv_athlete_awards
WHERE athlete_id = (SELECT athlete_id FROM Athlete LIMIT 1);