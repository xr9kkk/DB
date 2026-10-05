import psycopg, threading, time
from pathlib import Path
# Параметры учебной базы; перед запуском выполни setup лабораторных 2–4.
DSN='host=localhost dbname=SportsClubDB user=lab1_admin password=admin'
log=[]
def note(s): log.append(s); print(s)
def conn(): return psycopg.connect(DSN,autocommit=True)
# Три независимых подключения соответствуют окнам A, B и монитору C.
a,b,c=conn(),conn(),conn()
# Долгий снимок должен сохранять старое значение после обновления из другого сеанса.
a.execute('BEGIN ISOLATION LEVEL REPEATABLE READ'); assert a.execute('SELECT balance FROM lab2.accounts WHERE id=1').fetchone()[0]==100
b.execute('UPDATE lab2.accounts SET balance=110 WHERE id=1')
assert a.execute('SELECT balance FROM lab2.accounts WHERE id=1').fetchone()[0]==100
# Через pageinspect проверяем наличие старой и новой физических версий.
versions=b.execute("SELECT lp,t_xmin,t_xmax,t_ctid FROM heap_page_items(get_raw_page('lab2.accounts',0)) WHERE lp_flags=1").fetchall()
assert len(versions)==3; note('MVCC physical tuples: '+str(versions))
b.execute('VACUUM lab2.accounts'); assert len(b.execute("SELECT * FROM heap_page_items(get_raw_page('lab2.accounts',0)) WHERE lp_flags=1").fetchall())==3
a.execute('COMMIT'); b.execute('VACUUM lab2.accounts'); assert len(b.execute("SELECT * FROM heap_page_items(get_raw_page('lab2.accounts',0)) WHERE lp_flags=1").fetchall())==2
note('PASS snapshot visibility and VACUUM horizon')
# Сравниваем повторное чтение и фантомы на двух уровнях изоляции.
for level,expected in [('READ COMMITTED',120),('REPEATABLE READ',100)]:
 b.execute('UPDATE lab2.accounts SET balance=100 WHERE id=1'); b.execute('DELETE FROM lab2.accounts WHERE id=3')
 a.execute('BEGIN ISOLATION LEVEL '+level); a.execute('SELECT * FROM lab2.accounts').fetchall()
 b.execute('UPDATE lab2.accounts SET balance=120 WHERE id=1'); b.execute('INSERT INTO lab2.accounts VALUES(3,150)')
 assert a.execute('SELECT balance FROM lab2.accounts WHERE id=1').fetchone()[0]==expected
 assert a.execute('SELECT count(*) FROM lab2.accounts').fetchone()[0]==(3 if level=='READ COMMITTED' else 2)
 if level=='REPEATABLE READ':
  try: a.execute('UPDATE lab2.accounts SET balance=130 WHERE id=1'); raise AssertionError()
  except psycopg.errors.SerializationFailure: pass
 a.execute('ROLLBACK'); note('PASS '+level+' repeat reads, phantoms')
# Проверяем правило дежурств: SERIALIZABLE не допускает выключить обоих сотрудников.
for level in ['REPEATABLE READ','SERIALIZABLE']:
 b.execute('UPDATE lab2.duty SET active=true')
 for x in [a,b]: x.execute('BEGIN ISOLATION LEVEL '+level); assert x.execute('SELECT count(*) FROM lab2.duty WHERE active').fetchone()[0]==2
 a.execute('UPDATE lab2.duty SET active=false WHERE id=1'); b.execute('UPDATE lab2.duty SET active=false WHERE id=2'); a.execute('COMMIT')
 try: b.execute('COMMIT'); assert level=='REPEATABLE READ'
 except psycopg.errors.SerializationFailure: assert level=='SERIALIZABLE'; b.execute('ROLLBACK')
 note('PASS duty '+level)
a.execute("SET application_name='lab3_A'"); b.execute("SET application_name='lab3_B'")
apid=a.info.backend_pid; bpid=b.info.backend_pid
errors=[]
# Запускаем блокирующий запрос в отдельном потоке, чтобы монитор продолжал работать.
def update(x,sql):
 try: x.execute(sql)
 except psycopg.Error as e: errors.append(e.sqlstate)
# Создаём конфликт и ждём, пока сервер подтвердит зависимость B от A.
def start_wait():
 a.execute('BEGIN'); a.execute('UPDATE lab3.accounts SET balance=balance+10 WHERE id=1'); b.execute('BEGIN')
 t=threading.Thread(target=update,args=(b,'UPDATE lab3.accounts SET balance=balance+20 WHERE id=1')); t.start()
 for _ in range(100):
  if c.execute('SELECT pg_blocking_pids(%s)',(bpid,)).fetchone()[0]==[apid]: return t
  time.sleep(.02)
 raise AssertionError('wait not seen')
