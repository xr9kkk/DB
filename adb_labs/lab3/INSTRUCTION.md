# Лабораторная 3. Блокировки — как сдавать

## SQL Shell (psql)

Открой три окна: A, B и C (монитор) через «Пуск → PostgreSQL 18 → SQL Shell (psql)». В каждом введи Server localhost, Database SportsClubDB, Port 5432, Username lab1_admin, Password admin. После каждого поля Enter; пароль не отображается. В каждом окне:

```sql
\encoding UTF8
\pset pager off
\set VERBOSITY verbose
\cd 'D:/учеба/DB/adb_labs'
SELECT current_database(),current_user,pg_backend_pid();
```

`\pset pager off` отключает постраничный вывод, `\cd` задаёт каталог, SELECT показывает PID. SQL выполняется после `;` и Enter; команды с `\` — без `;`. `\i` выполняет файл; `\q` выходит; `\r` очищает незаконченный ввод. BEGIN открывает транзакцию, COMMIT сохраняет, ROLLBACK отменяет. После ошибки в транзакции обязательно ROLLBACK. Ctrl+C отменяет текущий запрос. Скриншоты должны содержать запрос и результат; ошибки тоже сохраняй.

## 1. Конфликт и диагностика

В C: `\i 'lab3/01_setup.sql'`. Подготовка очищает только lab3.accounts; перед повтором заверши учебные транзакции.

A: `SET application_name='lab3_A';`
B: `SET application_name='lab3_B';`
C: `SET application_name='lab3_monitor';`

1. A:

```sql
BEGIN;
UPDATE lab3.accounts SET balance=balance+10 WHERE id=1;
```

2. B:

```sql
BEGIN;
UPDATE lab3.accounts SET balance=balance+20 WHERE id=1;
```

B ждёт: приглашение psql не появляется. Не вводи следующие команды в B.

3. C: `\i 'lab3/02_monitor.sql'`.

A — idle in transaction, B — active с wait_event_type=Lock. pg_blocking_pids(B) показывает PID A. Сохрани оба диагностических запроса. RowExclusiveLock на таблице совместимы: конфликт на строке. Ожидание обычно видно как transactionid / ShareLock с granted=false. Все блокировки строк не обязаны появляться в pg_locks: часть информации хранится в tuple.

4. A: `COMMIT;`. Запрос B завершится. B: `COMMIT;`.
5. C: `SELECT * FROM lab3.accounts ORDER BY id;` — баланс id=1 равен 130.

Штатное разрешение — закончить транзакцию держателя через COMMIT/ROLLBACK. Держи транзакции короткими и не оставляй их открытыми во время ввода пользователя.

## 2. Мягкая отмена запроса

Повтори создание конфликта. C:

```sql
SELECT pg_cancel_backend(pid) FROM pg_stat_activity
WHERE datname=current_database() AND application_name='lab3_B'
AND pid<>pg_backend_pid();
```

B получает отмену запроса (57014); соединение остаётся, транзакция ошибочная. B: `ROLLBACK;`, A: `ROLLBACK;`.

Для объяснения ограничений снова создай конфликт и в C выполни:

```sql
SELECT pg_cancel_backend(pid) FROM pg_stat_activity
WHERE datname=current_database() AND application_name='lab3_A'
AND pid<>pg_backend_pid();
\i 'lab3/02_monitor.sql'
```

Простаивающее A не выполняет запрос: отмена не заканчивает его транзакцию и не снимает блокировку. B всё ещё ждёт. A: `ROLLBACK;`, затем B: `ROLLBACK;`. Возвращённое true означает отправку сигнала, а не доказательство освобождения блокировки.

## 3. Принудительное завершение сеанса

Снова создай конфликт. C:

```sql
SELECT pg_terminate_backend(pid) FROM pg_stat_activity
WHERE datname=current_database() AND application_name='lab3_A'
AND pid<>pg_backend_pid();
```

A завершается, его изменения откатываются. UPDATE B продолжается; B: `ROLLBACK;`. Покажи монитор и данные. В A восстанови соединение:

```sql
\connect SportsClubDB lab1_admin localhost 5432
SET application_name='lab3_A';
```

Если окно завершилось — открой SQL Shell заново. Эти сигналы требуют соответствующих прав; чужой superuser-сеанс может завершить только superuser. Здесь администратор лабораторной имеет нужные права, а команды выбирают только учебные сеансы.

## 4. Простой и таймауты

A:

```sql
BEGIN;
SELECT * FROM lab3.accounts WHERE id=1 FOR UPDATE;
```

C запускает монитор. transaction_age — возраст транзакции, state_age — время в текущем состоянии. A удерживает блокировку после окончания SELECT.

B:

```sql
SET lock_timeout='3s';
BEGIN;
UPDATE lab3.accounts SET balance=balance+1 WHERE id=1;
ROLLBACK;
SET lock_timeout=0;
```

Через 3 секунды — ошибка lock timeout (55P03). A: `ROLLBACK;`.

Дополнительная демонстрация в A:

```sql
SET idle_in_transaction_session_timeout='10s';
BEGIN;
SELECT 1;
```

Не вводи команды более 10 секунд: сервер завершит простаивающий сеанс. Подключись заново и снова задай application_name. Настройка была сеансовой. lock_timeout ограничивает ожидание блокировки, statement_timeout — длительность запроса, idle_in_transaction_session_timeout — простой в транзакции.

## 5. Deadlock

Оба окна подключены, открытых транзакций нет. В A и B:

```sql
SET lock_timeout=0;
SET deadlock_timeout='15s';
```

1. A: `BEGIN;` и `UPDATE lab3.accounts SET balance=balance+1 WHERE id=1;`
2. B: `BEGIN;` и `UPDATE lab3.accounts SET balance=balance+1 WHERE id=2;`
3. A: `UPDATE lab3.accounts SET balance=balance+1 WHERE id=2;` — ждёт.
4. B: `UPDATE lab3.accounts SET balance=balance+1 WHERE id=1;` — ждёт.
5. C: сразу `\i 'lab3/02_monitor.sql'` — цикл ожидания PID.

После deadlock_timeout сервер обнаруживает цикл и прерывает одну транзакцию: deadlock detected, SQLSTATE 40P01. Жертва не гарантирована. В окне с ошибкой введи ROLLBACK; второй UPDATE продолжится, в том окне тоже ROLLBACK. В обоих: `SET deadlock_timeout='1s';`.

На сдаче покажи конфликт, pg_stat_activity и pg_locks, COMMIT/ROLLBACK, отмену запроса, завершение сеанса, простой и deadlock. Объясни предотвращение: брать строки в одинаковом порядке (id=1, затем id=2), сокращать транзакции; при 40P01 повторять всю операцию. Увеличение таймаута не устраняет цикл.

Источник: [блокировки PostgreSQL 18](https://www.postgresql.org/docs/18/explicit-locking.html).
