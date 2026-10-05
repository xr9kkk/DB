# Лабораторная 2. Многоверсионность — как сдавать

## Открытие SQL Shell (psql)

Открой два окна через «Пуск → PostgreSQL 18 → SQL Shell (psql)». Назовём их A и B. В каждом введи: Server — localhost, Database — SportsClubDB, Port — 5432, Username — lab1_admin, Password — admin. После каждого поля нажми Enter. Пароль не отображается. Все окна подключаются к одной базе.

В каждом окне введи:

```sql
\encoding UTF8
\pset pager off
\set VERBOSITY verbose
\cd 'D:/учеба/DB/adb_labs'
SELECT current_database(),current_user,pg_backend_pid();
```

`\encoding` задаёт кодировку, `\pset pager off` отключает постраничный вывод, `\cd` меняет каталог psql. SELECT подтверждает базу, пользователя и PID. SQL заканчивается `;`, команды с `\` — без неё. Enter запускает законченный ввод. `\i` выполняет файл, `\q` закрывает окно, `\r` очищает незаконченный ввод. `BEGIN` открывает транзакцию, `COMMIT` сохраняет изменения, `ROLLBACK` отменяет. После ошибки в транзакции введи `ROLLBACK;`.

Не вставляй команды разных окон одним блоком: выполняй шаги по порядку. Сохраняй скриншоты запросов вместе с выводом, особенно ожидаемых ошибок. Для вывода в файл: `\o 'lab2/result.txt'`, обратно на экран: `\o`.

## 1. Подготовка и изменение уровня

В A: `\i 'lab2/01_setup.sql'`. Скрипт очищает только учебные таблицы lab2; перед повтором закрой транзакции в обоих окнах. pageinspect требует администратора.

В A:

```sql
SHOW default_transaction_isolation;
SHOW transaction_isolation;
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW transaction_isolation;
ROLLBACK;
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

SHOW показывает уровень по умолчанию и текущий. SET TRANSACTION меняет только текущую транзакцию, до первого запроса данных. SET SESSION задаёт уровень последующих транзакций подключения.

## 2. Несколько версий строки и горизонт очистки

1. A:

```sql
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT ctid,xmin,xmax,* FROM lab2.accounts WHERE id=1;
```

2. B:

```sql
BEGIN;
UPDATE lab2.accounts SET balance=110 WHERE id=1;
SELECT ctid,xmin,xmax,* FROM lab2.accounts WHERE id=1;
```

3. A: повтори SELECT из шага 1. Баланс 100, незавершённое изменение B невидимо.
4. B: `COMMIT;`, затем `\i 'lab2/02_versions.sql'`.
5. A: снова тот же SELECT. Всё ещё 100, а B видит 110.
6. B:

```sql
SELECT pid,state,backend_xmin,xact_start FROM pg_stat_activity
WHERE datname=current_database() AND backend_xmin IS NOT NULL;
VACUUM VERBOSE lab2.accounts;
\i 'lab2/02_versions.sql'
```

7. A: `COMMIT;`. B: снова `VACUUM VERBOSE lab2.accounts;`, затем файл версий.

До окончания A на странице есть старая и новая версии id=1. Обычный SELECT показывает только видимую версию; heap_page_items показывает физические элементы, включая невидимые. `lp_flags=1` — обычный элемент с tuple. После очистки старая версия может стать redirect/unused, её t_xmin/t_xmax — NULL. Номера XID и ctid зависят от запуска.

`xmin` — XID создателя версии. UPDATE создаёт новую версию, а в старой записывает `xmax` обновляющей транзакции. `ctid` — положение (страница, элемент), оно меняется и не заменяет первичный ключ. `xmax` также может обозначать блокировку или MultiXact: ненулевой xmax не доказывает удаление или успешный COMMIT.

Долгий снимок A удерживает необходимые старые версии и ограничивает горизонт VACUUM. После COMMIT они становятся кандидатами на очистку. Другие сеансы и репликация тоже могут удерживать горизонт. Не всякая простаивающая транзакция держит снимок: смотри backend_xmin. Сохрани вывод до и после очистки.

## 3. READ COMMITTED: неповторяемое чтение и фантом

B вне транзакции:

```sql
UPDATE lab2.accounts SET balance=100 WHERE id=1;
DELETE FROM lab2.accounts WHERE id=3;
```

A:

```sql
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM lab2.accounts WHERE id=1;
SELECT * FROM lab2.accounts WHERE balance>=100 ORDER BY id;
```

B:

```sql
BEGIN;
UPDATE lab2.accounts SET balance=120 WHERE id=1;
INSERT INTO lab2.accounts VALUES(3,150);
COMMIT;
```

A повторяет оба SELECT, затем `COMMIT;`. Было 100, стало 120 — неповторяемое чтение; появился id=3 — фантом. Каждый запрос получает новый снимок.

## 4. REPEATABLE READ

Повтори раздел 3, включая восстановление исходных данных в B, но в A используй `BEGIN ISOLATION LEVEL REPEATABLE READ;`. Повторные SELECT сохраняют 100 и набор без id=3. Вместо завершающего COMMIT в A:

```sql
UPDATE lab2.accounts SET balance=130 WHERE id=1;
ROLLBACK;
```

Ожидается 40001: строка изменена после снимка A. В PostgreSQL REPEATABLE READ предотвращает и фантомы; стандарт допускает их на этом уровне. Снимок фиксируется первым запросом данных, не просто BEGIN.

## 5. SERIALIZABLE: ошибка сериализации

Правило: хотя бы один сотрудник дежурит. B вне транзакции: `UPDATE lab2.duty SET active=true;`.

1. A: `BEGIN ISOLATION LEVEL SERIALIZABLE;`
2. B: `BEGIN ISOLATION LEVEL SERIALIZABLE;`
3. A: `SELECT count(*) FROM lab2.duty WHERE active;`
4. B: тот же SELECT. В обоих окнах 2.
5. A: `UPDATE lab2.duty SET active=false WHERE id=1;`
6. B: `UPDATE lab2.duty SET active=false WHERE id=2;`
7. A: `COMMIT;`
8. B: `COMMIT;` При ошибке введи `ROLLBACK;`.

Одна транзакция отклоняется с 40001; ошибка возможна при UPDATE или COMMIT. Покажи `SELECT * FROM lab2.duty ORDER BY id;`: остаётся дежурный.

Повтори шаги с REPEATABLE READ, сначала восстановив active=true. Обе транзакции сохраняются, дежурных 0: write skew, аномалия сериализации. При 40001 нужно повторять всю транзакцию вместе с проверкой правила.

## Что показать преподавателю

Покажи версии и xmin/xmax, разные снимки A/B, очистку после окончания A, SHOW/SET, фантом и неповторяемое чтение, ошибку 40001 и сравнение дежурств. READ UNCOMMITTED работает как READ COMMITTED: грязного чтения нет. SERIALIZABLE предотвращает аномалии сериализации за счёт возможных отказов и повторов.

После сдачи заверши транзакции, в B:

```sql
UPDATE lab2.duty SET active=true;
ALTER TABLE lab2.accounts RESET (autovacuum_enabled);
VACUUM lab2.accounts;
```

Setup при следующем запуске снова отключает autovacuum только на учебной таблице.

Источники: [изоляция PostgreSQL 18](https://www.postgresql.org/docs/18/transaction-iso.html), [pageinspect](https://www.postgresql.org/docs/18/pageinspect.html).
