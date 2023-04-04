/* #1
DB: Lessons

Написать триггер, который проверяет корректность добавления данных в таблицу Lesson.
Преподаватель не может вести более трех занятий в один  день, не может вести занятия 
в свой методический день, и не может вести два и более занятий в одно и тоже время.
Вставка должна поддерживать множественность добавляемых данных 
(корректные данные должны быть добавлены, некорректные  - отбракованы).
*/

CREATE OR ALTER TRIGGER TableTrigger1
ON Lesson
INSTEAD OF INSERT AS 
BEGIN 
	DECLARE TriggerCursor CURSOR FOR 
		SELECT 
			[Id], [Name], [DayOfWeek], [NumberOfLesson], [EmployeeId]
		FROM inserted
	DECLARE 
		@InsertedId INT,
		@InsertedName NVARCHAR(50),
		@InsertedDayOfWeek INT,
		@InsertedNumberOfLesson INT,
		@InsertedEmployeeId INT
	OPEN TriggerCursor
	FETCH NEXT FROM TriggerCursor INTO @InsertedId, @InsertedName, @InsertedDayOfWeek, @InsertedNumberOfLesson, @InsertedEmployeeId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Количество в этот день уже пар у преподователя 
		-- не может превышать двух существующих
		DECLARE @PairsToDay INT
		SELECT
			@PairsToDay = COUNT([NumberOfLesson])
		FROM Lesson
		WHERE [DayOfWeek] = @InsertedDayOfWeek AND [EmployeeId] = @InsertedEmployeeId
		-- Методический день преподователя
		DECLARE @MethodDay INT = (
			SELECT 
				[RestDay]
			FROM Employee e 
			WHERE [Id] = @InsertedEmployeeId
		)
		-- Количество пар в в это время
		DECLARE @PairToOneTime INT
		SELECT 
			@PairToOneTime = COUNT(*)
		FROM Lesson l 
		WHERE [DayOfWeek] = @InsertedDayOfWeek 
		AND [EmployeeId] = @InsertedEmployeeId 
		AND [NumberOfLesson] = @InsertedNumberOfLesson
		-- Выполняем проверку условий и вставку
		IF @PairsToDay <= 2 AND @InsertedDayOfWeek <> @MethodDay AND @PairToOneTime = 0
			INSERT INTO Lesson ([Id], [Name], [DayOfWeek], [NumberOfLesson], [EmployeeId])
			VALUES (@InsertedId, @InsertedName, @InsertedDayOfWeek, @InsertedNumberOfLesson, @InsertedEmployeeId)
		FETCH NEXT FROM TriggerCursor INTO @InsertedId, @InsertedName, @InsertedDayOfWeek, @InsertedNumberOfLesson, @InsertedEmployeeId
	END
	CLOSE TriggerCursor
	DEALLOCATE TriggerCursor
END

/* #2
DB: tblDepartment

Написать триггер, который контролирует процесс  добавления данных в таблицу tblDepartment:
  -- Для каждой вновь добавляемой строки формирует уникальный идентификатор на единицу больший, чем максимальный  в таблице
  -- Не допускает существования двух и более корневых элементов (ParentId = NULL)
  -- Для каждой вновь добавляемой записи проверяет существование в таблице родительского подразделения.
Вставка должна поддерживать множественность добавляемых данных (корректные данные должны быть добавлены, некорректные  - отбракованы).
*/

