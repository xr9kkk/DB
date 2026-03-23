TRUNCATE Tournament CASCADE;
TRUNCATE Match CASCADE;
TRUNCATE Award CASCADE;
TRUNCATE Rank CASCADE;
TRUNCATE Employee CASCADE;
TRUNCATE Sponsorship CASCADE;
TRUNCATE Club_Owner CASCADE;
TRUNCATE sponsor_org CASCADE;
TRUNCATE sponsor_person CASCADE;
TRUNCATE Sponsor CASCADE;
TRUNCATE Athlete CASCADE;
TRUNCATE Owner CASCADE;
TRUNCATE Club CASCADE;
TRUNCATE City CASCADE;
TRUNCATE Region CASCADE;
TRUNCATE Country CASCADE;
TRUNCATE Position CASCADE;
TRUNCATE Award_type CASCADE;
TRUNCATE Rank_title CASCADE;
TRUNCATE GamePosition CASCADE;

-- Country
INSERT INTO Country (name) VALUES 
('Russia'),
('USA'),
('Germany'),
('France'),
('Japan'),
('Brazil'),
('China'),
('United Kingdom')
ON CONFLICT(name) DO NOTHING;

-- GamePosition
INSERT INTO GamePosition (position_name) VALUES
('Вратарь'),
('Защитник'),
('Полузащитник'),
('Нападающий'),
('Центральный нападающий'),
('Крайний защитник');

-- Region
INSERT INTO Region (name, country_id) VALUES 
('Moscow Oblast', (SELECT country_id FROM Country WHERE name = 'Russia')),
('California', (SELECT country_id FROM Country WHERE name = 'USA')),
('Bavaria', (SELECT country_id FROM Country WHERE name = 'Germany')),
('Ile-de-France', (SELECT country_id FROM Country WHERE name = 'France')),
('Kanto', (SELECT country_id FROM Country WHERE name = 'Japan')),
('São Paulo', (SELECT country_id FROM Country WHERE name = 'Brazil')),
('Beijing', (SELECT country_id FROM Country WHERE name = 'China')),
('England', (SELECT country_id FROM Country WHERE name = 'United Kingdom')),
('Texas', (SELECT country_id FROM Country WHERE name = 'USA')),
('Sverdlovsk Oblast', (SELECT country_id FROM Country WHERE name = 'Russia'))
ON CONFLICT(name, country_id) DO NOTHING;

-- City
INSERT INTO City (name, region_id) VALUES 
('Moscow', (SELECT region_id FROM Region WHERE name = 'Moscow Oblast')),
('Los Angeles', (SELECT region_id FROM Region WHERE name = 'California')),
('Munich', (SELECT region_id FROM Region WHERE name = 'Bavaria')),
('Paris', (SELECT region_id FROM Region WHERE name = 'Ile-de-France')),
('Tokyo', (SELECT region_id FROM Region WHERE name = 'Kanto')),
('São Paulo City', (SELECT region_id FROM Region WHERE name = 'São Paulo')),
('Beijing City', (SELECT region_id FROM Region WHERE name = 'Beijing')),
('London', (SELECT region_id FROM Region WHERE name = 'England')),
('Houston', (SELECT region_id FROM Region WHERE name = 'Texas')),
('Yekaterinburg', (SELECT region_id FROM Region WHERE name = 'Sverdlovsk Oblast')),
('Krasnodar', (SELECT region_id FROM Region WHERE name = 'Moscow Oblast')),
('Mos_cow', (SELECT region_id FROM Region WHERE name = 'Moscow Oblast')),
('New?York', (SELECT region_id FROM Region WHERE name = 'California')),
('Los*Angeles', (SELECT region_id FROM Region WHERE name = 'California')),
('San&Francisco', (SELECT region_id FROM Region WHERE name = 'California')),
('Test_?City*&', (SELECT region_id FROM Region WHERE name = 'Test Region')),
('NormalCity', (SELECT region_id FROM Region WHERE name = 'Test Region')),
('AnotherNormal', (SELECT region_id FROM Region WHERE name = 'Moscow Oblast'))
ON CONFLICT(name, region_id) DO NOTHING;

-- Club
INSERT INTO Club (name, city_id, foundation_date) VALUES 
('Spartak', (SELECT city_id FROM City WHERE name = 'Moscow'), '1990-05-01'),
('CSKA', (SELECT city_id FROM City WHERE name = 'Moscow'), '1985-03-15'),
('Lakers', (SELECT city_id FROM City WHERE name = 'Los Angeles'), '1995-08-20'),
('Bayern', (SELECT city_id FROM City WHERE name = 'Munich'), '1988-11-10'),
('PSG', (SELECT city_id FROM City WHERE name = 'Paris'), '1970-08-12'),
('Tokyo Giants', (SELECT city_id FROM City WHERE name = 'Tokyo'), '1995-04-05'),
('São Paulo FC', (SELECT city_id FROM City WHERE name = 'São Paulo City'), '1980-01-30'),
('London Royals', (SELECT city_id FROM City WHERE name = 'London'), '2000-07-15'),
('Houston Rockets', (SELECT city_id FROM City WHERE name = 'Houston'), '1992-11-25'),
('Dynamo', (SELECT city_id FROM City WHERE name = 'Moscow'), '1987-09-03'),
('Ural', (SELECT city_id FROM City WHERE name = 'Yekaterinburg'), '1998-06-20'),
('Krasnodar FC', (SELECT city_id FROM City WHERE name = 'Krasnodar'), '2005-03-10'),
('Club_Underscore', (SELECT city_id FROM City WHERE name = 'Mos_cow'), '2000-01-01'),
('Club_Question', (SELECT city_id FROM City WHERE name = 'New?York'), '2001-02-02'),
('Club_Star', (SELECT city_id FROM City WHERE name = 'Los*Angeles'), '2002-03-03'),
('Club_Ampersand', (SELECT city_id FROM City WHERE name = 'San&Francisco'), '2003-04-04'),
('Club_AllSymbols', (SELECT city_id FROM City WHERE name = 'Test_?City*&'), '2004-05-05'),
('Club_Normal', (SELECT city_id FROM City WHERE name = 'NormalCity'), '2005-06-06')
ON CONFLICT(name, city_id) DO NOTHING;

-- Создание клуба без спортсменов
INSERT INTO Club (name, city_id, foundation_date) VALUES 
('Empty Club', (SELECT city_id FROM City WHERE name = 'Moscow'), '2020-01-01'),
('No Athletes FC', (SELECT city_id FROM City WHERE name = 'Berlin'), '2019-03-15'),
('Solo Club', (SELECT city_id FROM City WHERE name = 'Tokyo'), '2021-07-20'),
('Test Team', (SELECT city_id FROM City WHERE name = 'London'), '2022-11-10'),
('Vacant VC', (SELECT city_id FROM City WHERE name = 'Paris'), '2023-05-05')
ON CONFLICT(name, city_id) DO NOTHING;

-- Owner
INSERT INTO Owner (last_name, first_name, middle_name, phone, gender, city_id) VALUES 
('Ivanov', 'Alexey', 'Petrovich', '+79161234567', 'male', (SELECT city_id FROM City WHERE name = 'Moscow')),
('Smith', 'John', NULL, '+13105551234', 'male', (SELECT city_id FROM City WHERE name = 'Los Angeles')),
('Müller', 'Hans', 'Friedrich', '+49891234567', 'male', (SELECT city_id FROM City WHERE name = 'Munich')),
('Dubois', 'Pierre', 'Jean', '+33123456789', 'male', (SELECT city_id FROM City WHERE name = 'Paris')),
('Tanaka', 'Kenji', NULL, '+81345678901', 'male', (SELECT city_id FROM City WHERE name = 'Tokyo')),
('Silva', 'Carlos', 'Alberto', '+5511987654321', 'male', (SELECT city_id FROM City WHERE name = 'São Paulo City')),
('Wilson', 'Emma', NULL, '+442012345678', 'female', (SELECT city_id FROM City WHERE name = 'London')),
('Petrova', 'Elena', 'Ivanovna', '+79159876543', 'female', (SELECT city_id FROM City WHERE name = 'Moscow')),
('Zhang', 'Wei', NULL, '+861012345678', 'male', (SELECT city_id FROM City WHERE name = 'Beijing City'))
ON CONFLICT(phone) DO NOTHING;

-- Club_Owner
INSERT INTO Club_Owner (club_id, owner_id, ownership_share) VALUES 
((SELECT club_id FROM Club WHERE name = 'Spartak'), (SELECT owner_id FROM Owner WHERE last_name = 'Ivanov'), 60.0),
((SELECT club_id FROM Club WHERE name = 'Lakers'), (SELECT owner_id FROM Owner WHERE last_name = 'Smith'), 100.0),
((SELECT club_id FROM Club WHERE name = 'PSG'), (SELECT owner_id FROM Owner WHERE last_name = 'Dubois'), 45.5),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), (SELECT owner_id FROM Owner WHERE last_name = 'Tanaka'), 100.0),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), (SELECT owner_id FROM Owner WHERE last_name = 'Petrova'), 75.0),
((SELECT club_id FROM Club WHERE name = 'London Royals'), (SELECT owner_id FROM Owner WHERE last_name = 'Wilson'), 60.0),
((SELECT club_id FROM Club WHERE name = 'São Paulo FC'), (SELECT owner_id FROM Owner WHERE last_name = 'Silva'), 80.0),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT owner_id FROM Owner WHERE last_name = 'Petrova'), 25.0)
ON CONFLICT(club_id, owner_id) DO NOTHING;

-- Position
INSERT INTO Position (position_type) VALUES 
('Coach'),
('Manager'),
('Doctor'),
('Accountant'),
('Assistant Coach'),
('Physiotherapist'),
('Scout'),
('Security Officer'),
('Marketing Manager'),
('Nutritionist'),
('Psychologist'),
('Analyst'),
('Massage Therapist'),
('Goalkeeping Coach'),
('Fitness Coach'),
('Tactical Analyst'),
('Equipment Manager'),
('Video Analyst'),
('Youth Coach'),
('Interpreter'),
('Recruiter'),
('Data Scientist')
ON CONFLICT(position_type) DO NOTHING;

-- Award_type
INSERT INTO Award_type (award_name) VALUES 
('Gold Medal'),
('Silver Medal'),
('Bronze Medal'),
('Champion Cup'),
('Best Player Award'),
('Fair Play Award'),
('Top Scorer Cup'),
('Rookie of the Year'),
('Team Spirit Award'),
('Best Goalkeeper'),
('Most Valuable Player')
ON CONFLICT(award_name) DO NOTHING;

-- Rank_title
INSERT INTO Rank_title (rank_title, previous_rank_id) VALUES 
('Master of Sports', NULL),
('Candidate Master', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Master of Sports')),
('First Category', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Candidate Master')),
('International Master', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Master of Sports')),
('Grandmaster', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'International Master')),
('Second Category', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'First Category')),
('Third Category', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Second Category'))
ON CONFLICT(rank_title) DO NOTHING;

-- Sponsor
INSERT INTO Sponsor (sponsor_type, registration_date, contact_phone) VALUES 
('org', '2020-01-15', '+74951234567'),
('person', '2021-03-20', '+79167654321'),
('org', '2019-11-10', '+13105559876'),
('org', '2018-05-20', '+33143219876'),
('person', '2022-08-14', '+81398765432'),
('org', '2017-12-01', '+442076543210'),
('org', '2020-09-25', '+74957654321'),
('person', '2023-02-28', '+79151112233'),
('org', '2019-06-15', '+861087654321'),
('person', CURRENT_DATE - INTERVAL '15 days', '+44201112233'),
('person', CURRENT_DATE - INTERVAL '75 days', '+33198765499'),
('person', CURRENT_DATE - INTERVAL '120 days', '+55119887766'),
('person', CURRENT_DATE - INTERVAL '180 days', '+13105559900');

-- sponsor_org
INSERT INTO sponsor_org (sponsor_id, inn, org_name, phone) VALUES 
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+74951234567'), '7701123456', 'Gazprom', 7495123456),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+13105559876'), '123456789', 'Nike', 1310555987),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+33143219876'), 'FR123456789', 'Air France', 3314321987),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+442076543210'), 'GB987654321', 'Barclays', 4420765432),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+74957654321'), '7701987654', 'Lukoil', 7495765432),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+861087654321'), 'CN112233445', 'Huawei', 8610876543)
ON CONFLICT(sponsor_id) DO NOTHING;

