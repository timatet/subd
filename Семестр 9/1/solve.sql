CREATE DATABASE L1;
USE L1;

-- Уровни безопасности
DROP TABLE IF EXISTS dbo.Clearence;
CREATE TABLE Clearence
(
	level INT NOT NULL UNIQUE,
	name NVARCHAR(50) PRIMARY KEY NOT NULL
);
INSERT INTO Clearence
VALUES
	(0, 'TOP SECRET'),
	(1, 'SECRET'),
	(2, 'UNCLASSIFIED');

-- Данные
CREATE TABLE TestData
(
	id INT IDENTITY(1, 1) PRIMARY KEY,
	name NVARCHAR(50) NOT NULL UNIQUE,
	clearence NVARCHAR(50) NOT NULL
	FOREIGN KEY(clearence) REFERENCES Clearence(name)
);
INSERT INTO TestData
VALUES 
	(N'Ivan Ivanov', 'SECRET'),
	(N'Peter Petrov', 'TOP SECRET'),
	(N'Michael Sidorov', 'UNCLASSIFIED');

-- Настройки пользователей
CREATE TABLE UserData
(
	name NVARCHAR(50) NOT NULL PRIMARY KEY,
	clearence NVARCHAR(50) NOT NULL
	FOREIGN KEY(clearence) REFERENCES Clearence(name)
);

INSERT INTO UserData
VALUES
	(N'dbo', 'TOP SECRET');

-- Триггер на добавление новых пользователей в UserData
CREATE OR ALTER TRIGGER UserRegisterTrigger
    ON DATABASE
    AFTER CREATE_USER
    AS
BEGIN
    DECLARE @NewUser NVARCHAR(2000) = 
    	EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(256)')
    INSERT INTO UserData
    VALUES 
    	(@NewUser, 'UNCLASSIFIED') 
END;

DELETE FROM UserData
SELECT * FROM UserData

DROP USER IF EXISTS [Anna]
DROP USER IF EXISTS [Alex]

CREATE ROLE [data_reader]
GRANT SELECT ON TestData TO [data_reader]
GRANT UPDATE ON TestData TO [data_reader]
GRANT INSERT ON TestData TO [data_reader]

CREATE USER [Anna] WITHOUT LOGIN
ALTER ROLE [data_reader] ADD MEMBER [Anna]

CREATE USER [Alex] WITHOUT LOGIN
ALTER ROLE [data_reader] ADD MEMBER [Alex]

UPDATE UserData
SET clearence = 'SECRET'
WHERE name = 'Alex'

SELECT * FROM UserData

-- Уровень пользователя
SELECT cl.level FROM UserData ud, Clearence cl WHERE ud.clearence = cl.name AND ud.name = 'Alex'

-- Уровень секрета
SELECT cl.level FROM Clearence cl WHERE cl.name = 'SECRET'

CREATE SCHEMA UserSec

-- Предикат управления доступом
CREATE OR ALTER FUNCTION [UserSec].[data_reader_control](@clearence AS NVARCHAR(20))
RETURNS TABLE
WITH schemabinding
AS
RETURN
    SELECT 1 AS allowed
    WHERE (
    	SELECT cl.level 
    	FROM dbo.Clearence cl 
    	WHERE cl.name = @clearence
	) >= (
		SELECT cl.level 
		FROM dbo.UserData ud, dbo.Clearence cl 
		WHERE ud.clearence = cl.name 
		AND ud.name = CURRENT_USER
	);

DROP FUNCTION [UserSec].[data_reader_control]

-- Политика
CREATE SECURITY POLICY 
	[UserSec].RLS_data_reader
ADD FILTER PREDICATE [UserSec].[data_reader_control]([clearence])
ON [dbo].[TestData],
ADD BLOCK PREDICATE [UserSec].[data_reader_control]([clearence])
ON [dbo].[TestData] AFTER INSERT
WITH (STATE = ON)

DROP SECURITY POLICY [UserSec].RLS_data_reader

-- Обновление данных
CREATE OR ALTER TRIGGER [dbo].UpdateDataClearance
ON [dbo].[TestData] AFTER UPDATE
AS
BEGIN
	DECLARE 
		@msg NVARCHAR(max),
		@TD_ins_id INT, 
		@TD_ins_name NVARCHAR(50), 
		@TD_ins_clearence NVARCHAR(50), 
		@TD_del_id INT,
		@TD_del_name NVARCHAR(50),
		@TD_del_clearence NVARCHAR(50);
	DECLARE UpdateDataClearanceCursor CURSOR 
	FOR 
		SELECT * 
		FROM deleted d 
		INNER JOIN inserted i 
		ON d.Id = i.Id;
	OPEN UpdateDataClearanceCursor;
	FETCH NEXT FROM UpdateDataClearanceCursor 
	INTO @TD_del_id,@TD_del_name,@TD_del_clearence,@TD_ins_id,@TD_ins_name,@TD_ins_clearence;
	WHILE @@FETCH_STATUS = 0
	BEGIN
	-- Находим уровень доступа текущего пользователя
	DECLARE @CurrentUserClearence NVARCHAR(50) = 
		(SELECT ud.clearence 
		FROM dbo.UserData ud
		WHERE ud.name = CURRENT_USER);
	-- Устанавливаем данным
	UPDATE dbo.TestData 
	SET clearence = @CurrentUserClearence
	WHERE id = @TD_del_id;
	FETCH NEXT FROM UpdateDataClearanceCursor 
	INTO @TD_del_id,@TD_del_name,@TD_del_clearence,@TD_ins_id,@TD_ins_name,@TD_ins_clearence;
	END;
	CLOSE UpdateDataClearanceCursor;
	DEALLOCATE UpdateDataClearanceCursor;
END
 
-- Проверка
EXECUTE AS USER = 'Anna'
SELECT * FROM dbo.TestData
INSERT INTO dbo.TestData 
VALUES (N'Insert SECRET by Anna', 'SECRET')
INSERT INTO dbo.TestData 
VALUES (N'Insert UNCLASSIFIED by Anna', 'UNCLASSIFIED')
REVERT
 
EXECUTE AS USER = 'Alex'
SELECT * FROM dbo.TestData
UPDATE dbo.TestData 
SET name = 'Michael Sidorov 1'
WHERE id = 3
REVERT

SELECT * FROM dbo.TestData 
UPDATE dbo.TestData 
SET name = 'Peter Petrov 1'
WHERE id = 2