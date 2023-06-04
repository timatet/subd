-- ЛАБОРАТОРНАЯ 8. ТРАНЗАКЦИИ

-- Выполнение транзакций с уровнем изоляции 
-- READ UNCOMMITTED

-- 1-ая транзакция (1)
SET TRANSACTION ISOLATION LEVEL 
READ UNCOMMITTED
BEGIN TRANSACTION

UPDATE tours 
SET tour_name = N'Пешком по золотому кольцу'
WHERE tour_name = N'Прогулка по золотому кольцу'

COMMIT

-- Проверка изменения данных для транзакций с уровнем изоляции 
-- READ UNCOMMITTED

-- 1-ая транзакция (2)
SET TRANSACTION ISOLATION LEVEL 
READ UNCOMMITTED
BEGIN TRANSACTION

SELECT * FROM tours t

SELECT * FROM tours t

SELECT * FROM tours t

COMMIT

-- Проверка изменения данных для транзакций с уровнем изоляции 
-- READ COMMITTED

-- 1-ая транзакция (3)
SET TRANSACTION ISOLATION LEVEL 
READ COMMITTED
BEGIN TRANSACTION

SELECT * FROM tours t

SELECT * FROM tours t

SELECT * FROM tours t

COMMIT

-- Попытка обновления данных во 2-ой транзакции до 
-- завершения 1-ой

-- 1-ая транзакция (4)
SET TRANSACTION ISOLATION LEVEL 
READ COMMITTED
BEGIN TRANSACTION

SELECT * FROM tours t

SELECT * FROM tours t

COMMIT

-- Проверка изменения данных для транзакций с уровнем изоляции 
-- REPEATABLE READ

-- 1-ая транзакция (5)
SET TRANSACTION ISOLATION LEVEL 
READ COMMITTED
REPEATABLE READ
BEGIN TRANSACTION

SELECT * FROM tours t

SELECT * FROM tours t

COMMIT

-- Попытка вставки "фантомных" записей

-- 1-ая транзакция (6)
SET TRANSACTION ISOLATION LEVEL 
REPEATABLE READ
BEGIN TRANSACTION

SELECT * FROM tours t
WHERE tour_cost < 7000

SELECT * FROM tours t
WHERE tour_cost < 7000

COMMIT

-- Проверка изменения данных для транзакций с уровнем изоляции 
-- SERIALIZABLE

-- 1-ая транзакция (7)
SET TRANSACTION ISOLATION LEVEL 
SERIALIZABLE
BEGIN TRANSACTION

SELECT * FROM tours t
WHERE tour_cost < 7000

SELECT * FROM tours t
WHERE tour_cost < 7000

COMMIT