-- 1. Выбрать все данные о спортивных клубах.
-- Результат отсортировать по названию в порядке обратном лексикографическому.
SELECT *
FROM Club
ORDER BY name DESC;

-- 2. Выбрать данные о клубах старше 20 лет. Результат отсортировать по названию в лексикографическом порядке.
SELECT *
FROM Club 
WHERE foundation_date <= CURRENT_DATE - INTERVAL '20 years' 
ORDER BY name ASC;

-- 3. Выбрать фамилии, имена, отчества, даты рождения спортсменов.
-- В результат должны войти спортсмены с фамилией, начинающейся на «К-» или «М-» и состоящей из 4 букв.
-- через like ограничение на 4 буквы
SELECT last_name, first_name, middle_name, birth_date 
FROM Athlete 
WHERE (last_name LIKE 'K___' OR last_name LIKE 'M___');

-- 4. Выбрать фамилию и инициалы, дату рождения спортсменов, для которых в столбце место жительства есть символы «?», «_», «*», «&».	
SELECT 
    a.last_name, 
    a.first_name, 
    LEFT(a.middle_name, 1) as middle_initial, 
    a.birth_date,
    ct.name as city_name
FROM Athlete a
JOIN Club c ON a.club_id = c.club_id
JOIN City ct ON c.city_id = ct.city_id
WHERE ct.name LIKE '%?%' 
   OR ct.name LIKE '%*%' 
   OR ct.name LIKE '%&%' 
   OR ct.name LIKE '%\_%' ESCAPE '\'; --экранируем _ 

-- 5. Выбрать фамилии, имена, отчества спортсменов в возрасте от 18 до 21 года.
SELECT last_name, first_name, middle_name 
FROM Athlete 
WHERE AGE(birth_date) BETWEEN INTERVAL '18 years' AND INTERVAL '21 years';


-- 6. Выбрать все данные о соревнованиях с id равным 1, 3, 4, 7, 10.
-- надо ли дописать вручную соревнования и айдишники сделать не через подзапрос?
SELECT *
FROM Tournament 
WHERE tournament_id IN (126, 132, 133, 127, 10);

SELECT *
FROM Tournament;
-- 7. Выбрать id_стадиона, у которого нет адреса в БД.
-- venue_address - NOT NULL
-- SELECT tournament_id
--FROM Tournament
-- WHERE venue_address IS NULL OR venue_address = '';

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
FROM Athlete;

-- 11. Выбрать максимальный рост спортсмена.
SELECT MAX(height) as max_height
FROM Athlete;

-- 12. Выбрать средний рост спортсменов, рожденных с 1995 по 2000 год.
SELECT ROUND(AVG(height), 2) AS average_height
FROM Athlete
WHERE EXTRACT(YEAR FROM birth_date) BETWEEN 1995 AND 2000;

-- 13. Выбрать фамилию, имя, отчество спортсмена, год рождения, название спортивного клуба.
SELECT a.last_name, a.first_name, a.middle_name, EXTRACT(YEAR FROM a.birth_date) as birth_year, c.name as club_name
FROM Athlete a
JOIN Club c ON a.club_id = c.club_id;

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
WHERE a.gender = 'male';

вариант с новыми инсертами
SELECT DISTINCT
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
LEFT JOIN Tournament t ON m.tournament_id = t.tournament_id
WHERE a.gender = 'male'
ORDER BY a.last_name, a.first_name;

-- 15. Выбрать название спортивного клуба и количество спортсменов в нем.
SELECT c.name AS club_name, COUNT (a.athlete_id) AS athlete_count
FROM Club c
JOIN Athlete a ON c.club_id = a.club_id
GROUP BY c.club_id, c.name
ORDER BY COUNT (a.athlete_id);

-- 16. Выбрать название спортивного клуба, количество спортсменов и количество работников в клубе.
SELECT 
    c.name AS club_name,
    COUNT(DISTINCT a.athlete_id) AS athlete_count,
    COUNT(DISTINCT e.employee_id) AS employee_count
FROM Club c
LEFT JOIN Athlete a ON c.club_id = a.club_id
LEFT JOIN Employee e ON c.club_id = e.club_id
GROUP BY c.club_id, c.name
ORDER BY COUNT(DISTINCT a.athlete_id);

-- 17. Выбрать среднюю зарплату работников спортклуба X 
SELECT AVG(e.salary) as average_salary
FROM Employee e
JOIN Club c ON e.club_id = c.club_id
WHERE c.name = 'Bayern';

