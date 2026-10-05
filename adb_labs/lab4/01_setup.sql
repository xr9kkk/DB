\set ON_ERROR_STOP on
-- Создаём объекты одной транзакцией: при ошибке незавершённые изменения можно откатить.
BEGIN;
CREATE SCHEMA IF NOT EXISTS lab4;
-- Создаём учебного пользователя только при его отсутствии; существующий пароль не меняем.
DO $$ BEGIN
 IF NOT EXISTS(SELECT FROM pg_roles WHERE rolname='lab4_user') THEN
  CREATE ROLE lab4_user LOGIN PASSWORD '123';
 END IF;
END $$;
-- Отдельная таблица для проверки доступа к зарплате через функции.
CREATE TABLE IF NOT EXISTS lab4.salary_secret(id integer PRIMARY KEY,salary numeric NOT NULL);
INSERT INTO lab4.salary_secret VALUES(1,50000) ON CONFLICT(id) DO UPDATE SET salary=excluded.salary;
GRANT USAGE ON SCHEMA lab4 TO lab4_user;
-- Функция своей базы возвращает зарплату сотрудника; отсутствие строки даёт NULL.
CREATE OR REPLACE FUNCTION lab4.employee_salary(p_id integer) RETURNS numeric
LANGUAGE plpgsql STABLE SECURITY INVOKER AS $$
DECLARE result numeric;
BEGIN SELECT salary INTO result FROM public.employee WHERE employee_id=p_id;
RETURN result; END $$;
-- INVOKER: доступ к таблице проверяется по правам вызывающего пользователя.
CREATE OR REPLACE FUNCTION lab4.secret_invoker(p_id integer) RETURNS numeric
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path=pg_catalog,pg_temp AS $$
BEGIN RETURN (SELECT salary FROM lab4.salary_secret WHERE id=p_id); END $$;
-- DEFINER: тело выполняется с правами владельца; имена объектов и search_path фиксированы.
CREATE OR REPLACE FUNCTION lab4.secret_definer(p_id integer) RETURNS numeric
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,pg_temp AS $$
BEGIN RETURN (SELECT salary FROM lab4.salary_secret WHERE id=p_id); END $$;
-- Ограничиваем EXECUTE только для этих двух новых функций; остальные права PUBLIC сохраняются.
REVOKE EXECUTE ON FUNCTION lab4.secret_invoker(integer),lab4.secret_definer(integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION lab4.secret_invoker(integer),lab4.secret_definer(integer) TO lab4_user;
-- Учебные данные для планов: 100 высоких зарплат среди 100000 строк.
CREATE TABLE IF NOT EXISTS lab4.plan_employee(id integer PRIMARY KEY,salary integer NOT NULL);
TRUNCATE lab4.plan_employee;
INSERT INTO lab4.plan_employee SELECT n,CASE WHEN n<=100 THEN 200000 ELSE 10000 END
FROM generate_series(1,100000) n;
-- Индекс позволяет быстро найти редкие высокие зарплаты по обычному SQL-условию.
CREATE INDEX IF NOT EXISTS plan_employee_salary_idx ON lab4.plan_employee(salary);
-- Собираем статистику распределения значений для оптимизатора.
ANALYZE lab4.plan_employee;
-- Условие скрыто в PL/pgSQL: оптимизатор не видит сравнение зарплаты напрямую.
CREATE OR REPLACE FUNCTION lab4.is_high_salary(p_salary integer) RETURNS boolean
LANGUAGE plpgsql IMMUTABLE STRICT COST 100 AS $$
BEGIN RETURN p_salary>100000; END $$;
-- Процедура вызывается через CALL и повышает зарплату существующего работника.
CREATE OR REPLACE PROCEDURE lab4.raise_salary(p_id integer,p_delta numeric)
LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
-- Отклоняем неположительную прибавку.
 IF p_delta<=0 THEN RAISE EXCEPTION 'delta must be positive'; END IF;
 UPDATE public.employee SET salary=salary+p_delta WHERE employee_id=p_id;
-- Если UPDATE не нашёл сотрудника, сообщаем об ошибке.
 IF NOT FOUND THEN RAISE EXCEPTION 'employee not found: %',p_id; END IF;
END $$;
CREATE TABLE IF NOT EXISTS lab4.procedure_log(message text NOT NULL);
-- Внутренний COMMIT разрешён при CALL вне явного блока BEGIN/COMMIT.
CREATE OR REPLACE PROCEDURE lab4.commit_demo()
LANGUAGE plpgsql AS $$
BEGIN INSERT INTO lab4.procedure_log VALUES('Committed inside procedure'); COMMIT; END $$;
COMMIT;