-- sponsor_person
INSERT INTO sponsor_person (sponsor_id, last_name, first_name, middle_name) VALUES 
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+79167654321'), 'Petrov', 'Sergey', 'Viktorovich'),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+81398765432'), 'Yamamoto', 'Takeshi', NULL),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+79151112233'), 'Sokolov', 'Dmitry', 'Alexandrovich'),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+44201112233'), 'Wilson', 'Robert', NULL),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+33198765499'), 'Martin', 'Pierre', 'Jacques'),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+55119887766'), 'Silva', 'Antonio', 'Carlos'),
((SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+13105559900'), 'Brown', 'James', 'William')
ON CONFLICT(sponsor_id) DO NOTHING;

-- Sponsorship
INSERT INTO Sponsorship (club_id, sponsor_id, donation_date, donation_amount, purpose) VALUES 
((SELECT club_id FROM Club WHERE name = 'Spartak'), (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+74951234567'), '2024-01-10', 500000.00, 'Equipment'),
((SELECT club_id FROM Club WHERE name = 'Lakers'), (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+13105559876'), '2024-02-15', 750000.00, 'Training'),
((SELECT club_id FROM Club WHERE name = 'PSG'), (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+33143219876'), '2024-03-01', 1000000.00, 'Infrastructure'),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+81398765432'), '2024-02-28', 300000.00, 'Youth Program'),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+74957654321'), '2024-03-05', 600000.00, 'Equipment'),
((SELECT club_id FROM Club WHERE name = 'London Royals'), (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+442076543210'), '2024-01-20', 900000.00, 'Training Facilities'),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+74957654321'), '2024-02-10', 400000.00, 'Medical Supplies'),
((SELECT club_id FROM Club WHERE name = 'Bayern'), (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+861087654321'), '2024-03-12', 550000.00, 'Technology');


-- Sponsorship 
INSERT INTO Sponsorship (club_id, sponsor_id, donation_date, donation_amount, purpose) VALUES 
-- Январь 2025
((SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+74951234567'), 
 '2025-01-10', 550000.00, 'Winter Equipment'),

((SELECT club_id FROM Club WHERE name = 'Lakers'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+13105559876'), 
 '2025-01-15', 800000.00, 'New Year Tournament'),

-- Февраль 2025
((SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+79167654321'), 
 '2025-02-05', 450000.00, 'Training Camp'),

((SELECT club_id FROM Club WHERE name = 'Bayern'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+33198765499'), 
 '2025-02-14', 350000.00, 'Youth Program'),

-- Март 2025
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+74951234567'), 
 '2025-03-10', 600000.00, 'Spring Equipment'),

((SELECT club_id FROM Club WHERE name = 'London Royals'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+442076543210'), 
 '2025-03-20', 950000.00, 'Facility Upgrade'),

-- Апрель 2025
((SELECT club_id FROM Club WHERE name = 'PSG'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+33143219876'), 
 '2025-04-05', 1200000.00, 'Major Renovation'),

-- Май 2025 (крупнейшие пожертвования)
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+81398765432'), 
 '2025-05-01', 500000.00, 'Anniversary Event'),

((SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+74957654321'), 
 '2025-05-15', 700000.00, 'Championship Preparation'),

-- Июнь 2025
((SELECT club_id FROM Club WHERE name = 'Lakers'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+13105559876'), 
 '2025-06-10', 850000.00, 'Summer Training'),

-- Июль 2025
((SELECT club_id FROM Club WHERE name = 'Bayern'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+861087654321'), 
 '2025-07-22', 650000.00, 'Technology Upgrade'),

-- Август 2025
((SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+79151112233'), 
 '2025-08-30', 300000.00, 'Medical Equipment'),

-- Сентябрь 2025 (самое крупное пожертвование - для теста LIMIT 1)
((SELECT club_id FROM Club WHERE name = 'London Royals'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+44201112233'), 
 '2025-09-18', 1500000.00, 'Stadium Construction'),

-- Октябрь 2025
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+33143219876'), 
 '2025-10-05', 550000.00, 'Autumn Tournament'),

-- Ноябрь 2025
((SELECT club_id FROM Club WHERE name = 'PSG'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+55119887766'), 
 '2025-11-20', 480000.00, 'Community Program'),

-- Декабрь 2025
((SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT sponsor_id FROM Sponsor WHERE contact_phone = '+13105559900'), 
 '2025-12-15', 420000.00, 'Year-End Support');
-- Employee
INSERT INTO Employee (club_id, last_name, first_name, middle_name, gender, phone, salary, position_id) VALUES 
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Sidorov', 'Andrey', 'Nikolaevich', 'male', '+79161112233', 80000.00, (SELECT position_id FROM Position WHERE position_type = 'Coach')),
((SELECT club_id FROM Club WHERE name = 'Lakers'), 'Johnson', 'Mike', NULL, 'male', '+13104445566', 120000.00, (SELECT position_id FROM Position WHERE position_type = 'Manager')),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Ivanov', 'Andrey', 'Viktorovich', 'male', '+79165554433', 60000.00, (SELECT position_id FROM Position WHERE position_type = 'Coach')),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Petrova', 'Elena', 'Ivanovna', 'female', '+79167778899', 55000.00, (SELECT position_id FROM Position WHERE position_type = 'Doctor')),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Sokolov', 'Dmitry', NULL, 'male', '+79168889900', 50000.00, (SELECT position_id FROM Position WHERE position_type = 'Assistant Coach')),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Müller', 'Hans', NULL, 'male', '+49891234567', 80000.00, (SELECT position_id FROM Position WHERE position_type = 'Coach')),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Schneider', 'Anna', NULL, 'female', '+49892345678', 70000.00, (SELECT position_id FROM Position WHERE position_type = 'Nutritionist')),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Fischer', 'Thomas', NULL, 'male', '+49893456789', 65000.00, (SELECT position_id FROM Position WHERE position_type = 'Scout')),
((SELECT club_id FROM Club WHERE name = 'PSG'), 'Dubois', 'Pierre', NULL, 'male', '+33123456789', 90000.00, (SELECT position_id FROM Position WHERE position_type = 'Coach')),
((SELECT club_id FROM Club WHERE name = 'PSG'), 'Moreau', 'Sophie', NULL, 'female', '+33134567890', 75000.00, (SELECT position_id FROM Position WHERE position_type = 'Psychologist')),
((SELECT club_id FROM Club WHERE name = 'PSG'), 'Lefevre', 'Antoine', NULL, 'male', '+33145678901', 85000.00, (SELECT position_id FROM Position WHERE position_type = 'Analyst')),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 'Tanaka', 'Kenji', NULL, 'male', '+81323456789', 70000.00, (SELECT position_id FROM Position WHERE position_type = 'Coach')),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 'Yamamoto', 'Aiko', NULL, 'female', '+81334567890', 60000.00, (SELECT position_id FROM Position WHERE position_type = 'Physiotherapist')),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 'Kobayashi', 'Hiroshi', NULL, 'male', '+81345678901', 55000.00, (SELECT position_id FROM Position WHERE position_type = 'Massage Therapist')),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 'Kuznetsov', 'Alexey', 'Vladimirovich', 'male', '+79164445566', 65000.00, (SELECT position_id FROM Position WHERE position_type = 'Coach')),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 'Smirnova', 'Olga', 'Petrovna', 'female', '+79165556677', 58000.00, (SELECT position_id FROM Position WHERE position_type = 'Assistant Coach')),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 'Vasiliev', 'Mikhail', NULL, 'male', '+79166667788', 62000.00, (SELECT position_id FROM Position WHERE position_type = 'Goalkeeping Coach')),
((SELECT club_id FROM Club WHERE name = 'London Royals'), 'Brown', 'Robert', NULL, 'male', '+447922334455', 88000.00, (SELECT position_id FROM Position WHERE position_type = 'Coach')),
((SELECT club_id FROM Club WHERE name = 'London Royals'), 'Wilson', 'Sarah', NULL, 'female', '+447933445566', 72000.00, (SELECT position_id FROM Position WHERE position_type = 'Fitness Coach')),
((SELECT club_id FROM Club WHERE name = 'London Royals'), 'Davies', 'Michael', NULL, 'male', '+447944556677', 78000.00, (SELECT position_id FROM Position WHERE position_type = 'Tactical Analyst')),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Nikolaev', 'Victor', 'Sergeevich', 'male', '+79169990011', 45000.00, (SELECT position_id FROM Position WHERE position_type = 'Equipment Manager')),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Weber', 'Markus', NULL, 'male', '+49894567890', 60000.00, (SELECT position_id FROM Position WHERE position_type = 'Video Analyst')),
((SELECT club_id FROM Club WHERE name = 'PSG'), 'Garcia', 'Carlos', NULL, 'male', '+33156789012', 70000.00, (SELECT position_id FROM Position WHERE position_type = 'Youth Coach')),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 'Suzuki', 'Yuto', NULL, 'male', '+81356789012', 50000.00, (SELECT position_id FROM Position WHERE position_type = 'Interpreter')),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 'Fedorov', 'Pavel', 'Andreevich', 'male', '+79167778899', 52000.00, (SELECT position_id FROM Position WHERE position_type = 'Recruiter')),
((SELECT club_id FROM Club WHERE name = 'London Royals'), 'Clark', 'David', NULL, 'male', '+447955667788', 68000.00, (SELECT position_id FROM Position WHERE position_type = 'Data Scientist')),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Volkov', 'Sergey', 'Petrovich', 'male', '+79162223344', 75000.00, (SELECT position_id FROM Position WHERE position_type = 'Coach')),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Schmidt', 'Klaus', NULL, 'male', '+49899876543', 95000.00, (SELECT position_id FROM Position WHERE position_type = 'Physiotherapist')),
((SELECT club_id FROM Club WHERE name = 'PSG'), 'Martin', 'Luc', NULL, 'male', '+33198765432', 110000.00, (SELECT position_id FROM Position WHERE position_type = 'Manager')),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 'Sato', 'Yuki', NULL, 'female', '+81312345678', 65000.00, (SELECT position_id FROM Position WHERE position_type = 'Assistant Coach')),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 'Orlova', 'Maria', 'Sergeevna', 'female', '+79163334455', 70000.00, (SELECT position_id FROM Position WHERE position_type = 'Doctor')),
((SELECT club_id FROM Club WHERE name = 'London Royals'), 'Taylor', 'James', NULL, 'male', '+447911123456', 85000.00, (SELECT position_id FROM Position WHERE position_type = 'Scout'))
ON CONFLICT(phone) DO NOTHING;

-- Athlete (без game_position_id сначала)
INSERT INTO Athlete (club_id, last_name, first_name, middle_name, gender, birth_date, phone, height, weight) VALUES 
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Kozlov', 'Ivan', 'Sergeevich', 'male', '2000-03-15', '+79162345678', 185.5, 78.2),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Moroz', 'Anna', 'Viktorovna', 'female', '2001-07-22', '+79163456789', 170.2, 60.1),
((SELECT club_id FROM Club WHERE name = 'Lakers'), 'Brown', 'Chris', NULL, 'male', '1999-11-30', '+13106667788', 190.0, 85.5),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Kov', 'Alex', 'Petrovich', 'male', '2002-05-10', '+79164567890', 182.0, 75.0),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Mir', 'Dmitry', 'Ivanovich', 'male', '2003-09-18', '+79165678901', 178.5, 72.3),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Kozl', 'Ivan', 'Sergeevich', 'male', '2010-03-15', '+7916234278', 185.5, 78.2),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Morz', 'Pavel', 'viktorovich', 'male', '2002-03-21', '+79202125518', 171.2, 62.1),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Serikova', 'Valeria', 'Valeriovna', 'female', '2005-03-21', '+79222125518', 141.2, 61.1),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Volkov', 'Alexey', 'Dmitrievich', 'male', '1998-11-12', '+79167778899', 188.0, 82.5),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Schneider', 'Thomas', NULL, 'male', '1997-04-25', '+49891234567', 192.0, 88.0),
((SELECT club_id FROM Club WHERE name = 'PSG'), 'Leroy', 'Sophie', NULL, 'female', '2000-08-17', '+33123456789', 175.5, 65.2),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 'Nakamura', 'Hiroshi', NULL, 'male', '2002-01-30', '+81398765432', 180.0, 76.8),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 'Smirnova', 'Olga', 'Andreevna', 'female', '1999-06-14', '+79164445566', 172.3, 61.7),
((SELECT club_id FROM Club WHERE name = 'London Royals'), 'Brown', 'Sarah', NULL, 'female', '2001-12-05', '+447700123456', 168.9, 59.3),
((SELECT club_id FROM Club WHERE name = 'São Paulo FC'), 'Santos', 'Rafael', 'Fernando', 'male', '2003-03-22', '+5511998887777', 185.7, 79.4),
((SELECT club_id FROM Club WHERE name = 'Ural'), 'Popov', 'Igor', 'Vladimirovich', 'male', '2004-07-08', '+79165556677', 183.2, 77.1),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Ivanov-Petrov', 'Andrey', 'Sergeevich', 'male', '2001-04-15', '+79161234511', 182.3, 75.5),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Smirnova-Kuznetsova', 'Elena', 'Alexandrovna', 'female', '2000-09-22', '+79162345622', 168.7, 58.2),
((SELECT club_id FROM Club WHERE name = 'Lakers'), 'Johnson-Smith', 'Michael', 'James', 'male', '1998-10-30', '+13105551211', 195.0, 90.3),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Müller-Schmidt', 'Anna', 'Maria', 'female', '2002-05-10', '+49891234511', 175.5, 62.8),
((SELECT club_id FROM Club WHERE name = 'PSG'), 'Dubois-Martin', 'Pierre', 'Jean', 'male', '1999-11-12', '+33123456711', 185.0, 78.4),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 'Tanaka-Yamamoto', 'Yuki', NULL, 'female', '2003-03-25', '+81398765411', 170.2, 59.1),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 'Popova-Sidorova', 'Maria', 'Viktorovna', 'female', '2001-04-18', '+79163334411', 172.0, 61.5),
((SELECT club_id FROM Club WHERE name = 'London Royals'), 'Taylor-Brown', 'Emma', 'Rose', 'female', '2000-10-05', '+44770012311', 169.3, 60.2),
((SELECT club_id FROM Club WHERE name = 'São Paulo FC'), 'Silva-Santos', 'Carlos', 'Fernando', 'male', '1997-05-20', '+55119988811', 188.5, 83.7),
((SELECT club_id FROM Club WHERE name = 'Ural'), 'Kozlov-Volkov', 'Dmitry', 'Ivanovich', 'male', '2004-09-15', '+79165556611', 184.0, 79.2),
((SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), 'Morozova-Orlova', 'Olga', 'Sergeevna', 'female', '2002-11-28', '+79167778811', 167.8, 57.9),
((SELECT club_id FROM Club WHERE name = 'Houston Rockets'), 'Davis-Wilson', 'Chris', 'Lee', 'male', '1999-04-03', '+17135551211', 192.5, 88.6),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Schneider-Hoffmann', 'Klaus', 'Peter', 'male', '1996-10-18', '+49899876511', 190.2, 86.4),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Petrov-Smirnov', 'Alexey', 'Dmitrievich', 'male', '2003-05-12', '+79168889911', 180.7, 73.8),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Kuznetsov-Ivanov', 'Sergey', 'Andreevich', 'male', '1998-09-08', '+79169990011', 186.3, 81.2),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Fedorov', 'Alexander', 'Viktorovich', 'male', '1998-05-20', '+79161111111', 185.5, 78.2),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Ivanova', 'Maria', 'Sergeevna', 'female', '2000-08-15', '+79162222222', 172.3, 60.5),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Sokolov', 'Pavel', 'Dmitrievich', 'male', '1999-03-10', '+79163333333', 188.0, 82.1),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Nikolaeva', 'Ekaterina', 'Andreevna', 'female', '2001-11-25', '+79164444444', 168.7, 58.3),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Orlov', 'Dmitry', 'Ivanovich', 'male', '1997-07-08', '+79165555555', 182.4, 76.8),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Voronov', 'Sergey', 'Petrovich', 'male', '2000-02-14', '+79166666666', 184.2, 79.5),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Petrov', 'Nikolay', 'Sergeevich', 'male', '2002-03-22', '+79162345602', 182.3, 76.2),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 'Yamamoto', 'Kenji', NULL, 'male', '2000-11-30', '+81398765003', 178.5, 70.8),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Yamamoto', 'Sakura', NULL, 'female', '2003-05-14', '+49891234004', 165.2, 56.7),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 'Sokolov', 'Alexander', 'Ivanovich', 'male', '1999-09-08', '+79163334005', 190.1, 84.3),
((SELECT club_id FROM Club WHERE name = 'Ural'), 'Sokolova', 'Natalia', 'Petrovna', 'female', '2004-02-19', '+79165556006', 172.8, 63.4),
((SELECT club_id FROM Club WHERE name = 'London Royals'), 'Wilson', 'David', NULL, 'male', '2001-04-10', '+44770012007', 183.7, 79.1),
((SELECT club_id FROM Club WHERE name = 'PSG'), 'Martin', 'Luc', NULL, 'male', '2002-08-25', '+33123456008', 179.2, 74.8),
((SELECT club_id FROM Club WHERE name = 'São Paulo FC'), 'Silva', 'Ricardo', 'Fernando', 'male', '2000-12-03', '+55119988009', 186.4, 81.5),
((SELECT club_id FROM Club WHERE name = 'Houston Rockets'), 'Brown', 'Matthew', NULL, 'male', '2003-06-18', '+17135552010', 191.0, 87.2),
((SELECT club_id FROM Club WHERE name = 'Club_Underscore'), 'Ivanov', 'Ivan', 'Ivanovich', 'male', '2000-01-15', '+79164111111', 185.5, 78.2),
((SELECT club_id FROM Club WHERE name = 'Club_Question'), 'Petrov', 'Petr', 'Petrovich', 'male', '2001-02-20', '+79162322222', 182.3, 75.8),
((SELECT club_id FROM Club WHERE name = 'Club_Star'), 'Sidorov', 'Sergey', 'Sergeevich', 'male', '2002-03-25', '+79163335333', 188.0, 82.1),
((SELECT club_id FROM Club WHERE name = 'Club_Ampersand'), 'Kuznetsova', 'Anna', 'Viktorovna', 'female', '2003-04-30', '+79124444444', 170.2, 60.5),
((SELECT club_id FROM Club WHERE name = 'Club_AllSymbols'), 'Smirnov', 'Alexey', 'Dmitrievich', 'male', '2004-05-05', '+79165155555', 184.7, 79.3),
((SELECT club_id FROM Club WHERE name = 'Club_Normal'), 'Normalov', 'Normal', 'Normalovich', 'male', '2005-06-10', '+79166666566', 180.0, 75.0)
ON CONFLICT(phone) DO NOTHING;

