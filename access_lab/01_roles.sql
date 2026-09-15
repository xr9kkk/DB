\set ON_ERROR_STOP on
\pset pager off
-- Initial setup: run as the existing owner of the lab database and tables,
-- with CREATEDB and CREATEROLE. All lab1_* role names must be unused.
BEGIN;
CREATE ROLE lab1_admin LOGIN NOSUPERUSER CREATEDB CREATEROLE PASSWORD 'admin';
-- The current owner needs SET permission to transfer ownership to lab1_admin.
GRANT lab1_admin TO CURRENT_USER WITH INHERIT FALSE, SET TRUE;

CREATE ROLE lab1_read NOLOGIN;
CREATE ROLE lab1_hr NOLOGIN;
CREATE ROLE lab1_events NOLOGIN;
CREATE ROLE lab1_analyst LOGIN PASSWORD '123';
CREATE ROLE lab1_hr_user LOGIN PASSWORD '123';
CREATE ROLE lab1_events_user LOGIN PASSWORD '123';
CREATE ROLE lab1_delegate LOGIN PASSWORD '123';
CREATE ROLE lab1_guest LOGIN PASSWORD '123';

GRANT lab1_read TO lab1_hr, lab1_events;
GRANT lab1_read TO lab1_analyst;
GRANT lab1_hr TO lab1_hr_user;
GRANT lab1_events TO lab1_events_user;
-- DBA can manage the lab roles and switch to them for access checks.
GRANT lab1_read, lab1_hr, lab1_events, lab1_analyst, lab1_hr_user,
 lab1_events_user, lab1_delegate, lab1_guest TO lab1_admin
 WITH ADMIN TRUE, INHERIT FALSE, SET TRUE;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO lab1_read, lab1_delegate, lab1_guest;
SELECT format('GRANT CONNECT ON DATABASE %I TO lab1_read, lab1_delegate, lab1_guest', current_database())
\gexec
REVOKE ALL ON public.country, public.region, public.city, public.club,
 public.owner, public.club_owner, public.sponsor, public.sponsor_org,
 public.sponsor_person, public.sponsorship, public.athlete, public.rank_title,
 public.rank, public.award_type, public.award, public.position, public.employee,
 public.match, public.stadion, public.tournament, public.gameposition FROM PUBLIC;

GRANT SELECT ON public.country, public.region, public.city, public.club,
 public.rank_title, public.award_type, public.position, public.gameposition,
 public.stadion, public.tournament, public.match TO lab1_read;
GRANT SELECT, INSERT, UPDATE ON public.employee TO lab1_hr;
GRANT USAGE ON SEQUENCE public.employee_employee_id_seq TO lab1_hr;
GRANT INSERT, UPDATE ON public.match, public.tournament TO lab1_events;
GRANT USAGE ON SEQUENCE public.match_match_id_seq,
 public.tournament_tournament_id_seq TO lab1_events;

-- Ownership supplies DDL and grant authority, not just data access.
GRANT USAGE, CREATE ON SCHEMA public TO lab1_admin;
SELECT format('ALTER TABLE public.%I OWNER TO lab1_admin', table_name)
FROM unnest(ARRAY['country','region','city','club','owner','club_owner',
 'sponsor','sponsor_org','sponsor_person','sponsorship','athlete','rank_title',
 'rank','award_type','award','position','employee','match','stadion',
 'tournament','gameposition']) AS lab_tables(table_name)
\gexec
-- SERIAL sequences owned by table columns follow the table owner automatically.
ALTER SCHEMA public OWNER TO lab1_admin;
SELECT format('ALTER DATABASE %I OWNER TO lab1_admin', current_database())
\gexec
SET ROLE lab1_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE lab1_admin IN SCHEMA public
 REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE lab1_admin IN SCHEMA public
 REVOKE ALL ON SEQUENCES FROM PUBLIC;
COMMIT;
RESET ROLE;
