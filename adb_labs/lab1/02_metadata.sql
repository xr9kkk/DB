\set ON_ERROR_STOP on
\pset pager off
-- Проверяем, к какой базе подключились и от чьего имени выполняются команды.
SELECT current_database(), session_user, current_user;
-- Показываем атрибуты учебных ролей: вход, права администратора и наследование.
SELECT rolname, rolcanlogin, rolsuper, rolcreatedb, rolcreaterole, rolinherit
FROM pg_roles WHERE rolname LIKE 'lab1\_%' ESCAPE '\' ORDER BY rolname;
-- Показываем членство: какая роль выдана какому пользователю или группе.
SELECT parent.rolname AS granted_role, child.rolname AS member,
 m.admin_option, m.inherit_option, m.set_option
FROM pg_auth_members m JOIN pg_roles parent ON parent.oid=m.roleid
JOIN pg_roles child ON child.oid=m.member
WHERE parent.rolname LIKE 'lab1\_%' ESCAPE '\' ORDER BY 1,2;
-- Показываем явные табличные права и возможность передавать их другим.
SELECT grantor, grantee, table_schema, table_name, privilege_type, is_grantable
FROM information_schema.role_table_grants
WHERE grantee LIKE 'lab1\_%' ESCAPE '\' ORDER BY grantee,table_name,privilege_type;
-- Проверяем эффективные права с учётом наследования, PUBLIC и superuser.
SELECT r.rolname, t.tablename,
 has_table_privilege(r.oid, format('%I.%I',t.schemaname,t.tablename),'SELECT') AS can_select,
 has_table_privilege(r.oid, format('%I.%I',t.schemaname,t.tablename),'INSERT') AS can_insert,
 has_table_privilege(r.oid, format('%I.%I',t.schemaname,t.tablename),'UPDATE') AS can_update,
 has_table_privilege(r.oid, format('%I.%I',t.schemaname,t.tablename),'DELETE') AS can_delete
FROM pg_roles r CROSS JOIN pg_tables t
WHERE r.rolname LIKE 'lab1\_%' ESCAPE '\' AND r.rolcanlogin
AND t.schemaname='public' AND t.tablename IN ('club','employee','match','owner')
ORDER BY 1,2;
-- Команда psql \dp показывает список прав таблицы и последовательности.
\dp public.employee
-- Команда psql \dp показывает список прав таблицы и последовательности.
\dp public.employee_employee_id_seq