-- 18. Выбрать название соревнования и количество игр, проводимых в прошлом году.
-- отказываемся от стринг агг
SELECT 
    t.tournament_id,
    t.name as tournament_name,
    t.start_date,
    t.end_date,
    COUNT(m.match_id) as match_count,
    STRING_AGG(
        CONCAT(c1.name, ' vs ', c2.name, ' (', TO_CHAR(m.match_date, 'DD.MM.YYYY'), ')'), 
        ', ' ORDER BY m.match_date
    ) as match_list
FROM Tournament t
JOIN Match m ON t.match_id = m.match_id
JOIN Club c1 ON m.club1_id = c1.club_id
JOIN Club c2 ON m.club2_id = c2.club_id
WHERE EXTRACT(YEAR FROM t.start_date) = 2024
GROUP BY t.tournament_id, t.name, t.start_date, t.end_date
ORDER BY t.start_date;
-- переписанный вариант
SELECT 
    t.tournament_id,
    t.name as tournament_name,
    t.start_date,
    t.end_date,
    COUNT(m.match_id) as match_count
FROM Tournament t
JOIN Match m ON t.match_id = m.match_id
JOIN Club c1 ON m.club1_id = c1.club_id
JOIN Club c2 ON m.club2_id = c2.club_id
WHERE EXTRACT(YEAR FROM t.start_date) = EXTRACT (YEAR FROM CURRENT_DATE) - 1
GROUP BY t.tournament_id, t.name, t.start_date, t.end_date
ORDER BY t.start_date;

переписанный вариант с новыми инсертами 
-- 18. Выбрать название соревнования и количество игр, проводимых в прошлом году.
SELECT 
    t.tournament_id,
    t.name as tournament_name,
    t.start_date,
    t.end_date,
    COUNT(m.match_id) as match_count
