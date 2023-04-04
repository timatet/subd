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

-- Процедура, на входе получающая тип транспорта и формирующая список туров, предлагающих этот транспорт
CREATE OR ALTER PROCEDURE ToursByTransportType
	@TransportType NVARCHAR(50)
AS 
BEGIN 

END

-- Процедура, на входе получающая идентификаторы тура, клиента, выбранное количество звезд, 
-- выходной параметр – стоимость этого тура (если клиент уже был у нас 2 или более раз, 
-- то делаем ему скидку 10%) 

CREATE OR ALTER PROCEDURE SearchTourCost
	@TourId INT,
	@CarrierId INT,
	@ClientId INT,
	@StarCount INT,
	@TourCost INT OUTPUT
AS 
BEGIN 
	SET @TourCost = 0
	SELECT 
		@TourCost = @TourCost + t.tour_cost 
	FROM tours t 
	WHERE t.tour_id = @TourId
END

SELECT 
	*
FROM clients c 

/*
 * TourID: 1 - 5
 * Carriers 123456789123, 123456789124, 7708503727, 7712040126 
 * Clients 79151236460 - 79151236466
 * */
DECLARE @TourCost INT 
EXEC SearchTourCost 1, 2, 2, 3, @TourCost OUTPUT
PRINT 'Стоимость тура: ' + CAST(@TourCost AS NVARCHAR)



