-- Country
DROP TABLE IF EXISTS Country CASCADE;
CREATE TABLE Country (
    country_id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL UNIQUE
);

-- Region
DROP TABLE IF EXISTS Region CASCADE;
CREATE TABLE Region (
    region_id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    country_id INTEGER REFERENCES Country(country_id),
    UNIQUE (name, country_id) -- Названия регионов уникальны в пределах страны
);

-- City
DROP TABLE IF EXISTS City CASCADE;
CREATE TABLE City (
    city_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    region_id INTEGER REFERENCES Region(region_id),
    UNIQUE (name, region_id) -- Города уникальны в пределах региона
);

-- Club
DROP TABLE IF EXISTS Club CASCADE;
CREATE TABLE Club (
    club_id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    city_id INTEGER REFERENCES City(city_id),
    foundation_date DATE NOT NULL,
    UNIQUE (name, city_id) -- Названия клубов уникальны в пределах города
);

-- ALTER TABLE: Добавим проверку даты основания
ALTER TABLE Club ADD CONSTRAINT chk_foundation_date CHECK (foundation_date >= DATE '1700-01-01');

-- Owner
DROP TABLE IF EXISTS Owner CASCADE;
CREATE TABLE Owner (
    owner_id SERIAL PRIMARY KEY,
    last_name VARCHAR(20) NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    middle_name VARCHAR(20),
    phone VARCHAR(20) NOT NULL UNIQUE, -- Уникальный номер телефона
    gender VARCHAR(20) NOT NULL,
    city_id INTEGER REFERENCES City(city_id)
);


DROP TABLE IF EXISTS Club_Owner CASCADE;
CREATE TABLE Club_Owner (
    club_id INTEGER REFERENCES Club(club_id),
    owner_id INTEGER REFERENCES Owner(owner_id),
    ownership_share NUMERIC NOT NULL,
    PRIMARY KEY (club_id, owner_id)
);


DROP TABLE IF EXISTS Sponsor CASCADE;
CREATE TABLE Sponsor (
    sponsor_id SERIAL PRIMARY KEY,
    sponsor_type VARCHAR(10) NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE,
    contact_phone VARCHAR(20)
);

DROP TABLE IF EXISTS sponsor_org CASCADE;
CREATE TABLE sponsor_org (
    sponsor_id INTEGER PRIMARY KEY REFERENCES sponsor(sponsor_id),
    inn VARCHAR(12) NOT NULL UNIQUE,
    org_name VARCHAR(100) NOT NULL,
    phone INTEGER NOT NULL
);

DROP TABLE IF EXISTS sponsor_person CASCADE;
CREATE TABLE sponsor_person (
    sponsor_id INTEGER PRIMARY KEY REFERENCES sponsor(sponsor_id),
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50)
);



DROP TABLE IF EXISTS Sponsorship CASCADE;
CREATE TABLE Sponsorship (
    sponsorship_id SERIAL PRIMARY KEY,
    club_id INTEGER NOT NULL REFERENCES club(club_id),
    sponsor_id INTEGER NOT NULL REFERENCES sponsor(sponsor_id),
    donation_date DATE NOT NULL,
    donation_amount DECIMAL(12,2) NOT NULL CHECK (donation_amount > 0),
    purpose VARCHAR(200)
);


DROP TABLE IF EXISTS Athlete CASCADE;
CREATE TABLE Athlete (
    athlete_id SERIAL PRIMARY KEY,
    club_id INTEGER REFERENCES Club(club_id),
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    gender TEXT NOT NULL,
    birth_date DATE NOT NULL,
    phone TEXT UNIQUE, -- Уникальный номер
    height NUMERIC NOT NULL,
    weight NUMERIC NOT NULL
);

ALTER TABLE Athlete ADD CONSTRAINT chk_birth_date 
CHECK (birth_date <= CURRENT_DATE);

ALTER TABLE Athlete ADD CONSTRAINT chk_height_weight 
CHECK (height > 0 AND weight > 0);

-- Rank_title
DROP TABLE IF EXISTS Rank_title CASCADE;
CREATE TABLE Rank_title (
    rank_title_id SERIAL PRIMARY KEY,
    rank_title TEXT UNIQUE, -- Название званий уникально
    previous_rank_id INTEGER REFERENCES Rank_title(rank_title_id)
);

-- Rank
DROP TABLE IF EXISTS Rank CASCADE;
CREATE TABLE Rank (
    rank_id SERIAL PRIMARY KEY,
    athlete_id INTEGER REFERENCES Athlete(athlete_id),
    assignment_date DATE NOT NULL,
    rank_title_id INTEGER REFERENCES Rank_title(rank_title_id),
    UNIQUE (athlete_id, rank_title_id) -- Одно звание - один раз для спортсмена
);

-- Award_type
DROP TABLE IF EXISTS Award_type CASCADE;
CREATE TABLE Award_type (
    award_type_id SERIAL PRIMARY KEY,
    award_name TEXT UNIQUE
);


-- Award
DROP TABLE IF EXISTS Award CASCADE;
CREATE TABLE Award (
    award_id SERIAL PRIMARY KEY,
    athlete_id INTEGER REFERENCES Athlete(athlete_id),
    award_date DATE,
    award_type_id INTEGER REFERENCES Award_type(award_type_id)
);

-- Position
DROP TABLE IF EXISTS Position CASCADE;
CREATE TABLE Position (
    position_id SERIAL PRIMARY KEY,
    position_type TEXT UNIQUE
);

-- Employee
DROP TABLE IF EXISTS Employee CASCADE;
CREATE TABLE Employee (
    employee_id SERIAL PRIMARY KEY,
    club_id INTEGER REFERENCES Club(club_id),
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    gender TEXT,
    phone TEXT UNIQUE,
    salary NUMERIC,
    position_id INTEGER REFERENCES Position(position_id)
);

ALTER TABLE Employee ADD CONSTRAINT chk_salary 
CHECK (salary >= 0);  

-- Match
DROP TABLE IF EXISTS Match CASCADE;
CREATE TABLE Match (
    match_id SERIAL PRIMARY KEY,
    tournament_id INTEGER REFERENCES Tournament(tournament_id),  -- Внешний ключ к турниру
    club1_id INTEGER REFERENCES Club(club_id),
    club2_id INTEGER REFERENCES Club(club_id),
    match_date DATE NOT NULL,
    match_time TIME NOT NULL,
    result_1 INTEGER,
    result_2 INTEGER
);

ALTER TABLE Match ADD CONSTRAINT chk_clubs_different 
CHECK (club1_id <> club2_id);

--Stadion
DROP TABLE IF EXISTS Stadion CASCADE;
CREATE TABLE Stadion(
	stadion_id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	address TEXT NOT NULL
);

-- Tournament
DROP TABLE IF EXISTS Tournament CASCADE;
CREATE TABLE Tournament (
    tournament_id SERIAL PRIMARY KEY,
    name TEXT,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
	stadion_id INTEGER NOT NULL REFERENCES Stadion(stadion_id),
    prize_fund NUMERIC
);

ALTER TABLE Tournament ADD CONSTRAINT chk_tournament_dates 
CHECK (start_date <= end_date);

ALTER TABLE Tournament ADD CONSTRAINT chk_prize_fund CHECK (prize_fund >= 0);

DROP TABLE IF EXISTS GamePosition CASCADE;
CREATE TABLE GamePosition (
    game_position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

ALTER TABLE Athlete 
ADD COLUMN game_position_id INTEGER REFERENCES GamePosition(game_position_id);
