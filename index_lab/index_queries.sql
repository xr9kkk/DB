-- Скрываем неважные предупреждения при повторном запуске скрипта.
SET client_min_messages = warning;

DROP TABLE IF EXISTS athlete_no_index CASCADE;
DROP TABLE IF EXISTS athlete_with_index CASCADE;

SET client_min_messages = notice;

-- Создаем две одинаковые учебные таблицы.
-- INCLUDING ALL не используем, потому что он скопировал бы индексы из Athlete.
CREATE TABLE athlete_no_index
(LIKE Athlete INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

CREATE TABLE athlete_with_index
(LIKE Athlete INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

-- Копируем одинаковые исходные данные в обе таблицы.
INSERT INTO athlete_no_index SELECT * FROM Athlete;
INSERT INTO athlete_with_index SELECT * FROM Athlete;

-- Дополнительные индексы создаем только на athlete_with_index.
CREATE INDEX idx_athlete_last_name ON athlete_with_index(last_name);
CREATE INDEX idx_athlete_birth_date ON athlete_with_index(birth_date);

ANALYZE athlete_no_index;
ANALYZE athlete_with_index;

-- SELECT: точечный поиск по индексируемому столбцу.
EXPLAIN ANALYZE
SELECT *
FROM athlete_with_index
WHERE last_name = 'Kozlov';

EXPLAIN ANALYZE
SELECT *
FROM athlete_no_index
WHERE last_name = 'Kozlov';

-- SELECT: условие с низкой селективностью. Индекс есть, но Seq Scan может быть дешевле.
EXPLAIN ANALYZE
SELECT *
FROM athlete_with_index
WHERE birth_date > '2000-01-01';

-- Подготовка DML: создаем предсказуемые группы строк для UPDATE и DELETE.
INSERT INTO athlete_no_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 1, 'DmlUpdate', 'DmlUpdateGroup', 'male', '2000-01-01',
       '+7901000' || LPAD(i::TEXT, 5, '0'), 180, 75
FROM generate_series(1, 5000) AS i;

INSERT INTO athlete_with_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 1, 'DmlUpdate', 'DmlUpdateGroup', 'male', '2000-01-01',
       '+7902000' || LPAD(i::TEXT, 5, '0'), 180, 75
FROM generate_series(1, 5000) AS i;

INSERT INTO athlete_no_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 1, 'DmlDelete', 'DmlDeleteGroup', 'female', '1999-01-01',
       '+7903000' || LPAD(i::TEXT, 5, '0'), 170, 60
FROM generate_series(1, 5000) AS i;

INSERT INTO athlete_with_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 1, 'DmlDelete', 'DmlDeleteGroup', 'female', '1999-01-01',
       '+7904000' || LPAD(i::TEXT, 5, '0'), 170, 60
FROM generate_series(1, 5000) AS i;

ANALYZE athlete_no_index;
ANALYZE athlete_with_index;

-- UPDATE неиндексируемого столбца.
-- Условие использует last_name, поэтому таблица с индексом может найти строки через индекс.
EXPLAIN ANALYZE
UPDATE athlete_no_index
SET height = height + 1
WHERE last_name = 'DmlUpdate';

EXPLAIN ANALYZE
UPDATE athlete_with_index
SET height = height + 1
WHERE last_name = 'DmlUpdate';

-- UPDATE индексируемого столбца.
-- Обе таблицы ищут строки по first_name без подходящего индекса, но
-- athlete_with_index дополнительно обновляет idx_athlete_last_name,
-- потому что меняется last_name.
EXPLAIN ANALYZE
UPDATE athlete_no_index
SET last_name = 'DmlUpdated'
WHERE first_name = 'DmlUpdateGroup';

EXPLAIN ANALYZE
UPDATE athlete_with_index
SET last_name = 'DmlUpdated'
WHERE first_name = 'DmlUpdateGroup';

-- DELETE существующих строк.
-- Обе таблицы удаляют одинаковое количество строк, но таблица с индексами
-- должна также удалить соответствующие записи из индексов.
EXPLAIN ANALYZE
DELETE FROM athlete_no_index
WHERE first_name = 'DmlDeleteGroup';

EXPLAIN ANALYZE
DELETE FROM athlete_with_index
WHERE first_name = 'DmlDeleteGroup';

-- INSERT новых строк в обе таблицы.
-- Таблица с индексами выполняет больше работы, потому что каждая новая строка
-- должна быть добавлена в idx_athlete_last_name и idx_athlete_birth_date.
EXPLAIN ANALYZE
INSERT INTO athlete_no_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 1, 'DmlInsert' || i, 'DmlInsertGroup', 'male', '2001-01-01',
       '+7905000' || LPAD(i::TEXT, 5, '0'), 180, 75
FROM generate_series(1, 10000) AS i;

EXPLAIN ANALYZE
INSERT INTO athlete_with_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 1, 'DmlInsert' || i, 'DmlInsertGroup', 'male', '2001-01-01',
       '+7906000' || LPAD(i::TEXT, 5, '0'), 180, 75
FROM generate_series(1, 10000) AS i;
