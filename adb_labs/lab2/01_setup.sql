\set ON_ERROR_STOP on
\pset pager off
-- Учебные объекты размещаем отдельно от основных таблиц спортивной базы.
CREATE SCHEMA IF NOT EXISTS lab2;
-- pageinspect позволяет увидеть физические версии строк на странице таблицы.
CREATE EXTENSION IF NOT EXISTS pageinspect;
-- Два учебных счёта используются для наблюдения снимков и обновлений.
CREATE TABLE IF NOT EXISTS lab2.accounts(id integer PRIMARY KEY, balance integer NOT NULL);
-- Временно отключаем автоматическую очистку, чтобы версии не исчезли до демонстрации.
ALTER TABLE lab2.accounts SET (autovacuum_enabled=false);
-- Очищаем только учебную таблицу и возвращаем исходные данные.
TRUNCATE lab2.accounts;
INSERT INTO lab2.accounts VALUES(1,100),(2,100);
-- Дежурства показывают правило: хотя бы один сотрудник должен остаться активным.
CREATE TABLE IF NOT EXISTS lab2.duty(id integer PRIMARY KEY, active boolean NOT NULL);
TRUNCATE lab2.duty;
INSERT INTO lab2.duty VALUES(1,true),(2,true);