FROM Tournament t
LEFT JOIN Match m ON t.tournament_id = m.tournament_id
WHERE EXTRACT(YEAR FROM t.start_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
GROUP BY t.tournament_id, t.name, t.start_date, t.end_date
ORDER BY t.start_date;

-- 19. Выбрать id, фамилию, имя, отчество спонсора, общую сумму взноса спонсоров спортивного клуба X
-- добавить данные фамилия имя
переделать
если человек указать в одном столбце нейм, если организация то название организации
переделано
SELECT 
    s.sponsor_id,
    COALESCE(sp.last_name || ' ' || LEFT (sp.first_name,1) || '.' || LEFT (sp.middle_name,1), so.org_name) as sponsor_name,
    SUM(sps.donation_amount) as total_donation
FROM Sponsor s
LEFT JOIN sponsor_person sp ON s.sponsor_id = sp.sponsor_id
LEFT JOIN sponsor_org so ON s.sponsor_id = so.sponsor_id
JOIN Sponsorship sps ON s.sponsor_id = sps.sponsor_id
JOIN Club c ON sps.club_id = c.club_id
WHERE c.name = 'Bayern'
GROUP BY s.sponsor_id, sponsor_name, first_name, middle_name;

проверка
SELECT * FROM   Sponsor s 
LEFT JOIN sponsor_person sp ON s.sponsor_id = sp.sponsor_id
LEFT JOIN sponsor_org so ON s.sponsor_id = so.sponsor_id
JOIN Sponsorship sps ON s.sponsor_id = sps.sponsor_id;
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
    COUNT(r.rank_id) as rank_count
FROM Athlete a
JOIN Rank r ON a.athlete_id = r.athlete_id
JOIN Rank_title rt ON r.rank_title_id = rt.rank_title_id
WHERE a.gender = 'male'
GROUP BY a.athlete_id, a.last_name, a.first_name
HAVING COUNT(r.rank_id) >= 2
ORDER BY COUNT(r.rank_id) DESC;

-- 22. Выбрать пары однофамильцев среди спонсоров и спортсменов
SELECT 
    sp.last_name as sponsor_last_name,
    a.last_name as athlete_last_name
FROM sponsor_person sp
JOIN Athlete a ON sp.last_name = a.last_name;


-- 23. Выбрать id, фамилию и инициалы спортсменов и, если у спортсмена есть награды, то дату вручения и название.
SELECT 
    a.athlete_id,
    a.last_name || ' ' || LEFT(a.first_name, 1) || '.' || 
    CASE 
        WHEN a.middle_name IS NOT NULL AND a.middle_name != '' 
        THEN LEFT(a.middle_name, 1) || '.' 
        ELSE '' 
    END as full_name,
    aw.award_date,
    at.award_name
FROM Athlete a
LEFT JOIN Award aw ON a.athlete_id = aw.athlete_id
LEFT JOIN Award_type at ON aw.award_type_id = at.award_type_id
ORDER BY a.last_name, a.first_name;

-- 24. Выбрать названия всех стадионов и, если на стадионе в прошлом году проходили соревнования, то количество игр.
разные стадионы не должны входить в одну группу
переделано
SELECT 
	t.venue_address,
    t.venue_name,
    COUNT(DISTINCT t.tournament_id) as tournament_count,
    COUNT(m.match_id) as match_count
LEFT JOIN Match m ON t.match_id = m.match_id
WHERE EXTRACT(YEAR FROM t.start_date) = EXTRACT (YEAR FROM CURRENT_DATE) - 1
GROUP BY t.venue_address, t.venue_name
ORDER BY tournament_count DESC, match_count DESC;

переделано с новыми инсертами
-- 24. Выбрать названия всех стадионов и, если на стадионе в прошлом году проходили соревнования, то количество игр.
SELECT 
    t.venue_name,
    t.venue_address,
    COUNT(DISTINCT t.tournament_id) as tournament_count,
    COUNT(m.match_id) as match_count
FROM Tournament t
LEFT JOIN Match m ON t.tournament_id = m.tournament_id 
    AND EXTRACT(YEAR FROM m.match_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
GROUP BY t.venue_address, t.venue_name
ORDER BY tournament_count DESC, match_count DESC;

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

переписано с новыми инсертами 
-- 26. Для каждого спортивного клуба выбрать названия всех соревнований и,
-- если клуб принимал участие в соответствующем соревновании, то количество сыгранных игр.
SELECT 
    c.name as club_name,
    t.name as tournament_name,
    COUNT(CASE WHEN m.club1_id = c.club_id OR m.club2_id = c.club_id THEN 1 END) as matches_played
FROM Club c
CROSS JOIN Tournament t
LEFT JOIN Match m ON t.tournament_id = m.tournament_id 
    AND (m.club1_id = c.club_id OR m.club2_id = c.club_id)
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
переделать с exists
переделано
SELECT 
    c.club_id,
    c.name as club_name
FROM Club c
WHERE NOT EXISTS (
    SELECT 1
    FROM Athlete a
    WHERE a.club_id = c.club_id
)
ORDER BY c.name;

-- 31. Выбрать название стадиона, на котором не проводилось ни одной игры в текущем году.
переделать с exists добавить адрес
переделано
SELECT 
		t.venue_name,
	 	t.venue_address
FROM Tournament t
WHERE NOT EXISTS (
    SELECT 1
    FROM Match m
    WHERE m.match_id = t.match_id 
        AND EXTRACT(YEAR FROM m.match_date) = EXTRACT(YEAR FROM CURRENT_DATE)
)
ORDER BY t.venue_name, t.venue_address;
переделано с новыми инсертами
-- 31. Выбрать название стадиона, на котором не проводилось ни одной игры в текущем году.
SELECT 
    t.venue_name,
    t.venue_address,
	t.name
FROM Tournament t
WHERE NOT EXISTS (
    SELECT 1
    FROM Match m
    WHERE m.tournament_id = t.tournament_id 
        AND EXTRACT(YEAR FROM m.match_date) = EXTRACT(YEAR FROM CURRENT_DATE)
)
ORDER BY t.venue_name, t.venue_address;

-- 32. Выбрать id и названия стадионов, на которых проходило
-- больше двух соревнований, по три игры в каждом.
переписать для использования городов с одинаковым названием стадионов и переписать чтобы в одном соревновании было три игры и при этом
соревнований больше двух
переписано

переписано с новыми инсертами
SELECT 
    s.name AS stadium_name,
    s.address AS stadium_address,
    COUNT(DISTINCT t.name) AS tournament_count
FROM Tournament t
JOIN Stadion s ON t.stadion_id = s.stadion_id
WHERE s.stadion_id IN (
    SELECT t2.stadion_id
    FROM Tournament t2
    JOIN Match m ON t2.tournament_id = m.tournament_id
    GROUP BY t2.stadion_id, t2.name
    HAVING COUNT(m.match_id) = 3  
)
GROUP BY s.stadion_id, s.name, s.address
HAVING COUNT(DISTINCT t.name) > 2 
ORDER BY s.name;



-- 33. Выбрать название спортивного клуба, который принял участие во всех соревнованиях, имеющихся в БД.
придумать второй вариант без NOT EXISTS (можно попробовать через count)
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

вариант с переписанными инсертами
SELECT c.name as club_name
FROM Club c
JOIN Match m ON c.club_id = m.club1_id OR c.club_id = m.club2_id
JOIN Tournament t ON m.tournament_id = t.tournament_id
GROUP BY c.club_id, c.name
HAVING COUNT(DISTINCT t.tournament_id) = (SELECT COUNT(*) FROM Tournament)
ORDER BY c.name;

-- 34. Выбрать фамилию, имя, отчество спонсора, внесшего
-- максимальную сумму в прошлом году.
придумать вариант без лимит
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

альтернативный вариант

WITH sponsor_totals AS (
    SELECT 
        s.sponsor_id,
        SUM(s.donation_amount) as total_donation
    FROM Sponsorship s
    WHERE EXTRACT(YEAR FROM s.donation_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
    GROUP BY s.sponsor_id
),
person_totals AS (
    SELECT 
        st.sponsor_id,
        st.total_donation,
        sp.last_name,
        sp.first_name,
        sp.middle_name
    FROM sponsor_totals st
    JOIN sponsor_person sp ON st.sponsor_id = sp.sponsor_id
)
SELECT 
    last_name,
    first_name,
    middle_name,
    total_donation
FROM person_totals
WHERE total_donation = (SELECT MAX(total_donation) FROM person_totals);

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
HAVING COUNT(*) = 2
ORDER BY award_count DESC;

-- 36. Выбрать фамилии, имена, отчества спортсменов клуба с наибольшим количеством спортсменов.
переписать альтернативно
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
альтернативный вариант
WITH counts AS (
    SELECT club_id, COUNT(*) as cnt
    FROM Athlete
    GROUP BY club_id
)
SELECT a.last_name, a.first_name, a.middle_name, c.name
FROM Athlete a
JOIN Club c ON a.club_id = c.club_id
WHERE a.club_id = (
    SELECT club_id
	FROM counts
	ORDER BY cnt DESC LIMIT 1
)
ORDER BY a.last_name, a.first_name;
переписать под несколько клубов с максимальным количеством игроков


WITH counts AS (
	SELECT club_id,
	COUNT(*) as cnt
	FROM Athlete
	GROUP BY club_id
),

max_count AS (
	SELECT MAX(cnt) as max_cnt
	FROM counts
)
SELECT a.last_name, a.first_name, a.middle_name, c.name
FROM Athlete a
JOIN Club c ON a.club_id = c.club_id
WHERE a.club_id IN (
    SELECT club_id
	FROM counts
	WHERE cnt = (SELECT max_cnt FROM max_count)
	)
ORDER BY a.last_name, a.first_name;
сократить количество селектов и переписать и использованием оправданных cte

WITH club_counts AS (
    SELECT 
        club_id,
        COUNT(*) as athlete_count
    FROM Athlete
    GROUP BY club_id
)
SELECT a.last_name, a.first_name, a.middle_name, c.name
FROM Athlete a
JOIN Club c ON a.club_id = c.club_id
JOIN club_counts cc ON a.club_id = cc.club_id
WHERE cc.athlete_count = (SELECT MAX (athlete_count) FROM club_counts)
ORDER BY a.last_name, a.first_name;


WITH club_counts AS (
    SELECT 
        club_id,
        COUNT(*) as athlete_count
    FROM Athlete
    GROUP BY club_id
)
SELECT a.last_name, a.first_name, a.middle_name, c.name
FROM Athlete a
JOIN Club c ON a.club_id = c.club_id
WHERE a.club_id IN (
    SELECT club_id
    FROM club_counts
    WHERE athlete_count = (SELECT MAX(athlete_count) FROM club_counts)
)
ORDER BY a.last_name, a.first_name;

37. Выбрать названия клубов, которые приняли участие в
двух и более соревнованиях и в которых есть игроки с наибольшим разрядом. 

альтернативный вариант попробовать через соединение таблиц
нужно чтобы было два и более матча
SELECT c.name
FROM Club c
JOIN Athlete a ON a.club_id = c.club_id
JOIN Rank r ON r.athlete_id = a.athlete_id
JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
JOIN Match m ON c.club_id IN (m.club1_id, m.club2_id)
WHERE NOT EXISTS (
      SELECT 1
      FROM Rank_title r2
      WHERE r2.previous_rank_id = rt.rank_title_id --смотрим где есть след разряд, если след разряда нет, то наибольший разряд
)
GROUP BY c.club_id, c.name
HAVING COUNT(DISTINCT m.tournament_id) >= 2;

альтернативный вариант
Использование оконной функции

SELECT DISTINCT c.name
FROM Club c
JOIN (
    SELECT DISTINCT
        a.club_id,
        FIRST_VALUE(rt.rank_title_id) OVER (
            PARTITION BY a.athlete_id 
            ORDER BY r.assignment_date DESC
        ) AS current_rank_id
    FROM Athlete a
    JOIN Rank r ON r.athlete_id = a.athlete_id
    JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
) ahr ON ahr.club_id = c.club_id
JOIN Match m ON c.club_id IN (m.club1_id, m.club2_id)
WHERE NOT EXISTS (
    SELECT 1 FROM Rank_title rt2 
    WHERE rt2.previous_rank_id = ahr.current_rank_id
)
GROUP BY c.club_id, c.name
HAVING COUNT(DISTINCT m.tournament_id) >= 2;


Выбрать названия клубов, которые приняли участие в
двух и более соревнованиях и в которых есть игроки с наибольшим разрядом. 
третий альтернативный вариант
альтернативный вариант попробовать через соединение таблиц
нужно чтобы было два и более матча
--не очень правильный вариант
SELECT c.name
FROM Club c
JOIN Athlete a ON a.club_id = c.club_id
JOIN Rank r ON r.athlete_id = a.athlete_id
JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
LEFT JOIN Match m1 ON m1.club1_id = c.club_id
LEFT JOIN Match m2 ON m2.club2_id = c.club_id
WHERE NOT EXISTS (
      SELECT 1
      FROM Rank_title r2
      WHERE r2.previous_rank_id = rt.rank_title_id
)
GROUP BY c.club_id, c.name
HAVING COUNT(DISTINCT COALESCE(m1.match_id, m2.match_id)) >= 2;

-- хороший альтернативный вариант
SELECT c.name
FROM Club c
JOIN (
    SELECT DISTINCT a.club_id
    FROM Athlete a
    JOIN Rank r ON r.athlete_id = a.athlete_id
    JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM Rank_title r2
        WHERE r2.previous_rank_id = rt.rank_title_id
    )
) max_rank_clubs
    ON max_rank_clubs.club_id = c.club_id

JOIN (
    SELECT club_id
    FROM (
        SELECT club1_id AS club_id, tournament_id FROM Match
        UNION ALL
        SELECT club2_id AS club_id, tournament_id FROM Match
    ) m
    GROUP BY club_id
    HAVING COUNT(DISTINCT tournament_id) >= 2
) match_clubs
    ON match_clubs.club_id = c.club_id;
38. Выбрать все данные спонсора, который каждый год делает взносы с момента образования клуба. 
рекурсивно насобирать года и проверить на вычитание годов, если множество окажется пустым, то подойдет

SELECT s.*
FROM Sponsor s
JOIN Sponsorship sp ON sp.sponsor_id = s.sponsor_id
JOIN Club c ON c.club_id = sp.club_id
GROUP BY s.sponsor_id, c.club_id, c.foundation_date
HAVING COUNT(DISTINCT EXTRACT(YEAR FROM sp.donation_date)) =
       EXTRACT(YEAR FROM CURRENT_DATE) - 
       EXTRACT(YEAR FROM c.foundation_date) + 1;

альтернативный вариант
Для каждого клуба-спонсора считаем количество взносов и сравниваем с количеством лет

SELECT s.*
FROM Sponsor s
WHERE NOT EXISTS (
    SELECT 1
    FROM Club c
    WHERE EXISTS (
        SELECT 1 FROM Sponsorship sp
        WHERE sp.sponsor_id = s.sponsor_id AND sp.club_id = c.club_id
    )
      AND (
              (SELECT EXTRACT(YEAR FROM CURRENT_DATE)) -
              (SELECT EXTRACT(YEAR FROM c.foundation_date)) + 1
              ) <> (
              SELECT COUNT(DISTINCT EXTRACT(YEAR FROM sp.donation_date))
              FROM Sponsorship sp
              WHERE sp.sponsor_id = s.sponsor_id AND sp.club_id = c.club_id
          )
);

третий альтернативный вариант 
WITH RECURSIVE club_years AS (
    SELECT 
        c.club_id,
        EXTRACT(YEAR FROM c.foundation_date)::int AS y
    FROM Club c

    UNION ALL

    SELECT
        club_id,
        y + 1
    FROM club_years
    WHERE y < EXTRACT(YEAR FROM CURRENT_DATE)
)

SELECT s.*
FROM Sponsor s
JOIN Club c ON TRUE
WHERE NOT EXISTS (
    SELECT y
    FROM club_years cy
    WHERE cy.club_id = c.club_id

    EXCEPT

    SELECT EXTRACT(YEAR FROM sp.donation_date)::int
    FROM Sponsorship sp
    WHERE sp.sponsor_id = s.sponsor_id
      AND sp.club_id = c.club_id
);

39. Выбрать все данные спонсора, который делает взносы
для нескольких клубов, но в каждом из этих клубов есть спортсмены с разрядами и наградами.

SELECT s.*
FROM Sponsor s
JOIN Sponsorship sp ON sp.sponsor_id = s.sponsor_id
JOIN Club c ON c.club_id = sp.club_id
JOIN Athlete a ON a.club_id = c.club_id
JOIN Rank r ON r.athlete_id = a.athlete_id
JOIN Award aw ON aw.athlete_id = a.athlete_id
GROUP BY s.sponsor_id
HAVING COUNT(DISTINCT c.club_id) > 1;

альтернативный вариант 
проверка через MIN количества наград и разрядов по клубам

SELECT s.*
FROM Sponsor s
JOIN Sponsorship sp ON sp.sponsor_id = s.sponsor_id
JOIN Club c ON c.club_id = sp.club_id
GROUP BY s.sponsor_id
HAVING COUNT(DISTINCT c.club_id) > 1
   AND MIN(
       (SELECT COUNT(*) FROM Athlete a 
        JOIN Rank r ON r.athlete_id = a.athlete_id
        WHERE a.club_id = c.club_id)
   ) > 0
   AND MIN(
       (SELECT COUNT(*) FROM Athlete a 
        JOIN Award aw ON aw.athlete_id = a.athlete_id
        WHERE a.club_id = c.club_id)
   ) > 0;

40. Выбрать все данные спонсора, который делает взносы
для нескольких клубов, но в каждом из этих клубов есть спортсмены с наивысшим разрядом.

можем для каждого клуба посчитать количество спортсменов с наисвысшим разрядом и оно должно быть больше нуля,
тогда нам подходит клуб, потом берем спонсора
смотрим сколько у него спонсируется клубов и если >= 2
SELECT s.*
FROM Sponsor s
WHERE (
    -- Сначала находим спонсоров с несколькими клубами
    SELECT COUNT(DISTINCT sp.club_id)
    FROM Sponsorship sp
    WHERE sp.sponsor_id = s.sponsor_id
) > 1
AND NOT EXISTS (
    -- Затем проверяем, что нет клуба без высшего разряда
    SELECT 1
    FROM Sponsorship sp
    JOIN Club c ON c.club_id = sp.club_id
    WHERE sp.sponsor_id = s.sponsor_id
    AND NOT EXISTS (
        SELECT 1
        FROM Athlete a
        JOIN Rank r ON r.athlete_id = a.athlete_id
        JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
        WHERE a.club_id = c.club_id
        AND NOT EXISTS (
            SELECT 1 FROM Rank_title rt2
            WHERE rt2.previous_rank_id = rt.rank_title_id
        )
    )
);

альтернативный вариант
через COUNT и сравнение количества клубов

SELECT s.*
FROM Sponsor s
JOIN Sponsorship sp ON sp.sponsor_id = s.sponsor_id
JOIN Club c ON c.club_id = sp.club_id
GROUP BY s.sponsor_id
HAVING COUNT(DISTINCT c.club_id) > 1
   AND COUNT(DISTINCT CASE 
       WHEN EXISTS (
           SELECT 1 FROM Athlete a
           JOIN Rank r ON r.athlete_id = a.athlete_id
           JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
           WHERE a.club_id = c.club_id
           AND NOT EXISTS (
               SELECT 1 FROM Rank_title rt2
               WHERE rt2.previous_rank_id = rt.rank_title_id
           )
       ) THEN c.club_id 
   END) = COUNT(DISTINCT c.club_id);

третий альтернативный вариант
WITH ClubsWithTopRank AS (
    SELECT DISTINCT a.club_id
    FROM Athlete a
    JOIN Rank r ON r.athlete_id = a.athlete_id
    JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM Rank_title rt2
        WHERE rt2.previous_rank_id = rt.rank_title_id
    )
)

SELECT s.*
FROM Sponsor s
JOIN Sponsorship sp ON sp.sponsor_id = s.sponsor_id
GROUP BY s.sponsor_id
HAVING COUNT(DISTINCT sp.club_id) > 1
AND COUNT(DISTINCT sp.club_id) =
    COUNT(DISTINCT CASE
        WHEN sp.club_id IN (SELECT club_id FROM ClubsWithTopRank)
        THEN sp.club_id
    END);
41. Выбрать id и фамилию и инициалы спортсменов, название разряда на начало прошлого года.
на 01.01
можно попробовать через оконки, выбрать первое или через максимум по разрядам
SELECT 
    a.athlete_id,
    a.last_name || ' ' || LEFT(a.first_name, 1) || '.' AS fio,
    r.assignment_date,
    rt.rank_title
FROM Athlete a
JOIN Rank r ON r.athlete_id = a.athlete_id
JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
WHERE EXTRACT(YEAR FROM r.assignment_date) = 2024
ORDER BY a.athlete_id, r.assignment_date DESC;

альтернативный вариант
через  >= < самый результативный, если есть индекс по дате присвоения

SELECT 
    a.athlete_id,
    a.last_name || ' ' || LEFT(a.first_name, 1) || '.' AS fio,
    r.assignment_date,
    rt.rank_title
FROM Athlete a
JOIN Rank r ON r.athlete_id = a.athlete_id
JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
WHERE r.assignment_date >= '2024-01-01' 
  AND r.assignment_date < '2025-01-01'
ORDER BY a.athlete_id, r.assignment_date DESC;

третий альтернативный вариант
SELECT
    athlete_id,
    fio,
    assignment_date,
    rank_title
FROM (
    SELECT 
        a.athlete_id,
        a.last_name || ' ' || LEFT(a.first_name,1) || '.' AS fio,
        r.assignment_date,
        rt.rank_title,
        ROW_NUMBER() OVER (
            PARTITION BY a.athlete_id
            ORDER BY r.assignment_date DESC
        ) AS rn
    FROM Athlete a
    JOIN Rank r ON r.athlete_id = a.athlete_id
    JOIN Rank_title rt ON rt.rank_title_id = r.rank_title_id
    WHERE EXTRACT(YEAR FROM r.assignment_date) = 2024
) t
WHERE rn = 1
ORDER BY athlete_id;

42. Выбрать фамилию и инициалы спонсоров, спортсменов и
работников. В результирующей таблице должно быть два столбца:
первый – с фамилией и инициалами, а во втором необходимо указать, 
кем является соответствующий человек (спонсором, владельцем, работником).
Результат отсортировать по фамилии в
лексикографическом порядке.

SELECT last_name || ' ' || LEFT(first_name,1) || '.' AS fio, 'Спортсмен'
FROM Athlete
UNION ALL
SELECT last_name || ' ' || LEFT(first_name,1) || '.', 'Спонсор'
FROM sponsor_person
UNION ALL
SELECT last_name || ' ' || LEFT(first_name,1) || '.', 'Работник'
FROM Employee
ORDER BY fio;

альтернативный вариант

SELECT 
    t.last_name || ' ' || LEFT(t.first_name, 1) || '.' AS fio,
    t.type
FROM (
    SELECT last_name, first_name, 'Спортсмен' AS type FROM Athlete
    UNION ALL
    SELECT last_name, first_name, 'Спонсор' FROM sponsor_person
    UNION ALL
    SELECT last_name, first_name, 'Работник' FROM Employee
) t
ORDER BY fio;

43. Выбрать общее количество всех однофамильцев.

SELECT SUM(cnt - 1) AS total_same_lastnames
FROM (
    SELECT last_name, COUNT(*) AS cnt
    FROM Athlete
    GROUP BY last_name
    HAVING COUNT(*) > 1
) t;

альтернативный вариант
с использованием оконных функций
SELECT SUM(COUNT(*) - 1) OVER () AS total_same_lastnames
FROM Athlete
GROUP BY last_name
HAVING COUNT(*) > 1
LIMIT 1;

44. Вывести сообщение, кого больше среди спортсменов
мужчин или женщин.

SELECT CASE 
    WHEN male_cnt > female_cnt THEN 'Больше мужчин'
    WHEN female_cnt > male_cnt THEN 'Больше женщин'
    ELSE 'Поровну'
END
FROM (
    SELECT 
        COUNT(*) FILTER (WHERE gender = 'male') AS male_cnt,
        COUNT(*) FILTER (WHERE gender = 'female') AS female_cnt
    FROM Athlete
) t;

альтернативный вариант
с использованием SIGN
SELECT CASE SIGN(SUM(CASE WHEN gender = 'male' THEN 1 ELSE -1 END))
    WHEN 1 THEN 'Больше мужчин'
    WHEN -1 THEN 'Больше женщин'
    ELSE 'Поровну'
END
FROM Athlete;

45. Выбрать фамилии, имена, отчества трех самых высоких
спортсменов.

SELECT last_name, first_name, middle_name
FROM Athlete
ORDER BY height DESC
LIMIT 3;

альтернативный вариант
с использованием оконной функции ROW_NUMBER
SELECT last_name, first_name, middle_name
FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY height DESC) AS rn
    FROM Athlete
) t
WHERE rn <= 3;