-- Теперь обновляем Athlete с game_position_id
UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Нападающий') 
WHERE last_name = 'Medvedev' AND first_name = 'Dmitry';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Защитник') 
WHERE last_name = 'Tarasova' AND first_name = 'Ekaterina';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Центральный нападающий') 
WHERE last_name = 'Williams' AND first_name = 'Robert';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Полузащитник') 
WHERE last_name = 'Schulz' AND first_name = 'Laura';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Вратарь') 
WHERE last_name = 'Bernard' AND first_name = 'Antoine';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Защитник') 
WHERE last_name = 'Suzuki' AND first_name = 'Haruto';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Нападающий') 
WHERE last_name = 'Romanov' AND first_name = 'Ivan';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Полузащитник') 
WHERE last_name = 'Cooper' AND first_name = 'Emily';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Крайний защитник') 
WHERE last_name = 'Rodrigues' AND first_name = 'Luis';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Нападающий') 
WHERE last_name = 'Vasiliev' AND first_name = 'Sergey';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Защитник') 
WHERE last_name = 'Klimova' AND first_name = 'Anna';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Центральный нападающий') 
WHERE last_name = 'Thompson' AND first_name = 'Kevin';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Полузащитник') 
WHERE last_name = 'Baranov' AND first_name = 'Pavel';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Защитник') 
WHERE last_name = 'Kuzmina' AND first_name = 'Svetlana';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Вратарь') 
WHERE last_name = 'Wagner' AND first_name = 'Stefan';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Полузащитник') 
WHERE last_name = 'Lemoine' AND first_name = 'Claire';

UPDATE Athlete SET game_position_id = (SELECT game_position_id FROM GamePosition WHERE position_name = 'Нападающий') 
WHERE last_name = 'Fedorov' AND first_name = 'Maxim';

