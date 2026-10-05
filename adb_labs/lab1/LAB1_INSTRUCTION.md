# Лабораторная 1 — исправленная инструкция сдачи

В 01_roles.sql удалены отзывы прав у PUBLIC на схему, таблицы и default privileges.
В 03_delegation.sql также убран отзыв у PUBLIC. Существующие права сохраняются.
Ранее выполненные отзывы нельзя точно обратить без исходных ACL. Текущие права
не восстановлены наугад через GRANT ALL: это выдало бы всем дополнительные права.
Исправленный установочный файл сохраняет исходные ACL при установке.

## SQL Shell (psql)

Открой «Пуск → PostgreSQL 18 → SQL Shell (psql)». Введи Server localhost,
Database SportsClubDB, Port 5432, Username lab1_admin, Password admin.
После каждого поля нажми Enter. Пароль не отображается. Внутри psql:

```sql
\encoding UTF8
\pset pager off
\cd 'D:/учеба/DB/adb_labs/lab1'
SELECT current_database(),session_user,current_user;
```

SQL заканчивается `;`, команды с `\` — без неё. После команды Enter.
`\pset pager off` отключает постраничный вывод; `\cd` меняет каталог;
`\i` выполняет файл; `\q` выходит; `\r` очищает незаконченный ввод.
BEGIN открывает транзакцию, COMMIT сохраняет, ROLLBACK отменяет.
После ошибки внутри транзакции введи ROLLBACK. Для сдачи сохраняй скриншоты.

## Роли и метаданные

Роли уже существуют: не запускай 01_roles.sql повторно в текущей базе.
Для первоначальной установки на исходной копии базы подключись как postgres,
выполни `\i '01_roles.sql'`: файл создаст DBA и переключится на него.
Для сдачи под lab1_admin:

```sql
\du lab1_*
\i '02_metadata.sql'
\dp public.employee
\dn+ public
```

pg_roles — атрибуты ролей; pg_auth_members — членство;
role_table_grants — явные права; has_table_privilege — эффективные права,
включая наследование и PUBLIC. `\dp` показывает ACL объектов.
Группы NOLOGIN: lab1_read → lab1_hr → lab1_hr_user;
lab1_read → lab1_events → lab1_events_user; lab1_read → lab1_analyst.
Стрелка означает GRANT роли слева роли справа. DBA — superuser всего кластера.

## Реальные входы

В отдельном SQL Shell подключись под lab1_analyst, пароль 123:

```sql
SELECT session_user,current_user;
SELECT * FROM public.club LIMIT 3;
SELECT * FROM public.employee LIMIT 3;
SET ROLE lab1_admin;
```

club читается; employee и повышение роли запрещены в текущей базе.
Под lab1_hr_user, пароль 123:

```sql
SELECT * FROM public.club LIMIT 3;
BEGIN;
INSERT INTO public.employee(last_name,first_name,salary) VALUES('LAB1','Test',100);
UPDATE public.employee SET salary=101 WHERE last_name='LAB1';
ROLLBACK;
DELETE FROM public.employee WHERE false;
```

INSERT/UPDATE разрешены, DELETE запрещён даже при WHERE false.
Под lab1_events_user, пароль 123:

```sql
SELECT * FROM public.match LIMIT 3;
BEGIN;
INSERT INTO public.match(match_date,match_time) VALUES(CURRENT_DATE,TIME '12:00');
ROLLBACK;
SELECT * FROM public.employee LIMIT 1;
DELETE FROM public.match WHERE false;
```

Чтение и добавление матчей разрешены, employee и DELETE запрещены.
Отказы предполагают отсутствие дополнительных прав через PUBLIC/другие роли.
В PostgreSQL нет DENY: отзыв у одной роли не отменяет доступ из другого источника.
CREATE в public теперь зависит от существующих ACL, обязательный отказ не требуется.
INSERT на SERIAL-таблицу требует USAGE на последовательность.
SET ROLE меняет current_user; новый вход меняет также session_user.

## Делегирование

Вернись в администраторское окно:

```sql
\i '03_delegation.sql'
```

WITH GRANT OPTION позволяет посреднику выдать SELECT гостю.
REVOKE GRANT OPTION ... CASCADE удаляет зависимую выдачу гостю, сохраняя SELECT
у посредника. Файл проверяет результат, показывает CREATE/ALTER/DROP ROLE,
откатывает демонстрацию целиком. WITH ADMIN OPTION — членство в роли,
WITH GRANT OPTION — право на объект. DROP ROLE требует устранить зависимости.

## Проверка

Выйди через `\q`. В PowerShell (не внутри psql):

```powershell
cd 'D:\учеба\DB\adb_labs\lab1'
powershell -NoProfile -ExecutionPolicy Bypass -File .\04_check.ps1
```

Теперь проверок 17: проверка обязательного отказа CREATE удалена.
Отказ подтверждается SQLSTATE 42501. Изменения откатываются, SERIAL может продвинуться.
metadata_result.txt содержит прежний вывод; обновить в администраторском psql:

```sql
\o 'metadata_result.txt'
\i '02_metadata.sql'
\o
```

`\o` направляет вывод в файл, повторная команда возвращает на экран.
На сдаче покажи роли, членство, эффективные права, настоящие входы,
делегирование и CASCADE; объясни наследование и права последовательностей.