46. Выбрать всю иерархию разрядов.

WITH RECURSIVE r AS (
    SELECT rank_title_id, rank_title, previous_rank_id, 1 AS lvl
    FROM Rank_title
    WHERE previous_rank_id IS NULL

    UNION ALL

    SELECT rt.rank_title_id, rt.rank_title, rt.previous_rank_id, r.lvl + 1
    FROM Rank_title rt
    JOIN r ON rt.previous_rank_id = r.rank_title_id
)
SELECT * FROM r;


47. Выбрать фамилию, имя, отчество спортсмена и названия
его первой и последней награды.

SELECT DISTINCT
    a.last_name,
    a.first_name,
    a.middle_name,
    FIRST_VALUE(aw.award_date) OVER (
        PARTITION BY a.athlete_id 
        ORDER BY aw.award_date
    ) AS first_award_date,
    FIRST_VALUE(at.award_name) OVER (
        PARTITION BY a.athlete_id 
        ORDER BY aw.award_date DESC
    ) AS last_award_name
FROM Athlete a
JOIN Award aw ON aw.athlete_id = a.athlete_id
JOIN Award_type at ON at.award_type_id = aw.award_type_id;

альтернативный вариант с лимит

SELECT 
    a.last_name,
    a.first_name,
    a.middle_name,
    (
        SELECT at.award_name
        FROM Award aw
        JOIN Award_type at ON at.award_type_id = aw.award_type_id
        WHERE aw.athlete_id = a.athlete_id
        ORDER BY aw.award_date
        LIMIT 1
    ) AS first_award,
    (
        SELECT at.award_name
        FROM Award aw
        JOIN Award_type at ON at.award_type_id = aw.award_type_id
        WHERE aw.athlete_id = a.athlete_id
        ORDER BY aw.award_date DESC
        LIMIT 1
    ) AS last_award
