USE L1

DROP TABLE dbo.Clearence

CREATE TABLE Clearence
(
	level INT NOT NULL UNIQUE,
	name NVARCHAR(50) PRIMARY KEY NOT NULL
)

INSERT INTO Clearence
VALUES
	(0, 'SECRET'),
	(1, 'TOP SECRET'),
	(2, 'UNCLASSIFIED')

CREATE TABLE TestData
(
	id INT IDENTITY(1, 1) PRIMARY KEY,
	name NVARCHAR(50) NOT NULL UNIQUE,
	clearence NVARCHAR(50) NOT NULL
	FOREIGN KEY(clearence) REFERENCES Clearence(name)
)

INSERT INTO TestData
VALUES 
	(N'Ivan Ivanov', 'SECRET'),
	(N'Peter Petrov', 'TOP SECRET'),
	(N'Michael Sidorov', 'UNCLASSIFIED')
	
CREATE TABLE UserData
(
	name NVARCHAR(50) NOT NULL PRIMARY KEY,
	clearence NVARCHAR(50) NOT NULL
	FOREIGN KEY(clearence) REFERENCES Clearence(name)
)

INSERT INTO UserData
VALUES
	(N'Anna', 'SECRET'),
	(N'Alex', 'UNCLASSIFIED');

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
END

DELETE FROM UserData
SELECT * FROM UserData

CREATE ROLE [data_reader]
GRANT SELECT ON TestData TO [data_reader]

CREATE USER [Anna] WITHOUT LOGIN
ALTER ROLE [data_reader] ADD MEMBER [Anna]

CREATE USER [Alex] WITHOUT LOGIN
ALTER ROLE [data_reader] ADD MEMBER [Alex]

UPDATE UserData
SET clearence = 'SECRET'
WHERE name = 'Alex'

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
    WHERE (SELECT cl.level FROM dbo.Clearence cl WHERE cl.name = @clearence) 
		>= (SELECT cl.level FROM dbo.UserData ud, dbo.Clearence cl WHERE ud.clearence = cl.name AND ud.name = CURRENT_USER) 

CREATE SECURITY POLICY 
	[UserSec].RLS_data_reader
ADD FILTER PREDICATE [UserSec].[data_reader_control]([clearence])
ON [dbo].[TestData]
WITH (STATE=ON)

DROP SECURITY POLICY [UserSec].RLS_data_reader
 
-- Проверка
EXECUTE AS USER = 'Anna'
SELECT * FROM dbo.TestData
REVERT
 
EXECUTE AS USER = 'Alex'
SELECT * FROM dbo.TestData
REVERT

SELECT CURRENT_USER

INSERT INTO UserData
VALUES
	('dbo', 'SECRET')
