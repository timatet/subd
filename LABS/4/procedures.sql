-- ЛАБОРАТОРНАЯ 4. ПРОЦЕДУРЫ

-- Процедура без параметров, формирующая список туров, предлагающих 5-звездочные отели
CREATE OR ALTER PROCEDURE FiveStarsHotels
AS 
BEGIN 
	SELECT 
		*
	FROM hotels h 
	WHERE h.hotel_stars_count = 5
END

EXEC FiveStarsHotels 

-- Процедура, на входе получающая тип транспорта и формирующая список 
-- перевозчиков, предлагающих данный вид
CREATE OR ALTER PROCEDURE CarriesByTransportType
	@TransportType NVARCHAR(50)
AS 
BEGIN 
	SELECT 
		DISTINCT c.carrier_name AS 'Перевозчики'
	FROM transport t 
	JOIN transport_types tt ON t.transport_type_id = tt.transport_type_id 
	JOIN carriers c ON t.carrier_INN = c.carrier_INN 
	WHERE tt.transport_type_name = @TransportType
END

EXEC CarriesByTransportType 'Самолет'

-- Процедура, на входе получающая идентификаторы тура, клиента, 
-- выбранное количество звезд, выходной параметр – стоимость этого тура 
-- (если клиент уже был у нас 2 или более раз, то делаем ему скидку 10%)
CREATE OR ALTER PROCEDURE SearchTourCost
	@TourId INT,
	@CarrierINN CHAR(12),
	@ClientPhone CHAR(20),
	@StarCount INT,
	@TourCost REAL OUTPUT
AS 
BEGIN 
	DECLARE @CountClientContracts INT = 0
	SET @CountClientContracts = (
		SELECT 
			COUNT(*)
		FROM contracts c2 
		WHERE c2.client_phone = @ClientPhone
	)
	-- Подбор тура
	DECLARE @OldTourCost INT = 0
	DECLARE @TourDuration INT = 1
	SET @TourCost = 0
	SELECT 
		@OldTourCost = @TourCost,
		@TourCost = @TourCost + t.tour_cost,
		@TourDuration = t.tour_duration
	FROM tours t 
	WHERE t.tour_id = @TourId
	IF @OldTourCost = @TourCost
		THROW 60000, 'Тура с заданными параметрами не существует', 1
	ELSE 
		SET @OldTourCost = @TourCost
	-- Подбор перевозчика
	-- Учет, что клиент летит в обе стороны
	SELECT
		@OldTourCost = @TourCost,
		@TourCost = @TourCost + c.carrier_cost * 2
	FROM carriers c 
	WHERE c.carrier_INN = @CarrierINN
	IF @OldTourCost = @TourCost
		THROW 60000, 'Перевозчика с заданными параметрами не существует', 1
	ELSE 
		SET @OldTourCost = @TourCost
	-- Подбор отеля с наименьшей стоимостью
	-- Учет длительности тура
	SELECT TOP 1
		@OldTourCost = @TourCost,
		@TourCost = @TourCost + h.hotel_booking_cost * @TourDuration
	FROM hotels h 
	WHERE h.hotel_stars_count = @StarCount
	ORDER BY h.hotel_booking_cost ASC 
	IF @OldTourCost = @TourCost
		THROW 60000, 'Отеля с заданными параметрами не существует', 1
	ELSE 
		SET @OldTourCost = @TourCost
	-- Рассчет скидки как постоянному клиенту
	IF @CountClientContracts >= 2
		SET @TourCost = @TourCost * 0.9
	-- Применение персональной скидки
	DECLARE @PersonalClientSale INT = 0
	SET @PersonalClientSale = (
		SELECT
			cl.client_personal_sale 
		FROM clients cl
		WHERE cl.client_phone = @ClientPhone
	)
	SET @TourCost = @TourCost * (100 - @PersonalClientSale) / 100
END

SELECT * FROM tours t 
SELECT * FROM carriers c 
SELECT * FROM hotels h WHERE h.hotel_stars_count = 4
SELECT * FROM clients c2 

-- Пример рассчета стоимости для:
-- Клиент: Крючкова В. А., 79151236462, перс. скидка. 5%.
-- Оформляет первый договор
-- Перевозчик Аэрофлот
-- Тур: Пешком по золотому кольцу, 10 дней
-- Отель: Хостел Друзья
DECLARE @TourCost REAL
EXEC SearchTourCost 1, '7712040126', '79151236462', 4, @TourCost OUTPUT
SELECT @TourCost AS 'Стоимость тура'

-- Процедура, вызывающая вложенную процедуру, которая подсчитывает среднюю стоимость 
-- по всем купленным турам. Главная процедура выдает ФИО клиентов, которые заключали 
-- договора на сумму, превышающую среднюю

-- Процедура подсчитывающая среднюю стоимость по всем купленным турам
CREATE OR ALTER PROCEDURE AverageAmountByAllTours
	@AverageAmount INT OUTPUT 
AS 
BEGIN 
	SELECT 
		@AverageAmount = AVG(c.contract_total_amount)
	FROM contracts c 
END

DECLARE @AverageAmount INT
EXEC AverageAmountByAllTours @AverageAmount OUTPUT
SELECT @AverageAmount AS 'Среднее по всем купленным турам'

CREATE OR ALTER PROCEDURE ClientsWithToursMoreThenAverage
AS 
BEGIN 
	DECLARE @AverageAmount INT
	EXEC AverageAmountByAllTours @AverageAmount OUTPUT
	SELECT 
		c.client_name AS 'ФИО',
		c2.contract_total_amount AS 'Стоимость'
	FROM clients c 
	JOIN contracts c2 ON c.client_phone = c2.client_phone 
	WHERE c2.contract_total_amount >= @AverageAmount
END

EXEC ClientsWithToursMoreThenAverage
