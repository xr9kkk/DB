-- Скрываем неважные предупреждения при повторном запуске скрипта.
SET client_min_messages = warning;

DROP TABLE IF EXISTS athlete_no_index CASCADE;
DROP TABLE IF EXISTS athlete_with_index CASCADE;

SET client_min_messages = notice;

CREATE TABLE athlete_no_index
(LIKE Athlete INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

CREATE TABLE athlete_with_index
(LIKE Athlete INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

-- Копируем одинаковые исходные данные в обе таблицы.
INSERT INTO athlete_no_index SELECT * FROM Athlete;
INSERT INTO athlete_with_index SELECT * FROM Athlete;

-- Дополнительные индексы создаем только на athlete_with_index.
-- Создаем индексы на last_name и first_name для демонстрации
CREATE INDEX idx_athlete_last_name ON athlete_with_index(last_name);
CREATE INDEX idx_athlete_first_name ON athlete_with_index(first_name);  -- НОВЫЙ индекс для first_name
CREATE INDEX idx_athlete_birth_date ON athlete_with_index(birth_date);

ANALYZE athlete_no_index;
ANALYZE athlete_with_index;


-- Вставка 100,000 строк с разными last_name для демонстрации точечного поиска
INSERT INTO athlete_no_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    (random() * 100)::int,
    'Test_' || LPAD(i::TEXT, 6, '0'),
    'FirstName_' || LPAD((random() * 1000)::int::TEXT, 4, '0'),
    CASE WHEN random() > 0.5 THEN 'male' ELSE 'female' END,
    '1990-01-01'::date + (random() * 3650)::int,
    '+7901' || LPAD((random() * 9999999)::int::TEXT, 7, '0'),
    150 + (random() * 50)::int,
    50 + (random() * 50)::int
FROM generate_series(1, 100000) AS i;

INSERT INTO athlete_with_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    (random() * 100)::int,
    'Test_' || LPAD(i::TEXT, 6, '0'),
    'FirstName_' || LPAD((random() * 1000)::int::TEXT, 4, '0'),
    CASE WHEN random() > 0.5 THEN 'male' ELSE 'female' END,
    '1990-01-01'::date + (random() * 3650)::int,
    '+7902' || LPAD((random() * 9999999)::int::TEXT, 7, '0'),
    150 + (random() * 50)::int,
    50 + (random() * 50)::int
FROM generate_series(1, 100000) AS i;

-- Добавляем целенаправленные данные для точечного поиска (чтобы гарантированно найти Kozlov)
INSERT INTO athlete_no_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    1,
    'Kozlov',
    'Name_' || i::TEXT,
    'male',
    '1995-01-01'::date + (i % 365),
    '+7903000' || LPAD(i::TEXT, 5, '0'),
    170 + (i % 30),
    60 + (i % 40)
FROM generate_series(1, 5000) AS i;

INSERT INTO athlete_with_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    1,
    'Kozlov',
    'Name_' || i::TEXT,
    'male',
    '1995-01-01'::date + (i % 365),
    '+7904000' || LPAD(i::TEXT, 5, '0'),
    170 + (i % 30),
    60 + (i % 40)
FROM generate_series(1, 5000) AS i;

-- Добавляем данные с разными датами рождения для демонстрации индекса по birth_date
INSERT INTO athlete_no_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    (random() * 50)::int,
    'BirthTest_' || LPAD(i::TEXT, 6, '0'),
    'BirthFirst_' || LPAD(i::TEXT, 6, '0'),
    CASE WHEN random() > 0.5 THEN 'male' ELSE 'female' END,
    '1980-01-01'::date + (random() * 10950)::int,
    '+7905' || LPAD(i::TEXT, 7, '0'),
    150 + (random() * 50)::int,
    50 + (random() * 50)::int
FROM generate_series(1, 50000) AS i;

INSERT INTO athlete_with_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    (random() * 50)::int,
    'BirthTest_' || LPAD(i::TEXT, 6, '0'),
    'BirthFirst_' || LPAD(i::TEXT, 6, '0'),
    CASE WHEN random() > 0.5 THEN 'male' ELSE 'female' END,
    '1980-01-01'::date + (random() * 10950)::int,
    '+7906' || LPAD(i::TEXT, 7, '0'),
    150 + (random() * 50)::int,
    50 + (random() * 50)::int
FROM generate_series(1, 50000) AS i;

-- ===== БОЛЬШИЕ ГРУППЫ ДАННЫХ ДЛЯ DML ОПЕРАЦИЙ =====

-- Группа для UPDATE неиндексируемого столбца (height)
-- Будем искать по ИНДЕКСИРОВАННОМУ полю last_name
INSERT INTO athlete_no_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    1, 
    'UpdateGroup',  -- Будем искать по этому полю (есть индекс в athlete_with_index)
    'UpdateFirstName_' || i::TEXT, 
    'male', 
    '2000-01-01'::date + (i % 365),
    '+7901000' || LPAD(i::TEXT, 6, '0'), 
    180, 
    75
FROM generate_series(1, 50000) AS i;

INSERT INTO athlete_with_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    1, 
    'UpdateGroup',  -- Будем искать по этому полю (есть индекс idx_athlete_last_name)
    'UpdateFirstName_' || i::TEXT, 
    'male', 
    '2000-01-01'::date + (i % 365),
    '+7902000' || LPAD(i::TEXT, 6, '0'), 
    180, 
    75
FROM generate_series(1, 50000) AS i;

-- Группа для UPDATE индексируемого столбца (last_name)
-- Будем искать по ИНДЕКСИРОВАННОМУ полю first_name
INSERT INTO athlete_no_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    1, 
    'IndexedUpdate_Old', 
    'IndexedUpdateGroup',  -- Будем искать по этому полю (есть индекс в athlete_with_index)
    'female', 
    '1999-01-01'::date + (i % 365),
    '+7903000' || LPAD(i::TEXT, 6, '0'), 
    170, 
    60
FROM generate_series(1, 50000) AS i;

INSERT INTO athlete_with_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    1, 
    'IndexedUpdate_Old', 
    'IndexedUpdateGroup',  -- Будем искать по этому полю (есть индекс idx_athlete_first_name)
    'female', 
    '1999-01-01'::date + (i % 365),
    '+7904000' || LPAD(i::TEXT, 6, '0'), 
    170, 
    60
FROM generate_series(1, 50000) AS i;

-- Группа для DELETE (будем удалять по ИНДЕКСИРОВАННОМУ столбцу last_name)
INSERT INTO athlete_no_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    1, 
    'DeleteGroupIndexed',  -- Будем удалять по этому полю (есть индекс в athlete_with_index)
    'DeleteFirstName_' || i::TEXT, 
    'female', 
    '1998-01-01'::date + (i % 365),
    '+7905000' || LPAD(i::TEXT, 6, '0'), 
    165, 
    65
FROM generate_series(1, 50000) AS i;

INSERT INTO athlete_with_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    1, 
    'DeleteGroupIndexed',  -- Будем удалять по этому полю (есть индекс idx_athlete_last_name)
    'DeleteFirstName_' || i::TEXT, 
    'female', 
    '1998-01-01'::date + (i % 365),
    '+7906000' || LPAD(i::TEXT, 6, '0'), 
    165, 
    65
FROM generate_series(1, 50000) AS i;

ANALYZE;
-- ===== ТЕСТОВЫЕ ЗАПРОСЫ =====

-- 1. UPDATE неиндексируемого столбца (height)
-- Поиск по ИНДЕКСИРОВАННОМУ полю last_name
-- Ожидается: Seq Scan (без индекса) vs Index Scan (с индексом)
EXPLAIN ANALYZE
UPDATE athlete_no_index
SET height = height + 1
WHERE last_name = 'UpdateGroup';

EXPLAIN ANALYZE
UPDATE athlete_with_index
SET height = height + 1
WHERE last_name = 'UpdateGroup';

-- 2. UPDATE индексируемого столбца (last_name)
-- Поиск по ИНДЕКСИРОВАННОМУ полю first_name
EXPLAIN ANALYZE
UPDATE athlete_no_index
SET last_name = 'IndexedUpdate_New'
WHERE first_name = 'IndexedUpdateGroup';

EXPLAIN ANALYZE
UPDATE athlete_with_index
SET last_name = 'IndexedUpdate_New'
WHERE first_name = 'IndexedUpdateGroup';

-- 3. DELETE по ИНДЕКСИРОВАННОМУ столбцу last_name
-- Ожидается: Seq Scan (без индекса) vs Index Scan (с индексом)
EXPLAIN ANALYZE
DELETE FROM athlete_no_index
WHERE last_name = 'DeleteGroupIndexed';

EXPLAIN ANALYZE
DELETE FROM athlete_with_index
WHERE last_name = 'DeleteGroupIndexed';

-- 4. INSERT новых строк (50,000 строк)
EXPLAIN ANALYZE
INSERT INTO athlete_no_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    1, 
    'BigInsert_' || i::TEXT, 
    'BigInsertGroup', 
    'male', 
    '2002-01-01'::date + (i % 365),
    '+7907000' || LPAD(i::TEXT, 6, '0'), 
    175, 
    70
FROM generate_series(1, 50000) AS i;

EXPLAIN ANALYZE
INSERT INTO athlete_with_index
    (club_id, last_name, first_name, gender, birth_date, phone, height, weight)
SELECT 
    1, 
    'BigInsert_' || i::TEXT, 
    'BigInsertGroup', 
    'male', 
    '2002-01-01'::date + (i % 365),
    '+7908000' || LPAD(i::TEXT, 6, '0'), 
    175, 
    70
FROM generate_series(1, 50000) AS i;
