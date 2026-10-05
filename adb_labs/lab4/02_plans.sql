\pset pager off
-- Прямое условие: оптимизатор использует статистику столбца и может выбрать индекс.
EXPLAIN (ANALYZE,BUFFERS) SELECT * FROM lab4.plan_employee WHERE salary>100000;
-- Условие внутри функции: сравниваем оценку rows с фактическим actual rows.
EXPLAIN (ANALYZE,BUFFERS) SELECT * FROM lab4.plan_employee WHERE lab4.is_high_salary(salary);
-- Каталог подпрограмм: prokind f/p — функция/процедура, prosecdef — режим DEFINER.
SELECT p.oid::regprocedure,p.prokind,p.prosecdef,p.provolatile,p.procost,p.proconfig
-- provolatile: i — IMMUTABLE, s — STABLE, v — VOLATILE; procost — оценка стоимости вызова.
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='lab4' ORDER BY 1;
