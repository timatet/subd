-- ЛАБОРАТОРНАЯ 8. ТРАНЗАКЦИИ

-- Выполнение транзакций с уровнем изоляции 
-- READ UNCOMMITTED

-- 2-ая транзакция (1)
SET TRANSACTION ISOLATION LEVEL 
READ UNCOMMITTED
BEGIN TRANSACTION

UPDATE tours 
SET tour_cost += 100
WHERE tour_name = N'Пешком по золотому кольцу'
COMMIT

-- Проверка изменения данных для транзакций с уровнем изоляции 
-- READ UNCOMMITTED

-- 2-ая транзакция (2)
SET TRANSACTION ISOLATION LEVEL 
READ UNCOMMITTED
BEGIN TRANSACTION

UPDATE tours 
SET tour_name = N'Прогулка по золотому кольцу'
WHERE tour_name = N'Пешком по золотому кольцу'

ROLLBACK

-- Проверка изменения данных для транзакций с уровнем изоляции 
-- READ COMMITTED

-- 2-ая транзакция (3)
SET TRANSACTION ISOLATION LEVEL 
READ COMMITTED
BEGIN TRANSACTION

UPDATE tours 
SET tour_name = N'Пешком по золотому кольцу'
WHERE tour_name = N'Прогулка по золотому кольцу'

ROLLBACK

-- Попытка обновления данных во 2-ой транзакции до 
-- завершения 1-ой

-- 2-ая транзакция (4)
SET TRANSACTION ISOLATION LEVEL 
READ COMMITTED
BEGIN TRANSACTION

UPDATE tours 
SET tour_name = N'Пешком по золотому кольцу'
WHERE tour_name = N'Прогулка по золотому кольцу'
COMMIT

-- Проверка изменения данных для транзакций с уровнем изоляции 
-- REPEATABLE READ

-- 2-ая транзакция (5)
SET TRANSACTION ISOLATION LEVEL 
READ COMMITTED
BEGIN TRANSACTION

UPDATE tours 
SET tour_name = N'Пешком по золотому кольцу'
WHERE tour_name = N'Прогулка по золотому кольцу'
COMMIT

-- Попытка вставки "фантомных" записей

-- 2-ая транзакция (6)
SET TRANSACTION ISOLATION LEVEL 
REPEATABLE READ
BEGIN TRANSACTION

INSERT INTO tours 
(tour_name, tour_cost, tour_food_type, tour_duration, state_id)
VALUES
(N'Тур в Рыбинск', 6000, 'RO', 5, 2)
COMMIT

-- Проверка изменения данных для транзакций с уровнем изоляции 
-- SERIALIZABLE

-- 2-ая транзакция (7)
SET TRANSACTION ISOLATION LEVEL 
SERIALIZABLE
BEGIN TRANSACTION

INSERT INTO tours 
(tour_name, tour_cost, tour_food_type, tour_duration, state_id)
VALUES
(N'Тур в Рыбинск', 6000, 'RO', 5, 2)
COMMIT