-- Добавляем Athlete с game_position_id
INSERT INTO Athlete (club_id, last_name, first_name, middle_name, gender, birth_date, phone, height, weight, game_position_id) VALUES 
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Medvedev', 'Dmitry', 'Alexeevich', 'male', '1995-03-15', '+79161234595', 190.5, 85.2, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Нападающий')),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Tarasova', 'Ekaterina', 'Sergeevna', 'female', '1995-07-22', '+79162345695', 176.0, 62.5, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Защитник')),
((SELECT club_id FROM Club WHERE name = 'Lakers'), 'Williams', 'Robert', NULL, 'male', '1996-01-10', '+13105551996', 195.3, 92.0, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Центральный нападающий')),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Schulz', 'Laura', NULL, 'female', '1996-05-30', '+49891234996', 179.8, 68.7, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Полузащитник')),
((SELECT club_id FROM Club WHERE name = 'PSG'), 'Bernard', 'Antoine', NULL, 'male', '1997-09-18', '+33123456997', 185.0, 78.3, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Вратарь')),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 'Suzuki', 'Haruto', NULL, 'male', '1997-11-05', '+81398765997', 182.5, 75.8, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Защитник')),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 'Romanov', 'Ivan', 'Petrovich', 'male', '1998-04-12', '+79163334998', 188.2, 80.1, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Нападающий')),
((SELECT club_id FROM Club WHERE name = 'London Royals'), 'Cooper', 'Emily', NULL, 'female', '1998-08-25', '+44770012998', 172.4, 61.3, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Полузащитник')),
((SELECT club_id FROM Club WHERE name = 'São Paulo FC'), 'Rodrigues', 'Luis', 'Fernando', 'male', '1999-02-28', '+55119988999', 187.0, 81.5, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Крайний защитник')),
((SELECT club_id FROM Club WHERE name = 'Ural'), 'Vasiliev', 'Sergey', 'Andreevich', 'male', '1999-06-15', '+79165556999', 184.5, 77.9, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Нападающий')),
((SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), 'Klimova', 'Anna', 'Viktorovna', 'female', '2000-12-03', '+79167778000', 169.8, 59.7, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Защитник')),
((SELECT club_id FROM Club WHERE name = 'Houston Rockets'), 'Thompson', 'Kevin', NULL, 'male', '2000-10-20', '+17135552000', 193.5, 89.2, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Центральный нападающий')),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Baranov', 'Pavel', 'Nikolaevich', 'male', '1996-03-10', '+79161234696', 178.0, 72.5, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Полузащитник')),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Kuzmina', 'Svetlana', 'Dmitrievna', 'female', '1997-07-14', '+79162345797', 165.3, 55.8, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Защитник')),
((SELECT club_id FROM Club WHERE name = 'Bayern'), 'Wagner', 'Stefan', NULL, 'male', '1998-11-30', '+49891235998', 191.2, 86.4, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Вратарь')),
((SELECT club_id FROM Club WHERE name = 'PSG'), 'Lemoine', 'Claire', NULL, 'female', '1999-04-05', '+33123456999', 174.6, 64.2, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Полузащитник')),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), 'Fedorov', 'Maxim', 'Olegovich', 'male', '2000-01-15', '+79163335000', 186.7, 79.3, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Нападающий')),
((SELECT club_id FROM Club WHERE name = 'London Royals'), 'Baker', 'Thomas', NULL, 'male', '1995-12-20', '+44770012995', 181.0, 76.8, NULL),
((SELECT club_id FROM Club WHERE name = 'São Paulo FC'), 'Costa', 'Mariana', 'Silva', 'female', '1996-08-08', '+55119988996', 167.5, 58.9, NULL),
((SELECT club_id FROM Club WHERE name = 'Ural'), 'Orlov', 'Andrey', 'Vladimirovich', 'male', '1997-05-25', '+79165556997', 183.2, 78.1, NULL),
((SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), 'Zaitseva', 'Elena', 'Igorevna', 'female', '1998-09-14', '+79167778998', 171.0, 62.4, NULL),
((SELECT club_id FROM Club WHERE name = 'Houston Rockets'), 'Jackson', 'Marcus', NULL, 'male', '1999-03-03', '+17135552999', 189.5, 84.7, NULL),
((SELECT club_id FROM Club WHERE name = 'Spartak'), 'Petrov', 'Viktor', 'Alexeevich', 'male', '2001-07-15', '+79161234501', 185.0, 78.5, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Нападающий')),
((SELECT club_id FROM Club WHERE name = 'CSKA'), 'Petrov', 'Nikolay', 'Sergeevich', 'male', '2002-03-22', '+79162345602', 182.3, 76.2, (SELECT game_position_id FROM GamePosition WHERE position_name = 'Защитник'))
ON CONFLICT(phone) DO NOTHING;

-- Rank
INSERT INTO Rank (athlete_id, assignment_date, rank_title_id) VALUES 
((SELECT athlete_id FROM Athlete WHERE last_name = 'Kozlov' AND first_name = 'Ivan' AND birth_date = '2000-03-15'), '2022-06-10', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'First Category')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Kozlov' AND first_name = 'Ivan' AND birth_date = '2000-03-15'), '2023-11-20', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Candidate Master')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Moroz' AND first_name = 'Anna'), '2021-12-05', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'First Category')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Volkov' AND first_name = 'Alexey'), '2021-09-15', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Candidate Master')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Schneider'), '2020-12-10', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Grandmaster')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Leroy'), '2023-02-28', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'First Category')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Nakamura'), '2022-07-20', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Second Category')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Smirnova'), '2021-11-05', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Candidate Master')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Santos'), '2023-05-18', (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Third Category'))
ON CONFLICT(athlete_id, rank_title_id) DO NOTHING;

-- Award
INSERT INTO Award (athlete_id, award_date, award_type_id) VALUES 
((SELECT athlete_id FROM Athlete WHERE last_name = 'Kozlov' AND first_name = 'Ivan' AND birth_date = '2000-03-15'), '2023-05-15', (SELECT award_type_id FROM Award_type WHERE award_name = 'Gold Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Moroz' AND first_name = 'Anna'), '2023-05-15', (SELECT award_type_id FROM Award_type WHERE award_name = 'Silver Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Volkov' AND first_name = 'Alexey'), '2023-07-22', (SELECT award_type_id FROM Award_type WHERE award_name = 'Best Player Award')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Schneider'), '2022-11-30', (SELECT award_type_id FROM Award_type WHERE award_name = 'Gold Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Leroy'), '2023-09-14', (SELECT award_type_id FROM Award_type WHERE award_name = 'Silver Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Smirnova'), '2022-05-09', (SELECT award_type_id FROM Award_type WHERE award_name = 'Top Scorer Cup')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Brown' AND first_name = 'Sarah'), '2023-12-03', (SELECT award_type_id FROM Award_type WHERE award_name = 'Rookie of the Year')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Santos'), '2023-08-19', (SELECT award_type_id FROM Award_type WHERE award_name = 'Fair Play Award')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Fedorov' AND first_name = 'Alexander'), '2022-05-15', (SELECT award_type_id FROM Award_type WHERE award_name = 'Gold Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Fedorov' AND first_name = 'Alexander'), '2023-05-20', (SELECT award_type_id FROM Award_type WHERE award_name = 'Gold Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Fedorov' AND first_name = 'Alexander'), '2021-12-10', (SELECT award_type_id FROM Award_type WHERE award_name = 'Silver Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Ivanova' AND first_name = 'Maria'), '2021-06-18', (SELECT award_type_id FROM Award_type WHERE award_name = 'Silver Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Ivanova' AND first_name = 'Maria'), '2022-07-22', (SELECT award_type_id FROM Award_type WHERE award_name = 'Silver Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Ivanova' AND first_name = 'Maria'), '2023-08-30', (SELECT award_type_id FROM Award_type WHERE award_name = 'Silver Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Ivanova' AND first_name = 'Maria'), '2023-05-15', (SELECT award_type_id FROM Award_type WHERE award_name = 'Best Player Award')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Sokolov' AND first_name = 'Pavel'), '2020-11-05', (SELECT award_type_id FROM Award_type WHERE award_name = 'Bronze Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Sokolov' AND first_name = 'Pavel'), '2022-12-08', (SELECT award_type_id FROM Award_type WHERE award_name = 'Bronze Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Sokolov' AND first_name = 'Pavel'), '2023-09-12', (SELECT award_type_id FROM Award_type WHERE award_name = 'Best Goalkeeper')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Sokolov' AND first_name = 'Pavel'), '2023-09-12', (SELECT award_type_id FROM Award_type WHERE award_name = 'Best Goalkeeper')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Nikolaeva' AND first_name = 'Ekaterina'), '2022-03-20', (SELECT award_type_id FROM Award_type WHERE award_name = 'Best Player Award')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Nikolaeva' AND first_name = 'Ekaterina'), '2023-04-25', (SELECT award_type_id FROM Award_type WHERE award_name = 'Best Player Award')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Nikolaeva' AND first_name = 'Ekaterina'), '2023-11-30', (SELECT award_type_id FROM Award_type WHERE award_name = 'Team Spirit Award')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Orlov' AND first_name = 'Dmitry'), '2021-10-15', (SELECT award_type_id FROM Award_type WHERE award_name = 'Top Scorer Cup')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Orlov' AND first_name = 'Dmitry'), '2022-10-18', (SELECT award_type_id FROM Award_type WHERE award_name = 'Top Scorer Cup')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Orlov' AND first_name = 'Dmitry'), '2023-10-22', (SELECT award_type_id FROM Award_type WHERE award_name = 'Top Scorer Cup')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Kozlov' AND first_name = 'Ivan' AND birth_date = '2000-03-15'), '2022-06-10', (SELECT award_type_id FROM Award_type WHERE award_name = 'Gold Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Moroz' AND first_name = 'Anna'), '2022-12-05', (SELECT award_type_id FROM Award_type WHERE award_name = 'Silver Medal')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Voronov' AND first_name = 'Sergey'), '2021-05-20', (SELECT award_type_id FROM Award_type WHERE award_name = 'Most Valuable Player')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Voronov' AND first_name = 'Sergey'), '2022-05-25', (SELECT award_type_id FROM Award_type WHERE award_name = 'Most Valuable Player')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Voronov' AND first_name = 'Sergey'), '2023-05-30', (SELECT award_type_id FROM Award_type WHERE award_name = 'Most Valuable Player')),
((SELECT athlete_id FROM Athlete WHERE last_name = 'Voronov' AND first_name = 'Sergey'), '2023-12-15', (SELECT award_type_id FROM Award_type WHERE award_name = 'Most Valuable Player'));

-- Match
INSERT INTO Match (club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT club_id FROM Club WHERE name = 'Spartak'), (SELECT club_id FROM Club WHERE name = 'CSKA'), '2024-03-15', '19:00:00', 1, 1),
((SELECT club_id FROM Club WHERE name = 'Lakers'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2024-03-16', '21:00:00', 2, 0),
((SELECT club_id FROM Club WHERE name = 'Spartak'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2024-03-18', '18:30:00', 0, 3),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Lakers'), '2024-03-20', '20:00:00', 2, 2),
((SELECT club_id FROM Club WHERE name = 'Bayern'), (SELECT club_id FROM Club WHERE name = 'Spartak'), '2024-03-22', '19:45:00', 1, 2),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2024-03-25', '17:30:00', 3, 1),
((SELECT club_id FROM Club WHERE name = 'Lakers'), (SELECT club_id FROM Club WHERE name = 'Spartak'), '2024-03-28', '20:15:00', 0, 1),
((SELECT club_id FROM Club WHERE name = 'PSG'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2024-04-01', '20:30:00', 2, 2),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), (SELECT club_id FROM Club WHERE name = 'São Paulo FC'), '2024-04-03', '19:00:00', 1, 0),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), (SELECT club_id FROM Club WHERE name = 'London Royals'), '2024-04-05', '18:45:00', 3, 1),
((SELECT club_id FROM Club WHERE name = 'Ural'), (SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), '2024-04-07', '17:30:00', 2, 2),
((SELECT club_id FROM Club WHERE name = 'Houston Rockets'), (SELECT club_id FROM Club WHERE name = 'Lakers'), '2024-04-09', '21:15:00', 1, 3),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Dynamo'), '2024-04-11', '19:30:00', 0, 1),
((SELECT club_id FROM Club WHERE name = 'Bayern'), (SELECT club_id FROM Club WHERE name = 'PSG'), '2024-04-13', '20:00:00', 2, 1),
((SELECT club_id FROM Club WHERE name = 'São Paulo FC'), (SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), '2024-04-15', '18:00:00', 1, 1),
((SELECT club_id FROM Club WHERE name = 'Spartak'), (SELECT club_id FROM Club WHERE name = 'Dynamo'), '2024-05-10', '18:30:00', 2, 1),
((SELECT club_id FROM Club WHERE name = 'PSG'), (SELECT club_id FROM Club WHERE name = 'London Royals'), '2024-05-15', '20:00:00', 3, 0),
((SELECT club_id FROM Club WHERE name = 'Bayern'), (SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), '2024-05-20', '19:45:00', 1, 1),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Ural'), '2024-06-01', '17:30:00', 2, 2),
((SELECT club_id FROM Club WHERE name = 'São Paulo FC'), (SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), '2024-06-05', '21:00:00', 1, 0),
((SELECT club_id FROM Club WHERE name = 'Lakers'), (SELECT club_id FROM Club WHERE name = 'Houston Rockets'), '2024-06-10', '22:15:00', 3, 2),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), (SELECT club_id FROM Club WHERE name = 'PSG'), '2024-07-12', '19:00:00', 0, 2),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2024-07-18', '18:45:00', 1, 3),
((SELECT club_id FROM Club WHERE name = 'London Royals'), (SELECT club_id FROM Club WHERE name = 'Spartak'), '2024-08-05', '20:30:00', 2, 1),
((SELECT club_id FROM Club WHERE name = 'Ural'), (SELECT club_id FROM Club WHERE name = 'CSKA'), '2024-08-12', '17:00:00', 0, 1),
((SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), (SELECT club_id FROM Club WHERE name = 'São Paulo FC'), '2024-09-03', '19:15:00', 1, 1),
((SELECT club_id FROM Club WHERE name = 'Houston Rockets'), (SELECT club_id FROM Club WHERE name = 'Lakers'), '2024-09-10', '21:30:00', 2, 3),
((SELECT club_id FROM Club WHERE name = 'Spartak'), (SELECT club_id FROM Club WHERE name = 'London Royals'), '2024-10-05', '18:00:00', 2, 0),
((SELECT club_id FROM Club WHERE name = 'PSG'), (SELECT club_id FROM Club WHERE name = 'Dynamo'), '2024-10-12', '20:45:00', 1, 1),
((SELECT club_id FROM Club WHERE name = 'Bayern'), (SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), '2024-11-08', '19:30:00', 2, 1),
((SELECT club_id FROM Club WHERE name = 'Bayern'), (SELECT club_id FROM Club WHERE name = 'CSKA'), '2024-05-18', '19:00:00', 2, 1),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), (SELECT club_id FROM Club WHERE name = 'São Paulo FC'), '2024-05-25', '18:30:00', 0, 2),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2024-07-05', '20:15:00', 1, 3),
((SELECT club_id FROM Club WHERE name = 'London Royals'), (SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), '2024-07-22', '19:30:00', 2, 0),
((SELECT club_id FROM Club WHERE name = 'Ural'), (SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), '2024-09-15', '17:45:00', 1, 1),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Spartak'), '2024-10-20', '20:00:00', 2, 2);

