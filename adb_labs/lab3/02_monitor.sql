\pset pager off
-- Состояние учебных сеансов: кто простаивает, кто ждёт и кто его блокирует.
SELECT pid,application_name,state,wait_event_type,wait_event,
-- Возраст транзакции помогает найти давно незавершённые операции.
 clock_timestamp()-xact_start AS transaction_age,
-- Возраст состояния — длительность текущего простоя или выполнения.
 clock_timestamp()-state_change AS state_age,backend_xmin,
-- blockers содержит PID сеансов, удерживающих нужные блокировки.
 pg_blocking_pids(pid) AS blockers,query
FROM pg_stat_activity
WHERE datname=current_database() AND application_name IN ('lab3_A','lab3_B')
ORDER BY application_name;
-- Детали блокировок; granted=false означает ожидание выдачи блокировки.
SELECT a.application_name,l.pid,l.locktype,l.mode,l.granted,
-- Показываем таблицу, положение строки и XID, если они применимы к этому типу блокировки.
 l.relation::regclass AS relation,l.page,l.tuple,l.transactionid
FROM pg_locks l JOIN pg_stat_activity a USING(pid)
WHERE a.application_name IN ('lab3_A','lab3_B')
ORDER BY a.application_name,l.granted,l.locktype;