CREATE OR ALTER TRIGGER TableTrigger2
ON [tblDepartment]
INSTEAD OF INSERT AS 
BEGIN 
	DECLARE TriggerCursor CURSOR FOR 
		SELECT 
			[ID], [DepartmentName], [ParentID]
		FROM inserted
	DECLARE 
		@InsertedID INT,
		@InsertedDepartmentName NVARCHAR(200),
		@InsertedParentID INT
	OPEN TriggerCursor
	FETCH NEXT FROM TriggerCursor INTO @InsertedID, @InsertedDepartmentName, @InsertedParentID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Поиск максимального идентификатора
		DECLARE @MaxIdentifier INT = (
			SELECT MAX([ID])
			FROM [tblDepartment]
		)
		IF @MaxIdentifier IS NULL
			SET @MaxIdentifier = 1
		-- Количество корневых элементов
		DECLARE @ItemsWithParentNULL INT = (
			SELECT COUNT(*)
			FROM [tblDepartment]
			WHERE [ParentID] IS NULL 
		)
		-- Количество предков
		DECLARE @ItemsWithParent INT = (
			SELECT COUNT(*)
			FROM [tblDepartment]
			WHERE [ID] = @InsertedParentID
		)
		IF @MaxIdentifier = 1 AND @InsertedParentID IS NULL 
		BEGIN
			INSERT INTO [tblDepartment]
			VALUES (@MaxIdentifier, @InsertedDepartmentName, @InsertedParentID)
			FETCH NEXT FROM TriggerCursor INTO @InsertedID, @InsertedDepartmentName, @InsertedParentID
			CONTINUE
		END
		-- Выбраковка решения ЕСЛИ:
		-- Если у нас идентификатор на входе был задан как NULL, ИЛИ
		-- Количество корневых элементов (ParentID is null) меньше одного, ИЛИ
		-- Количество предков у элемента который вставляем меньше ОДНОГО
		IF (@InsertedID IS NULL OR @ItemsWithParentNULL < 1 OR @ItemsWithParent < 1) 
		BEGIN 
			FETCH NEXT FROM TriggerCursor INTO @InsertedID, @InsertedDepartmentName, @InsertedParentID
			CONTINUE
		END
		INSERT INTO [tblDepartment]
		VALUES (@MaxIdentifier + 1, @InsertedDepartmentName, @InsertedParentID)
		FETCH NEXT FROM TriggerCursor INTO @InsertedID, @InsertedDepartmentName, @InsertedParentID
	END
	CLOSE TriggerCursor
	DEALLOCATE TriggerCursor
END

/* #3
DB: tblDepartment

Написать замешающий триггер, который контролирует процесс  удаления данных из таблицы tblDepartment:
  -- Нельзя удалять корневой элемент
  -- Нельзя удалять более одной записи за один раз
  -- При удалении подразделения, все ему подчиненные подразделения переводятся под начало его руководителя.
*/

CREATE OR ALTER TRIGGER TableTrigger2
ON [tblDepartment]
INSTEAD OF DELETE AS
BEGIN 
	-- Если удаляется больше одной записи откатывает тразакцию
	IF (SELECT COUNT(*) FROM deleted) = 1
	BEGIN
		DECLARE TriggerCursor CURSOR FOR 
		SELECT 
			[ID], [DepartmentName], [ParentID]
		FROM deleted
		DECLARE 
			@InsertedID INT,
			@InsertedDepartmentName NVARCHAR(200),
			@InsertedParentID INT
		OPEN TriggerCursor
		FETCH NEXT FROM TriggerCursor INTO @InsertedID, @InsertedDepartmentName, @InsertedParentID
		WHILE @@FETCH_STATUS = 0
		BEGIN	
			IF @InsertedParentID IS NOT NULL
			BEGIN
				-- На входе тут будет только одна запись
				UPDATE tblDepartment 
				SET ParentID = @InsertedParentID
				WHERE ParentID = @InsertedID
				DELETE FROM tblDepartment
				WHERE ID = @InsertedID
			END
			FETCH NEXT FROM TriggerCursor INTO @InsertedID, @InsertedDepartmentName, @InsertedParentID
		END
		CLOSE TriggerCursor
		DEALLOCATE TriggerCursor
	END
END

/* #4
DB: tblDepartment

Написать замешающий триггер, который контролирует процесс  удаления данных из таблицы tblDepartment:
  -- Нельзя удалять корневой элемент
  -- При удалении подразделения, все ему подчиненные подразделения переводятся под начало его руководителя.
Удаление должно поддерживать множественность удаляемых  данных (корректные данные должны быть удалены, некорректные  - отбракованы).
*/