-- Tournament
INSERT INTO Tournament (match_id, name, start_date, end_date, venue_name, prize_fund, venue_address) VALUES
((SELECT match_id FROM Match WHERE club1_id = (SELECT club_id FROM Club WHERE name = 'Spartak') 
  AND club2_id = (SELECT club_id FROM Club WHERE name = 'Dynamo') 
  AND match_date = '2024-05-10'), 
 'Spring Cup', '2024-05-01 09:00:00', '2024-05-31 22:00:00', 'Olympic Stadium', 750000.00, 'Moscow, Olympiysky Prospect'),
 
((SELECT match_id FROM Match WHERE club1_id = (SELECT club_id FROM Club WHERE name = 'PSG') 
  AND club2_id = (SELECT club_id FROM Club WHERE name = 'London Royals') 
  AND match_date = '2024-05-15'), 
 'Summer Championship', '2024-06-01 10:00:00', '2024-08-31 23:00:00', 'National Arena', 1250000.00, 'Paris, Avenue des Champs-Élysées'),
 
((SELECT match_id FROM Match WHERE club1_id = (SELECT club_id FROM Club WHERE name = 'CSKA') 
  AND club2_id = (SELECT club_id FROM Club WHERE name = 'Ural') 
  AND match_date = '2024-06-01'), 
 'Autumn League', '2024-09-01 08:00:00', '2024-11-30 21:00:00', 'Central Stadium', 950000.00, 'Moscow, Petrovka Street'),
 
((SELECT match_id FROM Match WHERE club1_id = (SELECT club_id FROM Club WHERE name = 'Lakers') 
  AND club2_id = (SELECT club_id FROM Club WHERE name = 'Houston Rockets') 
  AND match_date = '2024-06-10'), 
 'NBA Summer League', '2024-06-01 11:00:00', '2024-08-31 23:59:00', 'Madison Square Garden', 1800000.00, 'New York, 4 Pennsylvania Plaza'),
 
((SELECT match_id FROM Match WHERE club1_id = (SELECT club_id FROM Club WHERE name = 'Bayern') 
  AND club2_id = (SELECT club_id FROM Club WHERE name = 'Tokyo Giants') 
  AND match_date = '2024-11-08'), 
 'Winter Classic', '2024-12-01 09:00:00', '2024-12-31 20:00:00', 'Allianz Arena', 800000.00, 'Munich, Werner-Heisenberg-Allee'),
 
-- Дополнительные турниры
((SELECT match_id FROM Match LIMIT 1 OFFSET 5), 
 'Autumn Championship', '2024-09-01 10:00:00', '2024-09-30 22:00:00', 
 'Olympic Stadium', 500000.00, 'Moscow, Olympiysky Prospect'),
 
((SELECT match_id FROM Match LIMIT 1 OFFSET 6), 
 'Winter League', '2024-12-01 09:00:00', '2024-12-20 21:00:00', 
 'Olympic Stadium', 300000.00, 'Moscow, Olympiysky Prospect'),
 
((SELECT match_id FROM Match LIMIT 1 OFFSET 7), 
 'European Cup', '2024-07-01 11:00:00', '2024-07-31 23:00:00', 
 'National Arena', 900000.00, 'Paris, Avenue des Champs-Élysées'),
 
((SELECT match_id FROM Match LIMIT 1 OFFSET 8), 
 'Regional Championship', '2024-08-01 08:00:00', '2024-08-31 20:00:00', 
 'Central Stadium', 400000.00, 'Moscow, Petrovka Street');

INSERT INTO Rank (athlete_id, assignment_date, rank_title_id)
SELECT DISTINCT
    r.athlete_id,
    (r.assignment_date - INTERVAL '1 year')::DATE,
    rt.previous_rank_id
FROM Rank r
INNER JOIN Rank_title rt ON r.rank_title_id = rt.rank_title_id
WHERE rt.previous_rank_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM Rank r2 
    WHERE r2.athlete_id = r.athlete_id 
    AND r2.rank_title_id = rt.previous_rank_id
);

-- Уровень 2: разряды на 2 шага ниже
INSERT INTO Rank (athlete_id, assignment_date, rank_title_id)
SELECT DISTINCT
    r.athlete_id,
    (r.assignment_date - INTERVAL '2 years')::DATE,
    rt2.previous_rank_id
FROM Rank r
INNER JOIN Rank_title rt ON r.rank_title_id = rt.rank_title_id
INNER JOIN Rank_title rt2 ON rt.previous_rank_id = rt2.rank_title_id
WHERE rt2.previous_rank_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM Rank r2 
    WHERE r2.athlete_id = r.athlete_id 
    AND r2.rank_title_id = rt2.previous_rank_id
);

-- Уровень 3: разряды на 3 шага ниже
INSERT INTO Rank (athlete_id, assignment_date, rank_title_id)
SELECT DISTINCT
    r.athlete_id,
    (r.assignment_date - INTERVAL '3 years')::DATE,
    rt3.previous_rank_id
FROM Rank r
INNER JOIN Rank_title rt ON r.rank_title_id = rt.rank_title_id
INNER JOIN Rank_title rt2 ON rt.previous_rank_id = rt2.rank_title_id
INNER JOIN Rank_title rt3 ON rt2.previous_rank_id = rt3.rank_title_id
WHERE rt3.previous_rank_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM Rank r2 
    WHERE r2.athlete_id = r.athlete_id 
    AND r2.rank_title_id = rt3.previous_rank_id
);

-- Уровень 4: разряды на 4 шага ниже (если кому-то нужно)
INSERT INTO Rank (athlete_id, assignment_date, rank_title_id)
SELECT DISTINCT
    r.athlete_id,
    (r.assignment_date - INTERVAL '4 years')::DATE,
    rt4.previous_rank_id
FROM Rank r
INNER JOIN Rank_title rt ON r.rank_title_id = rt.rank_title_id
INNER JOIN Rank_title rt2 ON rt.previous_rank_id = rt2.rank_title_id
INNER JOIN Rank_title rt3 ON rt2.previous_rank_id = rt3.rank_title_id
INNER JOIN Rank_title rt4 ON rt3.previous_rank_id = rt4.rank_title_id
WHERE rt4.previous_rank_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM Rank r2 
    WHERE r2.athlete_id = r.athlete_id 
    AND r2.rank_title_id = rt4.previous_rank_id
);


-- Third Category (3-й разряд) - базовый, не требует ничего
UPDATE Rank_title SET previous_rank_id = NULL WHERE rank_title = 'Third Category';

