\set ON_ERROR_STOP on
\pset pager off
-- Подключиться как lab1_admin. В конце все изменения отменяются, демонстрацию можно повторять.
BEGIN;
-- Создаём отдельную таблицу для демонстрации передачи права чтения.
CREATE TABLE public.lab1_grant_demo (id integer);
INSERT INTO public.lab1_grant_demo VALUES (1);
-- WITH GRANT OPTION разрешает посреднику передавать SELECT другим ролям.
GRANT SELECT ON public.lab1_grant_demo TO lab1_delegate WITH GRANT OPTION;
-- Временно действуем как посредник; session_user остаётся администратором.
SET ROLE lab1_delegate;
SELECT session_user, current_user;
-- Посредник передаёт право чтения гостю.
GRANT SELECT ON public.lab1_grant_demo TO lab1_guest;
RESET ROLE;
-- Проверяем доступ от имени гостя.
SET ROLE lab1_guest;
SELECT * FROM public.lab1_grant_demo;
RESET ROLE;
SELECT grantor,grantee,privilege_type,is_grantable
FROM information_schema.role_table_grants WHERE table_name='lab1_grant_demo';
-- Отзываем только право передачи; CASCADE убирает зависимую выдачу гостю.
REVOKE GRANT OPTION FOR SELECT ON public.lab1_grant_demo FROM lab1_delegate CASCADE;
SELECT has_table_privilege('lab1_delegate','public.lab1_grant_demo','SELECT') AS delegate_still_reads,
 has_table_privilege('lab1_guest','public.lab1_grant_demo','SELECT') AS guest_no_longer_reads;
-- Проверяем ожидаемый результат; неверное поведение вызывает исключение.
DO $$ BEGIN
 IF NOT has_table_privilege('lab1_delegate','public.lab1_grant_demo','SELECT')
 OR has_table_privilege('lab1_guest','public.lab1_grant_demo','SELECT') THEN
 RAISE EXCEPTION 'Cascade check failed'; END IF;
END $$;
-- Проверяем доступ от имени гостя.
SET ROLE lab1_guest;
-- Проверяем ожидаемый результат; неверное поведение вызывает исключение.
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
-- Демонстрируем создание, изменение, выдачу членства и удаление временной роли.
CREATE ROLE lab1_temporary NOLOGIN;
ALTER ROLE lab1_temporary LOGIN PASSWORD '123' CONNECTION LIMIT 1;
GRANT lab1_read TO lab1_temporary;
REVOKE lab1_read FROM lab1_temporary;
ALTER ROLE lab1_temporary NOLOGIN;
DROP ROLE lab1_temporary;
-- Отменяем все учебные изменения, включая создание таблицы и выдачу прав.
ROLLBACK;
