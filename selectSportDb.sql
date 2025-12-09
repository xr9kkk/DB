-- 1. Выбрать все данные о спортивных клубах. Результат отсортировать по названию в порядке обратном лексикографическому.
SELECT * FROM Club ORDER BY name DESC;

-- 2. Выбрать данные о клубах старше 20 лет. Результат отсортировать по названию в лексикографическом порядке.
SELECT * FROM Club 
WHERE foundation_date <= CURRENT_DATE - INTERVAL '20 years' 
ORDER BY name ASC;

-- 3. Выбрать фамилии, имена, отчества, даты рождения спортсменов.
-- В результат должны войти спортсмены с фамилией, начинающейся на «К-» или «М-» и состоящей из 4 букв.
SELECT last_name, first_name, middle_name, birth_date 
FROM Athlete 
WHERE (last_name LIKE 'K%' OR last_name LIKE 'M%') 
  AND LENGTH(last_name) = 4
ORDER BY birth_date DESC, last_name DESC, first_name DESC, middle_name DESC;

-- 4. Выбрать фамилию и инициалы, дату рождения спортсменов, для которых в столбце место жительства есть символы «?», «_», «*», «&».	
SELECT a.last_name, a.first_name, LEFT(a.middle_name, 1) as middle_initial, a.birth_date
FROM Athlete a
JOIN Club c ON a.club_id = c.club_id
JOIN City ct ON c.city_id = ct.city_id
WHERE ct.name LIKE '%?%' 
   OR ct.name LIKE '%*%' 
   OR ct.name LIKE '%&%' 
   OR ct.name LIKE '%_%'
ORDER BY a.birth_date;

-- 5. Выбрать фамилии, имена, отчества спортсменов в возрасте от 18 до 21 года.
SELECT last_name, first_name, middle_name 
FROM Athlete 
WHERE AGE(birth_date) BETWEEN INTERVAL '18 years' AND INTERVAL '21 years'
ORDER BY last_name, first_name, middle_name;


-- 6. Выбрать все данные о соревнованиях с id равным 1, 3, 4, 7, 10. 
SELECT *
FROM Tournament 
WHERE tournament_id IN (1, 3, 4, 7, 10)
ORDER BY tournament_id % 2, tournament_id;

-- 7. Выбрать id_стадиона, у которого нет адреса в БД.
SELECT tournament_id
FROM Tournament
WHERE venue_address IS NULL OR venue_address = '';

-- 8. Выбрать годы рождения спортсменов без повторений. Результат отсортировать в порядке возрастания.
SELECT DISTINCT EXTRACT(YEAR FROM birth_date) as birth_year 
FROM Athlete 
ORDER BY birth_year ASC;

-- 9. Выбрать фамилию, имя, первую букву отчества спортсменов,
-- рожденных весной или осенью с двойной фамилией, для которых не указана позиция в игре.
-- для этого запроса создана доп таблица GamePosition
SELECT 
    last_name,
    first_name,
    LEFT(middle_name, 1) AS middle_initial
FROM Athlete
WHERE 
    (EXTRACT(MONTH FROM birth_date) BETWEEN 3 AND 5 
     OR EXTRACT(MONTH FROM birth_date) BETWEEN 9 AND 11)
    AND last_name LIKE '%-%'
    AND game_position_id IS NULL;


-- 10. Выбрать фамилии, имена, отчества спортсменов в первом столбце
-- во втором столбце указать название времени года рождения спортсмена.
SELECT 
    last_name || ' ' || first_name || ' ' || COALESCE(middle_name, '') as full_name,
    CASE 
        WHEN EXTRACT(MONTH FROM birth_date) IN (12, 1, 2) THEN 'зима'
        WHEN EXTRACT(MONTH FROM birth_date) IN (3, 4, 5) THEN 'весна'
        WHEN EXTRACT(MONTH FROM birth_date) IN (6, 7, 8) THEN 'лето'
        WHEN EXTRACT(MONTH FROM birth_date) IN (9, 10, 11) THEN 'осень'
    END as season
FROM Athlete
ORDER BY 
    CASE 
        WHEN EXTRACT(MONTH FROM birth_date) IN (12, 1, 2) THEN 1
        WHEN EXTRACT(MONTH FROM birth_date) IN (3, 4, 5) THEN 2
        WHEN EXTRACT(MONTH FROM birth_date) IN (6, 7, 8) THEN 3
        WHEN EXTRACT(MONTH FROM birth_date) IN (9, 10, 11) THEN 4
    END,
    LENGTH(last_name), LENGTH(first_name), LENGTH(middle_name);