-- Second Category (2-й разряд) - требует 3-й разряд как предыдущий
UPDATE Rank_title 
SET previous_rank_id = (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Third Category') 
WHERE rank_title = 'Second Category';

-- First Category (1-й разряд) - требует 2-й разряд как предыдущий
UPDATE Rank_title 
SET previous_rank_id = (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Second Category') 
WHERE rank_title = 'First Category';

-- Candidate Master (КМС) - требует 1-й разряд как предыдущий
UPDATE Rank_title 
SET previous_rank_id = (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'First Category') 
WHERE rank_title = 'Candidate Master';

-- Master of Sports (МС) - требует КМС как предыдущий
UPDATE Rank_title 
SET previous_rank_id = (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Candidate Master') 
WHERE rank_title = 'Master of Sports';

-- International Master (МСМК) - требует МС как предыдущий
UPDATE Rank_title 
SET previous_rank_id = (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'Master of Sports') 
WHERE rank_title = 'International Master';

-- Grandmaster (ЗМС) - требует МСМК как предыдущий
UPDATE Rank_title 
SET previous_rank_id = (SELECT rank_title_id FROM Rank_title WHERE rank_title = 'International Master') 
WHERE rank_title = 'Grandmaster';




INSERT INTO Region (name, country_id) VALUES 
('England', (SELECT country_id FROM Country WHERE name = 'United Kingdom')),
('Greater Manchester', (SELECT country_id FROM Country WHERE name = 'United Kingdom')),
('Merseyside', (SELECT country_id FROM Country WHERE name = 'United Kingdom')),
('Madrid', (SELECT country_id FROM Country WHERE name = 'Spain')),
('Catalonia', (SELECT country_id FROM Country WHERE name = 'Spain')),
('Andalusia', (SELECT country_id FROM Country WHERE name = 'Spain')),
('Bavaria', (SELECT country_id FROM Country WHERE name = 'Germany')),
('Berlin', (SELECT country_id FROM Country WHERE name = 'Germany')),
('North Rhine', (SELECT country_id FROM Country WHERE name = 'Germany')),
('Saxony', (SELECT country_id FROM Country WHERE name = 'Germany')),
('Piedmont', (SELECT country_id FROM Country WHERE name = 'Italy')),
('Lazio', (SELECT country_id FROM Country WHERE name = 'Italy')),
('Ile-de-France', (SELECT country_id FROM Country WHERE name = 'France')),
('Moscow Oblast', (SELECT country_id FROM Country WHERE name = 'Russia'))
ON CONFLICT(name, country_id) DO NOTHING;


INSERT INTO City (name, region_id) VALUES 
-- Англия
('London', (SELECT region_id FROM Region WHERE name = 'England')),
('Manchester', (SELECT region_id FROM Region WHERE name = 'Greater Manchester')),
('Liverpool', (SELECT region_id FROM Region WHERE name = 'Merseyside')),

-- Испания
('Madrid', (SELECT region_id FROM Region WHERE name = 'Madrid')),
('Barcelona', (SELECT region_id FROM Region WHERE name = 'Catalonia')),
('Seville', (SELECT region_id FROM Region WHERE name = 'Andalusia')),

-- Германия
('Munich', (SELECT region_id FROM Region WHERE name = 'Bavaria')),
('Berlin', (SELECT region_id FROM Region WHERE name = 'Berlin')),
('Gelsenkirchen', (SELECT region_id FROM Region WHERE name = 'North Rhine')),
('Wolfsburg', (SELECT region_id FROM Region WHERE name = 'North Rhine')),
('Leipzig', (SELECT region_id FROM Region WHERE name = 'Saxony')),
('Leverkusen', (SELECT region_id FROM Region WHERE name = 'North Rhine')),
('Dortmund', (SELECT region_id FROM Region WHERE name = 'North Rhine')),

-- Италия
('Turin', (SELECT region_id FROM Region WHERE name = 'Piedmont')),
('Rome', (SELECT region_id FROM Region WHERE name = 'Lazio')),

-- Франция
('Paris', (SELECT region_id FROM Region WHERE name = 'Ile-de-France')),

-- Россия
('Moscow', (SELECT region_id FROM Region WHERE name = 'Moscow Oblast'))
ON CONFLICT(name, region_id) DO NOTHING;


-- Английские клубы
INSERT INTO Club (name, city_id, foundation_date) VALUES 
('Manchester United', (SELECT city_id FROM City WHERE name = 'Manchester'), '1878-01-01'),
('Liverpool', (SELECT city_id FROM City WHERE name = 'Liverpool'), '1892-06-03'),
('Arsenal', (SELECT city_id FROM City WHERE name = 'London'), '1886-10-01'),
('Chelsea', (SELECT city_id FROM City WHERE name = 'London'), '1905-03-10'),
('Tottenham', (SELECT city_id FROM City WHERE name = 'London'), '1882-09-05'),
('Manchester City', (SELECT city_id FROM City WHERE name = 'Manchester'), '1880-11-23'),
('Leicester', (SELECT city_id FROM City WHERE name = 'London'), '1884-01-01'),
('Everton', (SELECT city_id FROM City WHERE name = 'Liverpool'), '1878-01-01'),
('Newcastle', (SELECT city_id FROM City WHERE name = 'London'), '1892-12-09')
ON CONFLICT(name, city_id) DO NOTHING;

-- Сборные (используем столицы)
INSERT INTO Club (name, city_id, foundation_date) VALUES 
('England', (SELECT city_id FROM City WHERE name = 'London'), '1863-01-01'),
('Germany', (SELECT city_id FROM City WHERE name = 'Berlin'), '1900-01-01'),
('France', (SELECT city_id FROM City WHERE name = 'Paris'), '1904-01-01'),
('Italy', (SELECT city_id FROM City WHERE name = 'Rome'), '1898-01-01')
ON CONFLICT(name, city_id) DO NOTHING;

-- Испанские клубы
INSERT INTO Club (name, city_id, foundation_date) VALUES 
('Real Madrid', (SELECT city_id FROM City WHERE name = 'Madrid'), '1902-03-06'),
('Barcelona', (SELECT city_id FROM City WHERE name = 'Barcelona'), '1899-11-29'),
('Atletico Madrid', (SELECT city_id FROM City WHERE name = 'Madrid'), '1903-04-26'),
('Sevilla', (SELECT city_id FROM City WHERE name = 'Seville'), '1890-01-25'),
('Espanyol', (SELECT city_id FROM City WHERE name = 'Barcelona'), '1900-10-28'),
('Girona', (SELECT city_id FROM City WHERE name = 'Barcelona'), '1930-07-23'),
('Real Betis', (SELECT city_id FROM City WHERE name = 'Seville'), '1907-09-12'),
('Real Sociedad', (SELECT city_id FROM City WHERE name = 'Madrid'), '1909-09-07'),
('Valencia', (SELECT city_id FROM City WHERE name = 'Madrid'), '1919-03-18'),
('Athletic Bilbao', (SELECT city_id FROM City WHERE name = 'Madrid'), '1898-07-18')
ON CONFLICT(name, city_id) DO NOTHING;

-- Немецкие клубы
INSERT INTO Club (name, city_id, foundation_date) VALUES 
('Bayern', (SELECT city_id FROM City WHERE name = 'Munich'), '1900-02-27'),
('Dortmund', (SELECT city_id FROM City WHERE name = 'Dortmund'), '1909-12-19'),
('Schalke', (SELECT city_id FROM City WHERE name = 'Gelsenkirchen'), '1904-05-04'),
('Wolfsburg', (SELECT city_id FROM City WHERE name = 'Wolfsburg'), '1945-09-12'),
('Leipzig', (SELECT city_id FROM City WHERE name = 'Leipzig'), '2009-05-19'),
('Leverkusen', (SELECT city_id FROM City WHERE name = 'Leverkusen'), '1904-07-01')
ON CONFLICT(name, city_id) DO NOTHING;

-- Итальянские и французские клубы
INSERT INTO Club (name, city_id, foundation_date) VALUES 
('Juventus', (SELECT city_id FROM City WHERE name = 'Turin'), '1897-11-01'),
('PSG', (SELECT city_id FROM City WHERE name = 'Paris'), '1970-08-12')
ON CONFLICT(name, city_id) DO NOTHING;

-- Российские клубы
INSERT INTO Club (name, city_id, foundation_date) VALUES 
('Spartak', (SELECT city_id FROM City WHERE name = 'Moscow'), '1922-04-18'),
('CSKA', (SELECT city_id FROM City WHERE name = 'Moscow'), '1911-08-27'),
('Dynamo', (SELECT city_id FROM City WHERE name = 'Moscow'), '1923-04-18'),
('Zenit', (SELECT city_id FROM City WHERE name = 'Moscow'), '1925-05-25')
ON CONFLICT(name, city_id) DO NOTHING;



-- Сначала создаем турниры (они получат свои ID автоматически)
INSERT INTO Tournament (name, start_date, end_date, venue_name, prize_fund, venue_address) VALUES 
('Spring Cup', '2024-05-01 09:00:00', '2024-05-31 22:00:00', 'Olympic Stadium', 750000.00, 'Moscow, Olympiysky Prospect'),
('Summer Championship', '2024-06-01 10:00:00', '2024-08-31 23:00:00', 'National Arena', 1250000.00, 'Paris, Avenue des Champs-Élysées'),
('Autumn League', '2024-09-01 08:00:00', '2024-11-30 21:00:00', 'Central Stadium', 950000.00, 'Moscow, Petrovka Street'),
('NBA Summer League', '2024-06-01 11:00:00', '2024-08-31 23:59:00', 'Madison Square Garden', 1800000.00, 'New York, 4 Pennsylvania Plaza'),
('Winter Classic', '2024-12-01 09:00:00', '2024-12-31 20:00:00', 'Allianz Arena', 800000.00, 'Munich, Werner-Heisenberg-Allee'),
('Autumn Championship', '2024-09-01 10:00:00', '2024-09-30 22:00:00', 'Olympic Stadium', 500000.00, 'Moscow, Olympiysky Prospect'),
('Winter League', '2024-12-01 09:00:00', '2024-12-20 21:00:00', 'Olympic Stadium', 300000.00, 'Moscow, Olympiysky Prospect'),
('European Cup', '2024-07-01 11:00:00', '2024-07-31 23:00:00', 'National Arena', 900000.00, 'Paris, Avenue des Champs-Élysées'),
('Regional Championship', '2024-08-01 08:00:00', '2024-08-31 20:00:00', 'Central Stadium', 400000.00, 'Moscow, Petrovka Street');

-- Теперь вставляем матчи с указанием tournament_id через подзапросы
-- Матчи для Spring Cup
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Spring Cup'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2024-05-10', '18:30:00', 2, 1);

-- Матчи для Summer Championship
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Summer Championship'), 
 (SELECT club_id FROM Club WHERE name = 'PSG'), 
 (SELECT club_id FROM Club WHERE name = 'London Royals'), 
 '2024-05-15', '20:00:00', 3, 0);

-- Матчи для Autumn League
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Autumn League'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT club_id FROM Club WHERE name = 'Ural'), 
 '2024-06-01', '17:30:00', 2, 2);

-- Матчи для NBA Summer League
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'NBA Summer League'), 
 (SELECT club_id FROM Club WHERE name = 'Lakers'), 
 (SELECT club_id FROM Club WHERE name = 'Houston Rockets'), 
 '2024-06-10', '22:15:00', 3, 2);

-- Матчи для Winter Classic
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Winter Classic'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 (SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 
 '2024-11-08', '19:30:00', 2, 1);

