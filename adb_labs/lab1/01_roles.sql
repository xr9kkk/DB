-- При ошибке останавливаем выполнение файла, чтобы не продолжать неполную настройку.
\set ON_ERROR_STOP on
-- Выполнить один раз от postgres в спортивной базе. Если роли уже существуют, создание откатится.
BEGIN;
CREATE ROLE lab1_admin LOGIN SUPERUSER CREATEDB CREATEROLE PASSWORD 'admin';
COMMIT;
-- Дальнейшие действия выполняются от созданного администратора lab1_admin.
\setenv PGPASSWORD admin
\connect -reuse-previous=on - lab1_admin
BEGIN;
-- Групповые роли NOLOGIN объединяют права; входить под ними нельзя.
CREATE ROLE lab1_read NOLOGIN;
CREATE ROLE lab1_hr NOLOGIN;
CREATE ROLE lab1_events NOLOGIN;
-- Роли LOGIN — пользователи, которые могут подключаться с паролем.
CREATE ROLE lab1_analyst LOGIN PASSWORD '123';
CREATE ROLE lab1_hr_user LOGIN PASSWORD '123';
CREATE ROLE lab1_events_user LOGIN PASSWORD '123';
CREATE ROLE lab1_delegate LOGIN PASSWORD '123';
CREATE ROLE lab1_guest LOGIN PASSWORD '123';

-- Выдаём членство: кадровики и регистраторы наследуют общие права чтения.
GRANT lab1_read TO lab1_hr, lab1_events;
GRANT lab1_read TO lab1_analyst;
GRANT lab1_hr TO lab1_hr_user;
GRANT lab1_events TO lab1_events_user;

-- Существующие права PUBLIC сохраняем: доступ ролям выдаём через GRANT.
GRANT USAGE ON SCHEMA public TO lab1_read, lab1_delegate, lab1_guest;
-- Формируем GRANT для текущей базы; команда psql \gexec выполняет полученный SQL.
SELECT format('GRANT CONNECT ON DATABASE %I TO lab1_read, lab1_delegate, lab1_guest', current_database()) \gexec
-- Общая группа получает чтение справочников и спортивных событий.
GRANT SELECT ON public.country, public.region, public.city, public.club,
 public.rank_title, public.award_type, public.position, public.gameposition,
 public.stadion, public.tournament, public.match TO lab1_read;
-- Кадровикам разрешаем читать, добавлять и изменять сотрудников.
GRANT SELECT, INSERT, UPDATE ON public.employee TO lab1_hr;
-- USAGE позволяет получать очередной идентификатор при INSERT в SERIAL-таблицу.
GRANT USAGE ON SEQUENCE public.employee_employee_id_seq TO lab1_hr;
-- Регистраторам разрешаем добавлять и изменять матчи и турниры.
GRANT INSERT, UPDATE ON public.match, public.tournament TO lab1_events;
GRANT USAGE ON SEQUENCE public.match_match_id_seq,
 public.tournament_tournament_id_seq TO lab1_events;
COMMIT;