-- 11. Выбрать максимальный рост спортсмена.
SELECT
MAX(height) as max_height
FROM Athlete;

-- 12. Выбрать средний рост спортсменов, рожденных с 1995 по 2000 год.
SELECT 
    ROUND(AVG(height), 2) AS average_height
FROM Athlete
WHERE EXTRACT(YEAR FROM birth_date) BETWEEN 1995 AND 2000;

-- 13. Выбрать фамилию, имя, отчество спортсмена, год рождения, название спортивного клуба.
SELECT a.last_name, a.first_name, a.middle_name, EXTRACT(YEAR FROM a.birth_date) as birth_year, c.name as club_name
FROM Athlete a
JOIN Club c ON a.club_id = c.club_id
ORDER BY c.name, a.last_name;

-- 14. Выбрать фамилии, имени, отчество спортсменов мужского пола
-- год рождения, название спортивного клуба, название разряда и дату присвоения разряда
-- дату проведения игры, название соревнования, название награды и дату вручения награды.
SELECT 
    a.last_name, a.first_name, a.middle_name,
    EXTRACT(YEAR FROM a.birth_date) as birth_year,
    c.name as club_name,
    rt.rank_title,
    r.assignment_date,
    m.match_date,
    t.name as tournament_name,
    at.award_name,
    aw.award_date
FROM Athlete a
JOIN Club c ON a.club_id = c.club_id
LEFT JOIN Rank r ON a.athlete_id = r.athlete_id
LEFT JOIN Rank_title rt ON r.rank_title_id = rt.rank_title_id
LEFT JOIN Award aw ON a.athlete_id = aw.athlete_id
LEFT JOIN Award_type at ON aw.award_type_id = at.award_type_id
LEFT JOIN Match m ON (c.club_id = m.club1_id OR c.club_id = m.club2_id)
LEFT JOIN Tournament t ON m.match_id = t.match_id
WHERE a.gender = 'male'
ORDER BY c.name DESC, a.height ASC, a.last_name ASC;

-- 15. Выбрать название спортивного клуба и количество спортсменов в нем.
SELECT c.name as club_name, COUNT(a.athlete_id) as athlete_count
FROM Club c
LEFT JOIN Athlete a ON c.club_id = a.club_id
GROUP BY c.club_id, c.name
ORDER BY athlete_count DESC;

-- 16. Выбрать название спортивного клуба, количество спортсменов и количество работников в клубе.
SELECT 
    c.name as club_name,
    COUNT(DISTINCT a.athlete_id) as athlete_count,
    COUNT(DISTINCT e.employee_id) as employee_count
FROM Club c
LEFT JOIN Athlete a ON c.club_id = a.club_id
LEFT JOIN Employee e ON c.club_id = e.club_id
GROUP BY c.club_id, c.name
ORDER BY athlete_count DESC;

-- 17. Выбрать среднюю зарплату работников спортклуба X 
SELECT AVG(e.salary) as average_salary
FROM Employee e
JOIN Club c ON e.club_id = c.club_id
WHERE c.name = 'Bayern';

-- 18. Выбрать название соревнования и количество игр, проводимых в прошлом году.
SELECT 
    t.tournament_id,
    t.name as tournament_name,
    t.start_date,
    t.end_date,
    COUNT(tm.match_id) as match_count,
    STRING_AGG(
        CONCAT(c1.name, ' vs ', c2.name, ' (', TO_CHAR(m.match_date, 'DD.MM.YYYY'), ')'), 
        ', ' ORDER BY m.match_date
    ) as match_list
FROM Tournament t
LEFT JOIN Tournament_Matches tm ON t.tournament_id = tm.tournament_id
LEFT JOIN Match m ON tm.match_id = m.match_id
LEFT JOIN Club c1 ON m.club1_id = c1.club_id
LEFT JOIN Club c2 ON m.club2_id = c2.club_id
WHERE EXTRACT(YEAR FROM t.start_date) = 2024
GROUP BY t.tournament_id, t.name, t.start_date, t.end_date
ORDER BY t.start_date;


-- 19. Выбрать id, фамилию, имя, отчество спонсора, общую сумму взноса спонсоров спортивного клуба X 
SELECT 
    s.sponsor_id,
    COALESCE(sp.last_name, so.org_name) as sponsor_name,
    COALESCE(sp.first_name, '') as first_name,
    COALESCE(sp.middle_name, '') as middle_name,
    SUM(sps.donation_amount) as total_donation