-- Остальные матчи без турнира (tournament_id = NULL)
INSERT INTO Match (club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT club_id FROM Club WHERE name = 'Spartak'), (SELECT club_id FROM Club WHERE name = 'CSKA'), '2024-03-15', '19:00:00', 1, 1),
((SELECT club_id FROM Club WHERE name = 'Lakers'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2024-03-16', '21:00:00', 2, 0),
((SELECT club_id FROM Club WHERE name = 'Spartak'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2024-03-18', '18:30:00', 0, 3),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Lakers'), '2024-03-20', '20:00:00', 2, 2),
((SELECT club_id FROM Club WHERE name = 'Bayern'), (SELECT club_id FROM Club WHERE name = 'Spartak'), '2024-03-22', '19:45:00', 1, 2),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2024-03-25', '17:30:00', 3, 1),
((SELECT club_id FROM Club WHERE name = 'Lakers'), (SELECT club_id FROM Club WHERE name = 'Spartak'), '2024-03-28', '20:15:00', 0, 1),
((SELECT club_id FROM Club WHERE name = 'PSG'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2024-04-01', '20:30:00', 2, 2),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), (SELECT club_id FROM Club WHERE name = 'São Paulo FC'), '2024-04-03', '19:00:00', 1, 0),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), (SELECT club_id FROM Club WHERE name = 'London Royals'), '2024-04-05', '18:45:00', 3, 1),
((SELECT club_id FROM Club WHERE name = 'Ural'), (SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), '2024-04-07', '17:30:00', 2, 2),
((SELECT club_id FROM Club WHERE name = 'Houston Rockets'), (SELECT club_id FROM Club WHERE name = 'Lakers'), '2024-04-09', '21:15:00', 1, 3),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Dynamo'), '2024-04-11', '19:30:00', 0, 1),
((SELECT club_id FROM Club WHERE name = 'Bayern'), (SELECT club_id FROM Club WHERE name = 'PSG'), '2024-04-13', '20:00:00', 2, 1),
((SELECT club_id FROM Club WHERE name = 'São Paulo FC'), (SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), '2024-04-15', '18:00:00', 1, 1),
((SELECT club_id FROM Club WHERE name = 'Bayern'), (SELECT club_id FROM Club WHERE name = 'CSKA'), '2024-05-18', '19:00:00', 2, 1),
((SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), (SELECT club_id FROM Club WHERE name = 'São Paulo FC'), '2024-05-25', '18:30:00', 0, 2);

-- Турниры за 2025 год
INSERT INTO Tournament (name, start_date, end_date, venue_name, prize_fund, venue_address) VALUES
('Spring International 2025', '2025-03-01 09:00:00', '2025-03-31 22:00:00', 'Luzhniki Stadium', 850000.00, 'Moscow, Luzhniki Street, 24'),
('El Clasico Cup 2025', '2025-04-01 10:00:00', '2025-04-30 21:00:00', 'Santiago Bernabeu', 1200000.00, 'Madrid, Av. de Concha Espina, 1'),
('Summer Championship 2025', '2025-07-01 08:00:00', '2025-07-31 20:00:00', 'Allianz Arena', 950000.00, 'Munich, Werner-Heisenberg-Allee, 25'),
('Autumn Tournament 2025', '2025-09-15 09:00:00', '2025-10-15 22:00:00', 'VTB Arena', 700000.00, 'Moscow, Leningradsky Prospect, 36');

-- Матчи 2025 года с привязкой к турнирам через подзапросы
-- Spring International 2025
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Spring International 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2025-03-15', '19:00:00', 2, 1);

-- El Clasico Cup 2025
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'El Clasico Cup 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 '2025-04-10', '20:45:00', 2, 2);

-- Summer Championship 2025
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Summer Championship 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 '2025-07-15', '21:15:00', 3, 1);

-- Autumn Tournament 2025
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Autumn Tournament 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2025-09-30', '16:45:00', 1, 1);

-- Остальные матчи 2025 без турнира
INSERT INTO Match (club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT club_id FROM Club WHERE name = 'Lakers'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2025-03-16', '21:00:00', 3, 2),
((SELECT club_id FROM Club WHERE name = 'Spartak'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2025-03-18', '18:30:00', 1, 3),
((SELECT club_id FROM Club WHERE name = 'Zenit'), (SELECT club_id FROM Club WHERE name = 'Dynamo'), '2025-05-05', '17:00:00', 1, 0),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Lakers'), '2025-06-20', '19:30:00', 0, 4),
((SELECT club_id FROM Club WHERE name = 'Barcelona'), (SELECT club_id FROM Club WHERE name = 'Spartak'), '2025-08-22', '18:00:00', 2, 1),
((SELECT club_id FROM Club WHERE name = 'Zenit'), (SELECT club_id FROM Club WHERE name = 'Bayern'), '2025-10-12', '20:00:00', 0, 2);

-- Турниры 2026 года
INSERT INTO Tournament (name, start_date, end_date, venue_name, prize_fund, venue_address) VALUES
('Winter Cup 2026', '2026-01-01 09:00:00', '2026-01-31 22:00:00', 'Otkrytie Arena', 900000.00, 'Moscow, Volgogradsky Prospect, 69'),
('Champions League 2026', '2026-02-15 10:00:00', '2026-03-15 21:00:00', 'Allianz Arena', 1500000.00, 'Munich, Werner-Heisenberg-Allee, 25'),
('Spring Classic 2026', '2026-04-01 08:00:00', '2026-04-30 20:00:00', 'Camp Nou', 1100000.00, 'Barcelona, C. d''Aristides Maillol, 12'),
('Summer International 2026', '2026-06-01 09:00:00', '2026-06-30 22:00:00', 'Gazprom Arena', 800000.00, 'Saint Petersburg, Football Alley, 1');

-- Матчи 2026 года с привязкой к турнирам через подзапросы
-- Winter Cup 2026
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Winter Cup 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2026-01-10', '18:00:00', 2, 0);

-- Champions League 2026
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Champions League 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 '2026-02-28', '21:00:00', 3, 2);

-- Spring Classic 2026
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Spring Classic 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2026-04-18', '18:30:00', 3, 1);

-- Summer International 2026
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Summer International 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 '2026-06-10', '20:45:00', 0, 0);

-- Остальные матчи 2026 без турнира
INSERT INTO Match (club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Zenit'), '2026-02-15', '19:30:00', 1, 1),
((SELECT club_id FROM Club WHERE name = 'Lakers'), (SELECT club_id FROM Club WHERE name = 'Barcelona'), '2026-03-08', '17:45:00', 2, 3),
((SELECT club_id FROM Club WHERE name = 'Bayern'), (SELECT club_id FROM Club WHERE name = 'CSKA'), '2026-03-25', '20:15:00', 4, 0),
((SELECT club_id FROM Club WHERE name = 'Dynamo'), (SELECT club_id FROM Club WHERE name = 'Real Madrid'), '2026-04-05', '19:00:00', 1, 2),
((SELECT club_id FROM Club WHERE name = 'Lakers'), (SELECT club_id FROM Club WHERE name = 'Spartak'), '2026-05-20', '21:00:00', 2, 1),
((SELECT club_id FROM Club WHERE name = 'CSKA'), (SELECT club_id FROM Club WHERE name = 'Barcelona'), '2026-07-01', '19:15:00', 1, 3);

-- Wembley турниры
INSERT INTO Tournament (name, start_date, end_date, venue_name, prize_fund, venue_address) VALUES
('Международный кубок 2026', '2026-11-20 09:00:00', '2026-12-10 22:00:00', 'Wembley', 1500000.00, 'Лондон, Wembley Park'),
('Кубок Англии 2026', '2026-12-01 09:00:00', '2026-12-31 22:00:00', 'Wembley', 700000.00, 'Лондон, Wembley Park');

-- Матчи для Международного кубка 2026
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'England'), 
 (SELECT club_id FROM Club WHERE name = 'Germany'), 
 '2026-11-25', '20:00:00', 2, 0),
 
((SELECT tournament_id FROM Tournament WHERE name = 'Международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'England'), 
 (SELECT club_id FROM Club WHERE name = 'France'), 
 '2026-11-28', '20:00:00', 1, 1),
 
((SELECT tournament_id FROM Tournament WHERE name = 'Международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'England'), 
 (SELECT club_id FROM Club WHERE name = 'Italy'), 
 '2026-12-02', '20:00:00', 3, 2);

-- Матчи для Кубка Англии 2026
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Англии 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Tottenham'), 
 (SELECT club_id FROM Club WHERE name = 'Arsenal'), 
 '2026-12-15', '19:45:00', 1, 1),
 
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Англии 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Tottenham'), 
 (SELECT club_id FROM Club WHERE name = 'Chelsea'), 
 '2026-12-22', '19:45:00', 2, 3),
 
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Англии 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Tottenham'), 
 (SELECT club_id FROM Club WHERE name = 'Liverpool'), 
 '2026-12-29', '19:45:00', 0, 2);

-- Luzhniki турниры
INSERT INTO Tournament (name, start_date, end_date, venue_name, prize_fund, venue_address) VALUES
('Зимний кубок 2026', '2026-01-01 09:00:00', '2026-01-31 22:00:00', 'Luzhniki', 500000.00, 'Москва, ул. Лужники, 24'),
('Кубок Содружества 2026', '2026-02-01 09:00:00', '2026-02-28 22:00:00', 'Luzhniki', 600000.00, 'Москва, ул. Лужники, 24'),
('Московский международный кубок 2026', '2026-03-01 09:00:00', '2026-03-31 22:00:00', 'Luzhniki', 750000.00, 'Москва, ул. Лужники, 24');

-- Матчи для Зимнего кубка 2026
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Зимний кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2026-01-10', '18:00:00', 2, 1),
 
((SELECT tournament_id FROM Tournament WHERE name = 'Зимний кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2026-01-17', '18:00:00', 1, 1),
 
((SELECT tournament_id FROM Tournament WHERE name = 'Зимний кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2026-01-24', '18:00:00', 3, 0);

-- Матчи для Кубка Содружества 2026
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Содружества 2026'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2026-02-10', '19:00:00', 2, 0),
 
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Содружества 2026'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2026-02-17', '19:00:00', 1, 2),
 
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Содружества 2026'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 '2026-02-24', '19:00:00', 0, 1);

-- Матчи для Московского международного кубка 2026
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Московский международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2026-03-05', '20:00:00', 1, 1),
 
((SELECT tournament_id FROM Tournament WHERE name = 'Московский международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 '2026-03-12', '20:00:00', 2, 3),
 
((SELECT tournament_id FROM Tournament WHERE name = 'Московский международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2026-03-19', '20:00:00', 0, 0);


-- Добавляем 18 спортсменов в CSKA
WITH new_athletes AS (
    VALUES 
    ('CSKA_Athlete_1', 'Ivanov_1', 'Ivan', 'Ivanovich', 'male', '2000-01-01'::DATE, 185.5, 78.2, '+79990000001'),
    ('CSKA_Athlete_2', 'Petrov_2', 'Petr', 'Petrovich', 'male', '2000-02-01'::DATE, 182.3, 76.1, '+79990000002'),
    ('CSKA_Athlete_3', 'Sidorov_3', 'Sidor', 'Sidorovich', 'male', '2000-03-01'::DATE, 188.2, 82.3, '+79990000003'),
    ('CSKA_Athlete_4', 'Smirnov_4', 'Alexey', 'Dmitrievich', 'male', '2000-04-01'::DATE, 184.1, 79.5, '+79990000004'),
    ('CSKA_Athlete_5', 'Kuznetsov_5', 'Nikolay', 'Sergeevich', 'male', '2000-05-01'::DATE, 186.7, 81.2, '+79990000005'),
    ('CSKA_Athlete_6', 'Popov_6', 'Andrey', 'Viktorovich', 'male', '2000-06-01'::DATE, 183.4, 77.8, '+79990000006'),
    ('CSKA_Athlete_7', 'Volkov_7', 'Dmitry', 'Alexandrovich', 'male', '2000-07-01'::DATE, 187.3, 83.1, '+79990000007'),
    ('CSKA_Athlete_8', 'Fedorov_8', 'Sergey', 'Ivanovich', 'male', '2000-08-01'::DATE, 181.9, 75.9, '+79990000008'),
    ('CSKA_Athlete_9', 'Morozov_9', 'Pavel', 'Petrovich', 'male', '2000-09-01'::DATE, 185.2, 79.8, '+79990000009'),
    ('CSKA_Athlete_10', 'Vasiliev_10', 'Roman', 'Andreevich', 'male', '2000-10-01'::DATE, 184.8, 80.1, '+79990000010'),
    ('CSKA_Athlete_11', 'Novikov_11', 'Artem', 'Sergeevich', 'male', '2000-11-01'::DATE, 189.1, 84.5, '+79990000011'),
    ('CSKA_Athlete_12', 'Zaitsev_12', 'Maxim', 'Ilyich', 'male', '2000-12-01'::DATE, 183.7, 77.2, '+79990000012'),
    ('CSKA_Athlete_13', 'Sorokin_13', 'Ilya', 'Vladimirovich', 'male', '2001-01-01'::DATE, 186.3, 81.7, '+79990000013'),
    ('CSKA_Athlete_14', 'Belyaev_14', 'Egor', 'Mikhailovich', 'male', '2001-02-01'::DATE, 185.9, 80.3, '+79990000014'),
    ('CSKA_Athlete_15', 'Titov_15', 'Denis', 'Evgenievich', 'male', '2001-03-01'::DATE, 182.6, 76.5, '+79990000015'),
    ('CSKA_Athlete_16', 'Gusev_16', 'Kirill', 'Nikolaevich', 'male', '2001-04-01'::DATE, 187.5, 83.9, '+79990000016'),
    ('CSKA_Athlete_17', 'Karpov_17', 'Vladimir', 'Olegovich', 'male', '2001-05-01'::DATE, 184.2, 79.4, '+79990000017'),
    ('CSKA_Athlete_18', 'Mikhailov_18', 'Anton', 'Grigorievich', 'male', '2001-06-01'::DATE, 186.8, 82.2, '+79990000018')
)
INSERT INTO Athlete (club_id, last_name, first_name, middle_name, gender, birth_date, phone, height, weight)
SELECT 
    (SELECT club_id FROM Club WHERE name = 'CSKA'),
    column2, column3, column4, column5, column6, column9, column7, column8
FROM new_athletes
ON CONFLICT(phone) DO NOTHING;

INSERT INTO Athlete (club_id, last_name, first_name, middle_name, gender, birth_date, phone, height, weight)
SELECT 
    (SELECT club_id FROM Club WHERE name = 'Spartak'),
    last_name, first_name, middle_name, gender, birth_date::DATE, phone, height, weight
FROM (
    VALUES 
    ('Морозов', 'Дмитрий', 'Александрович', 'male', '2002-07-15', '+79020000001', 184.3, 77.5),
    ('Волкова', 'Екатерина', 'Сергеевна', 'female', '2003-08-22', '+79020000002', 172.1, 62.3),
    ('Соколов', 'Андрей', 'Игоревич', 'male', '2001-09-10', '+79020000003', 186.5, 81.7),
    ('Новикова', 'Татьяна', 'Дмитриевна', 'female', '2002-10-05', '+79020000004', 169.8, 59.9),
    ('Зайцев', 'Максим', 'Павлович', 'male', '2000-11-18', '+79020000005', 189.2, 85.4),
    ('Лебедева', 'Ольга', 'Николаевна', 'female', '2002-12-25', '+79020000006', 171.5, 61.8)
) AS data(last_name, first_name, middle_name, gender, birth_date, phone, height, weight)
ON CONFLICT(phone) DO NOTHING;

-- Добавляем стадионы
INSERT INTO Stadion (name, address) VALUES 
('Olympic Stadium', 'Moscow, Olympiysky Prospect'),
('National Arena', 'Paris, Avenue des Champs-Élysées'),
('Central Stadium', 'Moscow, Petrovka Street'),
('Madison Square Garden', 'New York, 4 Pennsylvania Plaza'),
('Allianz Arena', 'Munich, Werner-Heisenberg-Allee'),
('Luzhniki', 'Moscow, Luzhniki Street, 24'),
('Santiago Bernabeu', 'Madrid, Av. de Concha Espina, 1'),
('VTB Arena', 'Moscow, Leningradsky Prospect, 36'),
('Otkritie Arena', 'Moscow, Volgogradsky Prospect, 69'),
('Camp Nou', 'Barcelona, C. d''Aristides Maillol, 12'),
('Gazprom Arena', 'Saint Petersburg, Football Alley, 1'),
('Wembley', 'London, Wembley Park');



INSERT INTO Tournament (name, start_date, end_date, stadion_id, prize_fund) VALUES 
-- 2024 год
('Spring Cup', '2024-05-01 09:00:00', '2024-05-31 22:00:00', 
 (SELECT stadion_id FROM Stadion WHERE name = 'Olympic Stadium'), 750000.00),
 
('Summer Championship', '2024-06-01 10:00:00', '2024-08-31 23:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'National Arena'), 1250000.00),
 
('Autumn League', '2024-09-01 08:00:00', '2024-11-30 21:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Central Stadium'), 950000.00),
 
('NBA Summer League', '2024-06-01 11:00:00', '2024-08-31 23:59:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Madison Square Garden'), 1800000.00),
 
('Winter Classic', '2024-12-01 09:00:00', '2024-12-31 20:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Allianz Arena'), 800000.00),
 
('European Cup', '2024-07-01 11:00:00', '2024-07-31 23:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Wembley'), 2000000.00),

-- 2025 год
('Spring International 2025', '2025-03-01 09:00:00', '2025-03-31 22:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Luzhniki'), 850000.00),
 
('El Clasico Cup 2025', '2025-04-01 10:00:00', '2025-04-30 21:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Santiago Bernabeu'), 1200000.00),
 
