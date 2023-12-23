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
	(0, 'TopSecret'),
	(1, 'Secret'),
	(2, 'Unclassified');
CREATE ROLE [TopSecret];
CREATE ROLE [Secret];
CREATE ROLE [Unclassified];

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
	(N'Ivan Ivanov', 'Secret'),
	(N'Peter Petrov', 'TopSecret'),
	(N'Michael Sidorov', 'Unclassified');

DROP USER IF EXISTS [Anna]
DROP USER IF EXISTS [Alex]
DROP USER IF EXISTS [Ivan]

CREATE ROLE [data_reader]
GRANT SELECT ON TestData TO [data_reader]
GRANT UPDATE ON TestData TO [data_reader]
GRANT INSERT ON TestData TO [data_reader]

CREATE USER [Anna] WITHOUT LOGIN
ALTER ROLE [data_reader] ADD MEMBER [Anna]
ALTER ROLE [Unclassified] ADD MEMBER [Anna]

CREATE USER [Alex] WITHOUT LOGIN
ALTER ROLE [data_reader] ADD MEMBER [Alex]
ALTER ROLE [Secret] ADD MEMBER [Alex]

CREATE USER [Ivan] WITHOUT LOGIN 
ALTER ROLE [data_reader] ADD MEMBER [Ivan]
ALTER ROLE [TopSecret] ADD MEMBER [Ivan]
ALTER ROLE [Unclassified] ADD MEMBER [Ivan]

-- Роли пользователи
SELECT m.name, p.name 
FROM sys.database_role_members rm
JOIN sys.database_principals p
	ON rm.role_principal_id = p.principal_id
JOIN sys.database_principals m
	ON rm.member_principal_id = m.principal_id

-- Максимально приоритетная роль пользователя
CREATE OR ALTER FUNCTION 
	[UserSec].[user_max_role_level]()
RETURNS INT
WITH schemabinding
BEGIN
	DECLARE 
		@CL_level INT, 
		@CL_name NVARCHAR(50),
		@CL_max_level INT = 999;
	DECLARE SearchUserMaxRoleLevelCursor CURSOR
	FOR (SELECT cl.level, cl.name FROM dbo.Clearence cl)
	OPEN SearchUserMaxRoleLevelCursor;
	FETCH NEXT FROM SearchUserMaxRoleLevelCursor 
	INTO @CL_level,@CL_name;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (IS_ROLEMEMBER(@CL_name)=1 OR CURRENT_USER='dbo')
		BEGIN
			SET @CL_max_level = LEAST(@CL_max_level, @CL_level);
		END
		FETCH NEXT FROM SearchUserMaxRoleLevelCursor
		INTO @CL_level,@CL_name;
	END;
	CLOSE SearchUserMaxRoleLevelCursor;
	DEALLOCATE SearchUserMaxRoleLevelCursor;
	RETURN @CL_max_level;
END;

SELECT UserSec.user_max_role_level();

CREATE SCHEMA UserSec

-- Предикат управления доступом
CREATE OR ALTER FUNCTION 
	[UserSec].[data_reader_control](@clearence AS NVARCHAR(20))
RETURNS TABLE
WITH schemabinding
AS
RETURN
    SELECT 1 AS allowed
    WHERE (
    	SELECT cl.level 
    	FROM dbo.Clearence cl 
    	WHERE cl.name = @clearence
	) >= (SELECT UserSec.user_max_role_level());

DROP FUNCTION [UserSec].[user_max_role_level]
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
		(SELECT c.name 
		FROM dbo.Clearence c 
		WHERE c.level = (SELECT UserSec.user_max_role_level()));
	-- Устанавливаем данным
	UPDATE dbo.TestData 
	SET clearence = @CurrentUserClearence
	WHERE id = @TD_del_id;
	FETCH NEXT FROM UpdateDataClearanceCursor 
	INTO @TD_del_id,@TD_del_name,@TD_del_clearence,@TD_ins_id,@TD_ins_name,@TD_ins_clearence;
	END;
	CLOSE UpdateDataClearanceCursor;
	DEALLOCATE UpdateDataClearanceCursor;
END;
 
-- Проверка
EXECUTE AS USER = 'Anna'
SELECT * FROM dbo.TestData
INSERT INTO dbo.TestData 
VALUES (N'Insert Secret by Anna', 'Secret')
INSERT INTO dbo.TestData 
VALUES (N'Insert Unclassified by Anna', 'Unclassified')
REVERT
 
EXECUTE AS USER = 'Alex'
SELECT * FROM dbo.TestData
UPDATE dbo.TestData 
SET name = 'Michael Sidorov 1'
WHERE id = 3
REVERT

EXECUTE AS USER = 'Ivan'
SELECT * FROM dbo.TestData
REVERT

SELECT * FROM dbo.TestData 
UPDATE dbo.TestData 
SET name = 'Peter Petrov 1'
WHERE id = 2
