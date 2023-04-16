-- ЛАБОРАТОРНАЯ 5. ТРИГГЕРЫ

-- Задание №1
-- Триггер любого типа на добавление клиента – если клиент с таким паспортом уже есть, 
-- то не добавляем его, а выдаем соответствующее сообщение. 
-- В базе документы хранятся отдельно 
CREATE OR ALTER TRIGGER NewClientDocsTrigger ON client_docs
INSTEAD OF INSERT
AS
BEGIN
	DECLARE 
		@ClientDocNumber CHAR(16), 
		@ClientDocIssuedBy NVARCHAR(128),
		@ClientDocIssueDate DATE,
		@ClientPhone CHAR(20),
		@DocTypeId INT
	DECLARE FetchClientsCursor CURSOR FOR
		SELECT 
			*
		FROM inserted
	OPEN FetchClientsCursor
	FETCH NEXT FROM FetchClientsCursor INTO 
		@ClientDocNumber, 
		@ClientDocIssuedBy,
		@ClientDocIssueDate,
		@ClientPhone,
		@DocTypeId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @CountExistPassports INT = 0
		SET @CountExistPassports = (
			SELECT 
				COUNT(*)
			FROM client_docs cd 
			WHERE cd.client_doc_number = @ClientDocNumber
		)
		IF @CountExistPassports > 0
			THROW 60000, 'Введенные данные уже принадлежат существующему документу', 1
		ELSE 
			INSERT INTO client_docs VALUES
				(@ClientDocNumber, @ClientDocIssuedBy, @ClientDocIssueDate, @ClientPhone, @DocTypeId)
		FETCH NEXT FROM FetchClientsCursor INTO 
			@ClientDocNumber, 
			@ClientDocIssuedBy,
			@ClientDocIssueDate,
			@ClientPhone,
			@DocTypeId
	END
	CLOSE FetchClientsCursor
	DEALLOCATE FetchClientsCursor
END

-- 7821849955 уже есть в базе
INSERT INTO client_docs VALUES
	('7821849955', 'MVD', '2012-01-15', '79102356984', 1)

-- Задание №2
-- Последующий триггер на изменение стоимости любого типа отеля – 
-- для 5-звездочных отелей стоимость может меняться только в большую сторону, 
-- для 1,2-звездочных – только в меньшую.
CREATE OR ALTER TRIGGER UpdateHotelCostTrigger ON hotels
AFTER UPDATE 
AS
BEGIN
	DECLARE 
		@HotelId INT,
		@HotelStarsCount INT, 
		@HotelBookingCost DECIMAL(10, 2)
	DECLARE FetchHotelsCursor CURSOR FOR
		SELECT 
			hotel_id,
			hotel_stars_count,
			hotel_booking_cost
		FROM inserted
	OPEN FetchHotelsCursor
	FETCH NEXT FROM FetchHotelsCursor INTO 
		@HotelId,
		@HotelStarsCount, 
		@HotelBookingCost
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @OldCost INT = 0,
				@NewCost INT = 0
		SET @OldCost = (
			SELECT 
				deleted.hotel_booking_cost
			FROM deleted
			WHERE deleted.hotel_id = @HotelId
		)
		SET @NewCost = (
			SELECT 
				inserted.hotel_booking_cost
			FROM inserted
			WHERE inserted.hotel_id = @HotelId
		)
		IF @HotelStarsCount = 5 AND @OldCost > @NewCost
			THROW 60000, 'Для 5-звездочных отелей цена может только увеличиваться', 1
		ELSE IF @HotelStarsCount <= 2 AND @OldCost < @NewCost
			THROW 60000, 'Для 1- и 2-звездочных отелей цена может только уменьшаться', 1
		ELSE 
			COMMIT TRAN
			/*UPDATE hotels 
			SET hotel_booking_cost = @HotelBookingCost
			WHERE hotel_id = @HotelId*/		
		SELECT @OldCost, @NewCost
		FETCH NEXT FROM FetchHotelsCursor INTO 
			@HotelId,
			@HotelStarsCount, 
			@HotelBookingCost
	END
	CLOSE FetchHotelsCursor
	DEALLOCATE FetchHotelsCursor
END

SELECT * FROM hotels h 

-- Id: 1. 5 звезд. Текущая цена 14000
-- Id: 2. 4 звезды. Цена может изменять в любую сторону
-- Id: 8. 1 звезда. Текущая цена 890

UPDATE hotels 
SET hotel_booking_cost = 6000
WHERE hotel_id = 8

-- Задание №3
-- Замещающий триггер на операцию удаления тура – если на данный момент этот тур кем-то куплен, 
-- и поездка еще не закончилась – то удаление не происходит, 
-- выдается соотв. сообщение, в противном случае тур удаляем.
-- Туры статичны, не содержат дат. Использую контракты. Если контракт не активен то удаляется
CREATE OR ALTER TRIGGER DeletingContractsTrigger ON contracts
INSTEAD OF DELETE 
AS
BEGIN
	DECLARE 
		@ContractId INT
	DECLARE FetchContractsCursor CURSOR FOR
		SELECT 
			deleted.contract_id
		FROM deleted
	OPEN FetchContractsCursor
	FETCH NEXT FROM FetchContractsCursor INTO 
		@ContractId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @ContractDateStart DATE, @ContractDateEnd DATE
		SELECT
			@ContractDateStart = deleted.contract_date_start,
			@ContractDateEnd = deleted.contract_date_end
		FROM deleted
		WHERE deleted.contract_id = @ContractId
		IF DATEDIFF(DAY, GETDATE(), @ContractDateStart) <= 0 AND
			DATEDIFF(DAY, GETDATE(), @ContractDateEnd) >= 0 
			THROW 60000, 'Контракт недоступен для удаления поскольку сейчас активен', 1
		ELSE 
			DELETE FROM contracts
			WHERE contract_id = @ContractId
		FETCH NEXT FROM FetchContractsCursor INTO 
			@ContractId
	END
	CLOSE FetchContractsCursor
	DEALLOCATE FetchContractsCursor
END

-- tour_id 2. contract_id 1

SELECT * FROM contracts c 

DELETE FROM contracts 
WHERE contract_id = 1