('Summer Championship 2025', '2025-07-01 08:00:00', '2025-07-31 20:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Allianz Arena'), 950000.00),
 
('Autumn Tournament 2025', '2025-09-15 09:00:00', '2025-10-15 22:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'VTB Arena'), 700000.00),

-- 2026 год
('Winter Cup 2026', '2026-01-01 09:00:00', '2026-01-31 22:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Otkritie Arena'), 900000.00),
 
('Champions League 2026', '2026-02-15 10:00:00', '2026-03-15 21:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Allianz Arena'), 1500000.00),
 
('Spring Classic 2026', '2026-04-01 08:00:00', '2026-04-30 20:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Camp Nou'), 1100000.00),
 
('Summer International 2026', '2026-06-01 09:00:00', '2026-06-30 22:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Gazprom Arena'), 800000.00),
 
('Международный кубок 2026', '2026-11-20 09:00:00', '2026-12-10 22:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Wembley'), 1500000.00),
 
('Кубок Англии 2026', '2026-12-01 09:00:00', '2026-12-31 22:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Wembley'), 700000.00),
 
('Зимний кубок 2026', '2026-01-01 09:00:00', '2026-01-31 22:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Luzhniki'), 500000.00),
 
('Кубок Содружества 2026', '2026-02-01 09:00:00', '2026-02-28 22:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Luzhniki'), 600000.00),
 
('Московский международный кубок 2026', '2026-03-01 09:00:00', '2026-03-31 22:00:00',
 (SELECT stadion_id FROM Stadion WHERE name = 'Luzhniki'), 750000.00);

-- Для Spring Cup (предположим, tournament_id = 1)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Spring Cup'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2024-05-10', '18:30:00', 2, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Spring Cup'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT club_id FROM Club WHERE name = 'Lakers'), 
 '2024-05-12', '19:00:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Spring Cup'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 (SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), 
 '2024-05-15', '17:30:00', 3, 0);

-- Для Summer Championship (tournament_id = 2)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Summer Championship'), 
 (SELECT club_id FROM Club WHERE name = 'PSG'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 '2024-06-15', '21:00:00', 2, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'Summer Championship'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 '2024-07-10', '20:45:00', 3, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Summer Championship'), 
 (SELECT club_id FROM Club WHERE name = 'London Royals'), 
 (SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 
 '2024-08-05', '19:30:00', 1, 0);

-- Для Autumn League (tournament_id = 3)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Autumn League'), 
 (SELECT club_id FROM Club WHERE name = 'Ural'), 
 (SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), 
 '2024-09-15', '17:00:00', 2, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'Autumn League'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2024-10-20', '19:30:00', 1, 0),
((SELECT tournament_id FROM Tournament WHERE name = 'Autumn League'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2024-11-05', '18:00:00', 2, 1);

-- Для NBA Summer League (tournament_id = 4)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'NBA Summer League'), 
 (SELECT club_id FROM Club WHERE name = 'Lakers'), 
 (SELECT club_id FROM Club WHERE name = 'Houston Rockets'), 
 '2024-06-20', '22:00:00', 3, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'NBA Summer League'), 
 (SELECT club_id FROM Club WHERE name = 'Lakers'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2024-07-15', '21:30:00', 4, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'NBA Summer League'), 
 (SELECT club_id FROM Club WHERE name = 'Houston Rockets'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 '2024-08-10', '20:00:00', 2, 3);

-- Для Winter Classic (tournament_id = 5)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Winter Classic'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 (SELECT club_id FROM Club WHERE name = 'PSG'), 
 '2024-12-05', '20:30:00', 2, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Winter Classic'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 '2024-12-12', '21:00:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Winter Classic'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2024-12-20', '19:00:00', 3, 2);

-- Для European Cup (tournament_id = 6)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'European Cup'), 
 (SELECT club_id FROM Club WHERE name = 'England'), 
 (SELECT club_id FROM Club WHERE name = 'Germany'), 
 '2024-07-05', '20:00:00', 2, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'European Cup'), 
 (SELECT club_id FROM Club WHERE name = 'France'), 
 (SELECT club_id FROM Club WHERE name = 'Italy'), 
 '2024-07-12', '20:00:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'European Cup'), 
 (SELECT club_id FROM Club WHERE name = 'Spain'), 
 (SELECT club_id FROM Club WHERE name = 'Portugal'), 
 '2024-07-19', '20:00:00', 3, 0),
((SELECT tournament_id FROM Tournament WHERE name = 'European Cup'), 
 (SELECT club_id FROM Club WHERE name = 'England'), 
 (SELECT club_id FROM Club WHERE name = 'France'), 
 '2024-07-26', '20:00:00', 1, 0);

-- Для Spring International 2025 (tournament_id = 7)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Spring International 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2025-03-10', '19:30:00', 2, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'Spring International 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2025-03-17', '18:00:00', 1, 0),
((SELECT tournament_id FROM Tournament WHERE name = 'Spring International 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Lakers'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 '2025-03-24', '21:00:00', 3, 1);

-- Для El Clasico Cup 2025 (tournament_id = 8)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'El Clasico Cup 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 '2025-04-05', '21:00:00', 2, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'El Clasico Cup 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 '2025-04-12', '21:00:00', 1, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'El Clasico Cup 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 '2025-04-19', '21:00:00', 3, 3);

-- Для Summer Championship 2025 (tournament_id = 9)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Summer Championship 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 (SELECT club_id FROM Club WHERE name = 'PSG'), 
 '2025-07-05', '20:30:00', 2, 0),
((SELECT tournament_id FROM Tournament WHERE name = 'Summer Championship 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 '2025-07-12', '21:00:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Summer Championship 2025'), 
 (SELECT club_id FROM Club WHERE name = 'London Royals'), 
 (SELECT club_id FROM Club WHERE name = 'Tokyo Giants'), 
 '2025-07-19', '19:30:00', 2, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Summer Championship 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2025-07-26', '18:30:00', 1, 2);

-- Для Autumn Tournament 2025 (tournament_id = 10)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Autumn Tournament 2025'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2025-09-20', '19:00:00', 2, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Autumn Tournament 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2025-09-27', '18:30:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Autumn Tournament 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Ural'), 
 (SELECT club_id FROM Club WHERE name = 'Krasnodar FC'), 
 '2025-10-04', '17:00:00', 0, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'Autumn Tournament 2025'), 
 (SELECT club_id FROM Club WHERE name = 'Lakers'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 '2025-10-11', '21:00:00', 3, 2);

-- Для Winter Cup 2026 (tournament_id = 11)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Winter Cup 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2026-01-10', '18:00:00', 2, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Winter Cup 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2026-01-17', '18:00:00', 1, 0),
((SELECT tournament_id FROM Tournament WHERE name = 'Winter Cup 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Lakers'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 '2026-01-24', '21:00:00', 3, 2);

-- Для Champions League 2026 (tournament_id = 12)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Champions League 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 '2026-02-20', '21:00:00', 2, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Champions League 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 (SELECT club_id FROM Club WHERE name = 'PSG'), 
 '2026-02-27', '21:00:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Champions League 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2026-03-06', '20:00:00', 3, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'Champions League 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 '2026-03-13', '21:00:00', 2, 2);

-- Для Spring Classic 2026 (tournament_id = 13)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Spring Classic 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Barcelona'), 
 (SELECT club_id FROM Club WHERE name = 'Real Madrid'), 
 '2026-04-05', '21:00:00', 1, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'Spring Classic 2026'), 
 (SELECT club_id FROM Club WHERE name = 'PSG'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 '2026-04-12', '20:30:00', 2, 0),
((SELECT tournament_id FROM Tournament WHERE name = 'Spring Classic 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2026-04-19', '18:30:00', 2, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'Spring Classic 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2026-04-26', '19:00:00', 1, 0);

-- Для Summer International 2026 (tournament_id = 14)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Summer International 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 '2026-06-05', '19:30:00', 2, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Summer International 2026'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2026-06-12', '18:00:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Summer International 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Lakers'), 
 (SELECT club_id FROM Club WHERE name = 'Bayern'), 
 '2026-06-19', '21:00:00', 3, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'Summer International 2026'), 
 (SELECT club_id FROM Club WHERE name = 'PSG'), 
 (SELECT club_id FROM Club WHERE name = 'London Royals'), 
 '2026-06-26', '20:30:00', 2, 0);

-- Для Международный кубок 2026 (tournament_id = 15)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'England'), 
 (SELECT club_id FROM Club WHERE name = 'Germany'), 
 '2026-11-25', '20:00:00', 2, 0),
((SELECT tournament_id FROM Tournament WHERE name = 'Международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'England'), 
 (SELECT club_id FROM Club WHERE name = 'France'), 
 '2026-11-28', '20:00:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'England'), 
 (SELECT club_id FROM Club WHERE name = 'Italy'), 
 '2026-12-02', '20:00:00', 3, 2);

-- Для Кубок Англии 2026 (tournament_id = 16)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Англии 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Tottenham'), 
 (SELECT club_id FROM Club WHERE name = 'Arsenal'), 
 '2026-12-15', '19:45:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Англии 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Tottenham'), 
 (SELECT club_id FROM Club WHERE name = 'Chelsea'), 
 '2026-12-22', '19:45:00', 2, 3),
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Англии 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Tottenham'), 
 (SELECT club_id FROM Club WHERE name = 'Liverpool'), 
 '2026-12-29', '19:45:00', 0, 2);

-- Для Зимний кубок 2026 (tournament_id = 17)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Зимний кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2026-01-10', '18:00:00', 2, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Зимний кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2026-01-17', '18:00:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Зимний кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2026-01-24', '18:00:00', 3, 0);

-- Для Кубок Содружества 2026 (tournament_id = 18)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Содружества 2026'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 '2026-02-10', '19:00:00', 2, 0),
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Содружества 2026'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2026-02-17', '19:00:00', 1, 2),
((SELECT tournament_id FROM Tournament WHERE name = 'Кубок Содружества 2026'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 '2026-02-24', '19:00:00', 0, 1);

-- Для Московский международный кубок 2026 (tournament_id = 19)
INSERT INTO Match (tournament_id, club1_id, club2_id, match_date, match_time, result_1, result_2) VALUES 
((SELECT tournament_id FROM Tournament WHERE name = 'Московский международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT club_id FROM Club WHERE name = 'CSKA'), 
 '2026-03-05', '20:00:00', 1, 1),
((SELECT tournament_id FROM Tournament WHERE name = 'Московский международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT club_id FROM Club WHERE name = 'Spartak'), 
 '2026-03-12', '20:00:00', 2, 3),
((SELECT tournament_id FROM Tournament WHERE name = 'Московский международный кубок 2026'), 
 (SELECT club_id FROM Club WHERE name = 'Dynamo'), 
 (SELECT club_id FROM Club WHERE name = 'Zenit'), 
 '2026-03-19', '20:00:00', 0, 0);
