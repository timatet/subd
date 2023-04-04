CREATE OR ALTER TRIGGER DateTriggerVariant2 ON [University\heimerdinger].[Строки-заказа]
INSTEAD OF INSERT
AS
BEGIN
	-- объявление переменных для курсора
	DECLARE @NumberNewOrder INT, @ContractNewOrder INT, @Tirage INT
	-- объявление курсора
	DECLARE FetchOrdersCursor CURSOR FOR
		SELECT [inserted].[№ заказа], [inserted].[№ контракта], [inserted].[Количество]
		FROM inserted
	-- открытие курсора
	OPEN FetchOrdersCursor
	-- получение первой строки в курсор
	FETCH NEXT FROM FetchOrdersCursor INTO @NumberNewOrder, @ContractNewOrder, @Tirage
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- дата поступления книги в редакцию для текущего заказа
		DECLARE @NewOrderDate DATE = (
			SELECT 
				[Дата поступления заказа]
			FROM [University\heimerdinger].[Заказы]
			WHERE [№ заказа] = @NumberNewOrder
		)
		-- дата выхода книги для текующего контракта
		DECLARE @BookOutDate DATE = (
			SELECT
				[Дата выхода]
			FROM [University\heimerdinger].[Книги]
			WHERE [№ контракта] = @ContractNewOrder
		)
		-- разница между датой выхода и датой поступления в редакцию
		DECLARE @Difference INT = DATEDIFF(DAY, @BookOutDate, @NewOrderDate)
		-- если между датами меньше 7 дней, то
		IF @Difference <= 7
			-- обновляю дату поступления заказа и дату выполнения работы
			-- чтобы между датой выхода и датой поступления была неделя
			UPDATE [University\heimerdinger].[Заказы]
			SET [Дата поступления заказа] = DATEADD(DAY, 7 - @Difference, [Дата поступления заказа]),
			[Дата выполнения заказа] = DATEADD(DAY, 7 - @Difference, [Дата выполнения заказа])
			WHERE [№ заказа] = @NumberNewOrder
		-- выполняю добавление информации о заказе, контракте, тираже
		INSERT INTO [University\heimerdinger].[Строки-заказа]
		VALUES (@NumberNewOrder, @ContractNewOrder, @Tirage)
		-- обновление данных в курсоре
		FETCH NEXT FROM FetchOrdersCursor INTO @NumberNewOrder, @ContractNewOrder, @Tirage
	END
	-- закрытие курсора
	CLOSE FetchOrdersCursor
	-- освобождение памяти
	DEALLOCATE FetchOrdersCursor
	-- тестовые данные
	-- INSERT INTO [University\heimerdinger].[Строки-заказа]
	-- VALUES (12, 2, 100)
	-- в исходных данных между датами разница в один день. 
	-- Затем она меняется на 7 дней, тк прибавляется 6, чтобы был выдержан период
END