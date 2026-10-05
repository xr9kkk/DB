# Лабораторная 4. Хранимые подпрограммы — как сдавать

## SQL Shell (psql)

Открой «Пуск → PostgreSQL 18 → SQL Shell (psql)». Заполни Server localhost, Database SportsClubDB, Port 5432, Username lab1_admin, Password admin. После каждого поля Enter. Пароль не отображается.

```sql
\encoding UTF8
\pset pager off
\set VERBOSITY verbose
\cd 'D:/учеба/DB/adb_labs'
SELECT current_database(),current_user;
```

`\pset pager off` отключает постраничный вывод; `\cd` меняет каталог; `\i` выполняет файл. SQL заканчивается `;`, команды с `\` — без неё. Нажимай Enter после законченной команды. `\q` закрывает подключение, `\r` очищает незаконченный ввод. BEGIN открывает транзакцию, COMMIT сохраняет, ROLLBACK отменяет; после ошибки в транзакции введи ROLLBACK. Для отчёта сохраняй скриншоты запросов, результатов и ожидаемых ошибок. `\o 'lab4/plans.txt'` направляет вывод в файл, `\o` возвращает на экран.

## 1. Создание и просмотр

Выполни `\i 'lab4/01_setup.sql'`. Скрипт создаёт подпрограммы, роль lab4_user (123) и учебные данные для планов. Зарплаты существующих работников не меняются. При повторном запуске существующий пароль роли сохраняется, учебная таблица планов заполняется заново.

```sql
\df+ lab4.*
\sf lab4.employee_salary
\sf lab4.raise_salary
SELECT employee_id,salary,lab4.employee_salary(employee_id)
FROM public.employee ORDER BY employee_id LIMIT 5;
```

`\df+` показывает свойства, `\sf` — определение подпрограммы. employee_salary возвращает зарплату по id, при отсутствии работника — NULL. PL/pgSQL позволяет переменные, условия, исключения и несколько SQL-команд.

## 2. INVOKER и DEFINER

Администратор:

```sql
SELECT has_table_privilege('lab4_user','lab4.salary_secret','SELECT');
SELECT has_function_privilege('lab4_user','lab4.secret_definer(integer)','EXECUTE');
```

Ожидается false и true. Открой ещё один SQL Shell, база SportsClubDB, Username lab4_user, Password 123. В нём по одной команде, вне BEGIN:

```sql
SELECT session_user,current_user;
SELECT * FROM lab4.salary_secret;
SELECT lab4.secret_invoker(1);
SELECT lab4.secret_definer(1);
```

Таблица и invoker дают permission denied, definer возвращает 50000. INVOKER проверяет права вызывающего; DEFINER исполняет тело с правами владельца (здесь lab1_admin). Пользователь имеет доступ к результату узкой функции без SELECT на таблицу.

В реальном сервисе владельцу нужны минимальные права, superuser избыточен; нужно также проверять, чью зарплату пользователь может читать. Учебная функция такой проверки не содержит. Фиксированный search_path=pg_catalog,pg_temp и полные имена таблиц защищают от подмены объектов. EXECUTE отозван у PUBLIC только для двух новых функций и выдан lab4_user: общего отзыва прав нет. По умолчанию EXECUTE новых функций доступен PUBLIC. Закрой пользовательское окно: `\q`.

## 3. Планы и неверная оценка селективности

Администратор: `\i 'lab4/02_plans.sql'`.

Обычный предикат salary>100000 виден оптимизатору: используется статистика salary и обычно индекс. Фактически подходящих строк 100. С PL/pgSQL-функцией условие скрыто: обычно Seq Scan, оценка около 33333 строк при actual rows=100. Сравни rows и actual rows, cost, Execution Time, Buffers, Rows Removed by Filter. Сохрани оба плана.

Выбор плана и оценки зависят от статистики и настроек. cost — условные единицы, actual time — измеренное время. IMMUTABLE не раскрывает тело PL/pgSQL оптимизатору. COST оценивает один вызов, а не селективность. ANALYZE собирает статистику таблицы. Скрытый фильтр вызывает функцию для множества строк; индекс salary напрямую ему не помогает. Простые фильтры лучше писать обычным SQL; SQL-функции при подходящих условиях могут встраиваться. EXPLAIN ANALYZE выполняет запрос — здесь запросы только читают.

## 4. Процедура для своей базы

Администратор:

```sql
SELECT employee_id AS demo_id FROM public.employee WHERE salary IS NOT NULL ORDER BY employee_id LIMIT 1 \gset
BEGIN;
SELECT salary FROM public.employee WHERE employee_id=:demo_id;
CALL lab4.raise_salary(:demo_id,1000);
SELECT salary FROM public.employee WHERE employee_id=:demo_id;
ROLLBACK;
```

`\gset` сохраняет результат в переменную psql, `:demo_id` подставляет её. Зарплата временно увеличивается на 1000; ROLLBACK возвращает её. Если employee пустая, сначала добавь сотрудника по схеме базы; если зарплата NULL, выбери сотрудника с ненулевой зарплатой. Процедура проверяет положительную прибавку и существование работника, вызывается CALL; функция вызывается SELECT.

## 5. Управление транзакцией

Вне BEGIN:

```sql
CALL lab4.commit_demo();
SELECT * FROM lab4.procedure_log;
```

Процедура вставляет сообщение и выполняет внутренний COMMIT. Затем:

```sql
BEGIN;
CALL lab4.commit_demo();
ROLLBACK;
```

Ошибка invalid transaction termination (2D000): внутренний COMMIT недопустим внутри явного блока транзакции. Вставка второго вызова откатывается. Функция не может делать COMMIT/ROLLBACK; процедура может при подходящем контексте (верхнеуровневый CALL). SECURITY DEFINER-процедуры и процедуры с SET-параметрами не могут управлять транзакциями.

На сдаче покажи определения, функции своей базы, реальный вход lab4_user, различие режимов прав, два плана, временную прибавку и внутренний COMMIT. Функции удобны для повторного использования вычислений и проверок; вызовы на каждой строке могут ухудшить план. Процедуры удобны для самостоятельных операций. DEFINER требует ограниченного EXECUTE, безопасного search_path и минимальных прав владельца.

Источники: [CREATE FUNCTION](https://www.postgresql.org/docs/18/sql-createfunction.html), [CREATE PROCEDURE](https://www.postgresql.org/docs/18/sql-createprocedure.html).
