\set ON_ERROR_STOP on
\pset pager off
-- Connect as lab1_admin. All demo changes are rolled back, so it is repeatable.
BEGIN;
CREATE TABLE public.lab1_grant_demo (id integer);
INSERT INTO public.lab1_grant_demo VALUES (1);
REVOKE ALL ON public.lab1_grant_demo FROM PUBLIC;
GRANT SELECT ON public.lab1_grant_demo TO lab1_delegate WITH GRANT OPTION;
SET ROLE lab1_delegate;
SELECT session_user, current_user;
GRANT SELECT ON public.lab1_grant_demo TO lab1_guest;
RESET ROLE;
SET ROLE lab1_guest;
SELECT * FROM public.lab1_grant_demo;
RESET ROLE;
SELECT grantor,grantee,privilege_type,is_grantable
FROM information_schema.role_table_grants WHERE table_name='lab1_grant_demo';
REVOKE GRANT OPTION FOR SELECT ON public.lab1_grant_demo FROM lab1_delegate CASCADE;
SELECT has_table_privilege('lab1_delegate','public.lab1_grant_demo','SELECT') AS delegate_still_reads,
 has_table_privilege('lab1_guest','public.lab1_grant_demo','SELECT') AS guest_no_longer_reads;
DO $$ BEGIN
 IF NOT has_table_privilege('lab1_delegate','public.lab1_grant_demo','SELECT')
 OR has_table_privilege('lab1_guest','public.lab1_grant_demo','SELECT') THEN
 RAISE EXCEPTION 'Cascade check failed'; END IF;
END $$;
SET ROLE lab1_guest;
DO $$ BEGIN
 BEGIN
  PERFORM * FROM public.lab1_grant_demo;
  RAISE EXCEPTION 'Unexpected SELECT success';
 EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'PASS: guest SELECT denied after CASCADE';
 END;
END $$;
RESET ROLE;
REVOKE SELECT ON public.lab1_grant_demo FROM lab1_delegate;
CREATE ROLE lab1_temporary NOLOGIN;
ALTER ROLE lab1_temporary LOGIN PASSWORD '123' CONNECTION LIMIT 1;
GRANT lab1_read TO lab1_temporary;
REVOKE lab1_read FROM lab1_temporary;
ALTER ROLE lab1_temporary NOLOGIN;
DROP ROLE lab1_temporary;
ROLLBACK;
