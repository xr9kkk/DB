\set ON_ERROR_STOP on
-- Run once as postgres, connected to the sports database. Existing roles cause rollback.
BEGIN;
CREATE ROLE lab1_admin LOGIN SUPERUSER CREATEDB CREATEROLE PASSWORD 'admin';
COMMIT;
-- All further administration is performed as the new DBA.
\setenv PGPASSWORD admin
\connect -reuse-previous=on - lab1_admin
BEGIN;
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

-- PUBLIC is implicit membership of every user. No explicit deny exists in PostgreSQL.
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO lab1_read, lab1_delegate, lab1_guest;
SELECT format('GRANT CONNECT ON DATABASE %I TO lab1_read, lab1_delegate, lab1_guest', current_database()) \gexec
-- Only the original business tables; other labs' tables are not granted.
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
-- New objects are closed until an explicit business decision grants access.
ALTER DEFAULT PRIVILEGES FOR ROLE lab1_admin IN SCHEMA public
 REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE lab1_admin IN SCHEMA public
 REVOKE ALL ON SEQUENCES FROM PUBLIC;
COMMIT;
\echo Roles and business privileges installed.