CREATE OR ALTER TRIGGER TableTrigger2
ON [tblDepartment]
INSTEAD OF DELETE AS
BEGIN 
	DECLARE TriggerCursor CURSOR FOR 
	SELECT 
		[ID], [DepartmentName], [ParentID]
	FROM deleted
	DECLARE 
		@ID INT,
		@DepartmentName NVARCHAR(200),
		@ParentID INT
	OPEN TriggerCursor
	FETCH NEXT FROM TriggerCursor INTO @ID, @DepartmentName, @ParentID
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		IF @ParentID IS NOT NULL
		BEGIN 
			DECLARE @NewParentID INT = (SELECT [ParentID] FROM tblDepartment WHERE [ID] = @ID)
			DELETE FROM tblDepartment
			WHERE ID = @ID
			UPDATE tblDepartment 
			SET ParentID = @NewParentID
			WHERE ParentID = @ID
		END
		FETCH NEXT FROM TriggerCursor INTO @ID, @DepartmentName, @ParentID
	END
	CLOSE TriggerCursor
	DEALLOCATE TriggerCursor
END

/* #5
DB: tblDepartment

Вам необходимо реализовать протоколирование  операций модификации, удаления и добавления 
информации в таблицу  tblDepartment. Для этого в системе создана таблица [Audit]
*/

CREATE OR ALTER TRIGGER TableTrigger2
ON [tblDepartment]
AFTER DELETE, UPDATE, INSERT AS
BEGIN 
	DECLARE @Operation NVARCHAR(20),
			@CountInserted INT = (SELECT COUNT(*) FROM inserted),
			@CountDeleted INT = (SELECT COUNT(*) FROM deleted),
			@DepartmentNameOld NVARCHAR(200), 
			@ParentIDOld INT,
			@DepartmentNameNew NVARCHAR(200),
			@ParentIDNew INT, 
			@ID INT,
			@DepartmentName NVARCHAR(200),
			@ParentID INT
	SELECT @Operation = CASE 
    WHEN @CountDeleted > 0 AND @CountInserted > 0 THEN 'Update'
    WHEN @CountDeleted > 0 THEN 'Delete'
    ELSE 'Insert' END
    IF @CountDeleted > 0
    BEGIN
	    DECLARE DeleteUpdateCursor CURSOR FOR 
		SELECT 
			[ID], [DepartmentName], [ParentID]
		FROM deleted
		OPEN DeleteUpdateCursor
		FETCH NEXT FROM DeleteUpdateCursor INTO @ID, @DepartmentName, @ParentID
		WHILE @@FETCH_STATUS = 0
		BEGIN	
			-- в любом случае сохраняются старые данные
			SELECT 
				@DepartmentNameOld = [DepartmentName],
				@ParentIDOld = [ParentID]
			FROM deleted
			WHERE [ID] = @ID
			-- но если операция обновления то так же сохраняются новые данные
			IF @CountInserted > 0 AND @CountDeleted > 0
			BEGIN 
				SELECT 
					@DepartmentNameNew = [DepartmentName],
					@ParentIDNew = [ParentID]
				FROM inserted
				WHERE [ID] = @ID
			END
			INSERT INTO [Audit] ([Command], [ID], [DepartmentNameOld], [ParentIDOld], [DepartmentNameNew], [ParentIDNew])
			VALUES (@Operation, @ID, @DepartmentNameOld, @ParentIDOld, @DepartmentNameNew, @ParentIDNew)
			FETCH NEXT FROM DeleteUpdateCursor INTO @ID, @DepartmentName, @ParentID
		END
		CLOSE DeleteUpdateCursor
		DEALLOCATE DeleteUpdateCursor
	END
	ELSE
	BEGIN
		DECLARE InsertCursor CURSOR FOR 
		SELECT 
			[ID], [DepartmentName], [ParentID]
		FROM inserted
		OPEN InsertCursor
		FETCH NEXT FROM InsertCursor INTO @ID, @DepartmentName, @ParentID
		WHILE @@FETCH_STATUS = 0
		BEGIN	
			-- при добавлении только новые данные
			SELECT 
				@DepartmentNameNew = [DepartmentName],
				@ParentIDNew = [ParentID]
			FROM inserted
			WHERE [ID] = @ID
			INSERT INTO [Audit] ([Command], [ID], [DepartmentNameOld], [ParentIDOld], [DepartmentNameNew], [ParentIDNew])
			VALUES (@Operation, @ID, @DepartmentNameOld, @ParentIDOld, @DepartmentNameNew, @ParentIDNew)
			FETCH NEXT FROM InsertCursor INTO @ID, @DepartmentName, @ParentID
		END
		CLOSE InsertCursor
		DEALLOCATE InsertCursor
	END
END