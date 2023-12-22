USE mask_test

CREATE TABLE TestData
(
	id INT IDENTITY(1, 1) PRIMARY KEY,
	name NVARCHAR(50) NOT NULL UNIQUE,
	level NVARCHAR(50) NOT NULL
)

INSERT INTO TestData
VALUES 
	(N'Ivan Ivanov', 'SECRET'),
	(N'Peter Petrov', 'TOP SECRET'),
	(N'Michael Sidorov', 'UNCLASSIFIED')
	
CREATE TABLE UserData
(
	name NVARCHAR(50) NOT NULL PRIMARY KEY,
	clearance NVARCHAR(50) NOT NULL,
	level INT NOT NULL
)

INSERT INTO UserData
VALUES
	(N'Anna', 'SECRET', 1),
	(N'Alex', 'UNCLASSIFIED', 2)
	
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

CREATE ROLE [data_reader]
GRANT SELECT ON TestData TO [data_reader]

CREATE USER [Anna] WITHOUT LOGIN
ALTER ROLE [data_reader] ADD MEMBER [Alex]

CREATE USER [Alex] WITHOUT LOGIN
ALTER ROLE [data_reader] ADD MEMBER [Anna]

CREATE SCHEMA UserSec
CREATE OR ALTER FUNCTION [UserSec].[data_read]
	(@Clearance AS NVARCHAR(20))
RETURNS TABLE
WITH schemabinding
AS
RETURN
    WITH 
    cte_row_level AS (
		SELECT TOP 1 
    		C.level AS row_level
		FROM [dbo].Classifications C
		WHERE C.name = @clearance
	),
	cte_user_level AS (
		SELECT TOP 1 
			C.level AS user_level
		FROM [dbo].Classifications C
		JOIN [dbo].Users U ON C.name = U.clearance
		WHERE U.name = CURRENT_USER
	)
    SELECT 1 AS fn_result
    FROM cte_row_level, cte_user_level
    WHERE cte_row_level.row_level >= cte_user_level.user_level
    
CREATE SECURITY policy [Security].P_RLS_DataTable_read
ADD FILTER predicate [Security].[fn_DataTable_read]([level])
ON [dbo].[TestData]
WITH (state=on)
 
-- Проверка
EXECUTE AS USER = 'Anna'
SELECT * FROM [dbo].[DataTable]
REVERT
 
EXECUTE AS USER = 'Alex'
SELECT * FROM [dbo].[DataTable]
REVERT