# Отменяем ожидающий запрос: соединение сохраняется, транзакцию нужно откатить.
t=start_wait(); note('PASS blocking diagnostics: B waits for A'); c.execute('SELECT pg_cancel_backend(%s)',(bpid,)); t.join(5); assert not t.is_alive() and '57014' in errors; b.execute('ROLLBACK'); a.execute('ROLLBACK'); note('PASS cancel')
# Отмена запроса простаивающего держателя не освобождает его блокировку.
t=start_wait(); c.execute('SELECT pg_cancel_backend(%s)',(apid,)); assert c.execute('SELECT pg_blocking_pids(%s)',(bpid,)).fetchone()[0]==[apid]; a.execute('ROLLBACK'); t.join(5); b.execute('ROLLBACK'); note('PASS cancel idle holder retains lock')
# Завершение держателя откатывает его транзакцию и освобождает ожидающий запрос.
t=start_wait(); c.execute('SELECT pg_terminate_backend(%s)',(apid,)); t.join(5); assert not t.is_alive(); b.execute('ROLLBACK'); a.close(); a=conn(); note('PASS terminate releases lock')
# Готовим взаимоблокировку: транзакции берут две строки в противоположном порядке.
for x in [a,b]: x.execute("SET deadlock_timeout='100ms'"); x.execute('BEGIN')
a.execute('UPDATE lab3.accounts SET balance=balance+1 WHERE id=1'); b.execute('UPDATE lab3.accounts SET balance=balance+1 WHERE id=2')
t=threading.Thread(target=update,args=(a,'UPDATE lab3.accounts SET balance=balance+1 WHERE id=2')); t.start(); time.sleep(.05)
u=threading.Thread(target=update,args=(b,'UPDATE lab3.accounts SET balance=balance+1 WHERE id=1')); u.start()
for _ in range(100):
 if '40P01' in errors: break
 time.sleep(.02)
assert '40P01' in errors
# При аварийном прерывании транзакции-жертвы её блокировки строк освобождаются.
t.join(5); u.join(5); assert not t.is_alive() and not u.is_alive()
a.execute('ROLLBACK'); b.execute('ROLLBACK'); note('PASS deadlock 40P01')
# Настоящее подключение обычного пользователя для проверки INVOKER и DEFINER.
user=psycopg.connect('host=localhost dbname=SportsClubDB user=lab4_user password=123',autocommit=True)
# Возвращаем учебные данные и включаем autovacuum после проверки.
for sql in ['SELECT * FROM lab4.salary_secret','SELECT lab4.secret_invoker(1)']:
 try: user.execute(sql); raise AssertionError()
 except psycopg.errors.InsufficientPrivilege: pass
assert user.execute('SELECT lab4.secret_definer(1)').fetchone()[0]==50000; user.close(); note('PASS invoker denied, definer returns 50000')
# Проверяем прибавку зарплаты внутри транзакции, затем отменяем изменение.
e=c.execute('SELECT employee_id,salary FROM public.employee WHERE salary IS NOT NULL ORDER BY employee_id LIMIT 1').fetchone()
assert e is not None
c.execute('BEGIN'); c.execute('CALL lab4.raise_salary(%s,1000)',(e[0],)); assert c.execute('SELECT salary FROM public.employee WHERE employee_id=%s',(e[0],)).fetchone()[0]==e[1]+1000; c.execute('ROLLBACK'); note('PASS raise_salary rollback')
# Проверяем внутренний COMMIT: отдельно разрешён, внутри BEGIN вызывает 2D000.
c.execute('CALL lab4.commit_demo()'); c.execute('BEGIN')
try: c.execute('CALL lab4.commit_demo()'); raise AssertionError()
except psycopg.errors.InvalidTransactionTermination: c.execute('ROLLBACK')
note('PASS procedure COMMIT and 2D000')
# Возвращаем учебные данные и включаем autovacuum после проверки.
for sql in ['UPDATE lab2.accounts SET balance=100 WHERE id=1','DELETE FROM lab2.accounts WHERE id=3','UPDATE lab2.duty SET active=true','ALTER TABLE lab2.accounts RESET (autovacuum_enabled)','VACUUM lab2.accounts','TRUNCATE lab4.procedure_log']: c.execute(sql)
for x in [a,b,c]: x.close()
# Сохраняем результаты проверки в текстовый файл.
Path('verification_result.txt').write_text('\n'.join(log)+'\n',encoding='utf-8')
