  \set ON_ERROR_STOP on
  \pset pager off

  BEGIN;
  DO $$
  BEGIN
  IF session_user <> 'lab1_admin' OR current_user <> 'lab1_admin' THEN
    RAISE EXCEPTION 'Connect directly as lab1_admin';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = current_user
              AND (rolsuper OR NOT rolcreaterole OR rolbypassrls)) THEN
    RAISE EXCEPTION 'lab1_admin must be NOSUPERUSER NOBYPASSRLS CREATEROLE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_database
                  WHERE datname = current_database()
                    AND datdba = (SELECT oid FROM pg_roles WHERE rolname = current_user))
  OR NOT has_schema_privilege(current_user, 'public', 'CREATE') THEN
    RAISE EXCEPTION 'lab1_admin must own this database and have CREATE on public';
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname IN ('country','region','city','club','owner','club_owner',
      'sponsor','sponsor_org','sponsor_person','sponsorship','athlete','rank_title',
      'rank','award_type','award','position','employee','match','stadion',
      'tournament','gameposition','employee_employee_id_seq','match_match_id_seq',
      'tournament_tournament_id_seq')
      AND c.relowner <> (SELECT oid FROM pg_roles WHERE rolname = current_user)
  ) THEN
    RAISE EXCEPTION 'lab1_admin must own the listed lab tables and sequences';
  END IF;
  END $$;

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
  GRANT lab1_delegate, lab1_guest TO lab1_admin WITH INHERIT FALSE, SET TRUE;

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
  ALTER DEFAULT PRIVILEGES FOR ROLE lab1_admin IN SCHEMA public
  REVOKE ALL ON TABLES FROM PUBLIC;
  ALTER DEFAULT PRIVILEGES FOR ROLE lab1_admin IN SCHEMA public
  REVOKE ALL ON SEQUENCES FROM PUBLIC;
  COMMIT;
