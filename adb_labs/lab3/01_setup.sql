\set ON_ERROR_STOP on
-- Отдельная схема учебных объектов для опытов с блокировками.
CREATE SCHEMA IF NOT EXISTS lab3;
-- Две строки позволяют создать конфликт на одной строке и цикл ожидания на двух.
CREATE TABLE IF NOT EXISTS lab3.accounts(id integer PRIMARY KEY,balance integer NOT NULL);
-- Возвращаем исходное состояние; перед запуском завершаем транзакции учебных окон.
TRUNCATE lab3.accounts;
INSERT INTO lab3.accounts VALUES(1,100),(2,100);