FROM Sponsor s
LEFT JOIN sponsor_person sp ON s.sponsor_id = sp.sponsor_id
LEFT JOIN sponsor_org so ON s.sponsor_id = so.sponsor_id
JOIN Sponsorship sps ON s.sponsor_id = sps.sponsor_id
JOIN Club c ON sps.club_id = c.club_id
WHERE c.name = 'Spartak'
GROUP BY s.sponsor_id, sponsor_name, first_name, middle_name;

-- 20. Выбрать id, названия и адреса стадионов, на которых проходило более двух соревнований.
SELECT 
    venue_name,
    venue_address,
    COUNT(*) as tournament_count
FROM Tournament
GROUP BY venue_name, venue_address
HAVING COUNT(*) > 1
ORDER BY tournament_count DESC;

-- 21. Выбрать все данные о спортсменах мужского пола, имеющих два или более разряда.
SELECT 
    a.athlete_id,
    a.last_name,
    a.first_name,
    COUNT(r.rank_id) as rank_count,
    STRING_AGG(rt.rank_title, ', ' ORDER BY r.assignment_date) as ranks
FROM Athlete a
JOIN Rank r ON a.athlete_id = r.athlete_id
JOIN Rank_title rt ON r.rank_title_id = rt.rank_title_id
WHERE a.gender = 'male'
GROUP BY a.athlete_id, a.last_name, a.first_name
HAVING COUNT(r.rank_id) >= 2
ORDER BY rank_count DESC;

-- 22. Выбрать пары однофамильцев среди спонсоров и спортсменов
SELECT 
    sp.last_name as sponsor_last_name,
    a.last_name as athlete_last_name
FROM sponsor_person sp
JOIN Athlete a ON sp.last_name = a.last_name;


-- 23. Выбрать id, фамилию и инициалы спортсменов и, если у спортсмена есть награды, то дату вручения и название.
SELECT 
    a.athlete_id,
    a.last_name,
    LEFT(a.first_name, 1) as first_initial,
    LEFT(a.middle_name, 1) as middle_initial,
    aw.award_date,
    at.award_name
FROM Athlete a
LEFT JOIN Award aw ON a.athlete_id = aw.athlete_id
LEFT JOIN Award_type at ON aw.award_type_id = at.award_type_id
ORDER BY a.last_name, a.first_name;

-- 24. Выбрать названия всех стадионов и, если на стадионе в прошлом году проходили соревнования, то количество игр.
SELECT 
    t.venue_name,
    COUNT(DISTINCT t.tournament_id) as tournament_count,
    COUNT(m.match_id) as match_count