FROM Athlete a
WHERE EXISTS (SELECT 1 FROM Award WHERE athlete_id = a.athlete_id)
ORDER BY a.last_name, a.first_name;

48. Выбрать спортсмена, который «перепрыгнул» через разряд, т. е. нарушил правильную иерархию разрядов.
взять на планы
SELECT DISTINCT a.*
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

альтернативный варик

WITH RECURSIVE rank_chain AS (
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

49. Выбрать название клуба, количество спортсменов, количество соревнований,
в которых клуб принимал участие, общее
количество соревнований, процент участия в соревнованиях.

SELECT c.name,
       COUNT(DISTINCT a.athlete_id) AS athletes,
       COUNT(DISTINCT m.match_id) AS matches,
       (SELECT COUNT(*) FROM Match) AS total_matches,
       COUNT(DISTINCT m.match_id) * 100.0 / (SELECT COUNT(*) FROM Match) AS percent
FROM Club c
LEFT JOIN Athlete a ON a.club_id = c.club_id
LEFT JOIN Match m ON m.club1_id = c.club_id OR m.club2_id = c.club_id
GROUP BY c.club_id;

альтернативный вариант
подцепить оконки

WITH club_stats_base AS (
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

50. Выбрать все данные соревнования, в котором приняли
участие все клубы.

SELECT t.*
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

альтернативный вариант
через сравнение количества клубов

SELECT t.*
FROM Tournament t
JOIN Match m ON m.tournament_id = t.tournament_id
GROUP BY t.tournament_id
HAVING COUNT(DISTINCT 
    CASE WHEN m.club1_id IS NOT NULL THEN m.club1_id 
         WHEN m.club2_id IS NOT NULL THEN m.club2_id 
    END
) = (SELECT COUNT(*) FROM Club);

51. Выбрать все данные соревнования, в котором приняло
участие наибольшее количество клубов. 
надо чтобы лимит выводил все соревнования а не срезал
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

альтернативный вариант
с использованием оконной функции
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