FROM Tournament t
LEFT JOIN Match m ON t.match_id = m.match_id
WHERE EXTRACT(YEAR FROM t.start_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
GROUP BY t.venue_name
UNION ALL
SELECT 
    t.venue_name,
    0 as tournament_count,
    0 as match_count
FROM Tournament t
WHERE NOT EXISTS (
    SELECT 1 FROM Tournament t2 
    WHERE t2.venue_name = t.venue_name 
    AND EXTRACT(YEAR FROM t2.start_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
)
GROUP BY t.venue_name;

-- 25. Для каждого спортивного клуба выбрать названия всех соревнований
-- Результат отсортировать по названию клуба и соревнования
SELECT 
    c.name as club_name,
    t.name as tournament_name
FROM Club c
CROSS JOIN Tournament t
ORDER BY c.name, t.name;

-- 26. Для каждого спортивного клуба выбрать названия всех соревнований и,
-- если клуб принимал участие в соответствующем соревновании, то количество сыгранных игр.
SELECT 
    c.name as club_name,
    t.name as tournament_name,
    COUNT(CASE WHEN m.club1_id = c.club_id OR m.club2_id = c.club_id THEN 1 END) as matches_played
FROM Club c
CROSS JOIN Tournament t
LEFT JOIN Match m ON t.match_id = m.match_id AND (m.club1_id = c.club_id OR m.club2_id = c.club_id)
GROUP BY c.club_id, c.name, t.tournament_id, t.name
ORDER BY c.name, t.name;

-- 27. Выбрать фамилии, имена, отчества спортсменов выше среднего роста.
SELECT 
    last_name,
    first_name,
    middle_name
FROM Athlete
WHERE height > (SELECT AVG(height) FROM Athlete)
ORDER BY last_name, first_name, middle_name;

-- 28. Выбрать название должности работников с наибольшей зарплатой.
SELECT DISTINCT p.position_type
FROM Employee e
JOIN Position p ON e.position_id = p.position_id
WHERE e.salary = (SELECT MAX(salary) FROM Employee);

-- 29. Выбрать id, фамилию, имя, отчество спортсмена и его разряд актуальный на данный момент.
SELECT 
    a.athlete_id,
    a.last_name,
    a.first_name,
    a.middle_name,
    rt.rank_title as current_rank
FROM Athlete a
JOIN Rank r ON a.athlete_id = r.athlete_id
JOIN Rank_title rt ON r.rank_title_id = rt.rank_title_id
WHERE r.assignment_date = (
    SELECT MAX(assignment_date) 
    FROM Rank r2 
    WHERE r2.athlete_id = a.athlete_id
)
ORDER BY a.last_name, a.first_name;

-- 30. Выбрать id и название клуба без спортсменов.
SELECT 
    c.club_id,
    c.name as club_name
FROM Club c
LEFT JOIN Athlete a ON c.club_id = a.club_id
WHERE a.athlete_id IS NULL
ORDER BY c.name;

-- 31. Выбрать название стадиона, на котором не проводилось ни одной игры в текущем году.
SELECT DISTINCT t.venue_name
FROM Tournament t
LEFT JOIN Match m ON t.match_id = m.match_id 
    AND EXTRACT(YEAR FROM m.match_date) = EXTRACT(YEAR FROM CURRENT_DATE)
WHERE m.match_id IS NULL;

-- 32. Выбрать id и названия стадионов, на которых проходило
-- больше двух соревнований, по три игры в каждом. 
SELECT 
    t.venue_name,
    COUNT(DISTINCT t.tournament_id) as tournament_count,
    COUNT(DISTINCT m.match_id) as total_matches
FROM Tournament t
JOIN Match m ON t.match_id = m.match_id
GROUP BY t.venue_name
HAVING COUNT(DISTINCT t.tournament_id) > 2 
   AND COUNT(DISTINCT m.match_id) >= 3;

-- 33. Выбрать название спортивного клуба, который принял участие во всех соревнованиях, имеющихся в БД. 
SELECT c.name as club_name
FROM Club c
WHERE NOT EXISTS (
    SELECT t.tournament_id
    FROM Tournament t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Match m
        WHERE m.match_id = t.match_id
          AND (m.club1_id = c.club_id OR m.club2_id = c.club_id)
    )
);

-- 34. Выбрать фамилию, имя, отчество спонсора, внесшего
-- максимальную сумму в прошлом году. 
SELECT 
    spp.last_name,
    spp.first_name,
    spp.middle_name,
    SUM(s.donation_amount) as total_donation
FROM Sponsorship s
JOIN Sponsor sp ON s.sponsor_id = sp.sponsor_id
JOIN sponsor_person spp ON sp.sponsor_id = spp.sponsor_id
WHERE EXTRACT(YEAR FROM s.donation_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
GROUP BY sp.sponsor_id, spp.last_name, spp.first_name, spp.middle_name
ORDER BY total_donation DESC
LIMIT 1;

-- 35. Выбрать фамилии, имена, отчества спортсменов клуба X
-- которые одну и ту же награду получали дважды.
SELECT 
    a.last_name,
    a.first_name,
    a.middle_name,
    at.award_name,
    COUNT(*) as award_count
FROM Athlete a
JOIN Award aw ON a.athlete_id = aw.athlete_id
JOIN Award_type at ON aw.award_type_id = at.award_type_id
JOIN Club c ON a.club_id = c.club_id
WHERE c.name = 'Spartak'
GROUP BY a.athlete_id, a.last_name, a.first_name, a.middle_name, at.award_name
HAVING COUNT(*) >= 2
ORDER BY award_count DESC;

-- 36. Выбрать фамилии, имена, отчества спортсменов клуба с наибольшим количеством спортсменов.
SELECT 
    a.last_name,
    a.first_name,
    a.middle_name,
    c.name as club_name
FROM Athlete a
JOIN Club c ON a.club_id = c.club_id
WHERE c.club_id = (
    SELECT club_id
    FROM (
        SELECT 
            club_id,
            COUNT(athlete_id) as athlete_count,
            RANK() OVER (ORDER BY COUNT(athlete_id) DESC) as rnk
        FROM Athlete
        GROUP BY club_id
    ) as club_counts
    WHERE rnk = 1
)
ORDER BY a.last_name, a.first_name;

