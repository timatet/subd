CREATE DATABASE L6;
USE L6;

-- Настройки clr
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;

ALTER DATABASE L6 SET TRUSTWORTHY ON;

DROP FUNCTION IF EXISTS dbo.TestFunction;
DROP ASSEMBLY IF EXISTS DotNetFunction;

CREATE ASSEMBLY DotNetFunction 
FROM '/.../CLR2.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS;

CREATE OR ALTER FUNCTION dbo.TestFunction(
	@log_file NVARCHAR(100),
	@date DATE, 
	@user NVARCHAR(50), 
	@object_type NVARCHAR(50), 
	@object_name NVARCHAR(50), 
	@sql NVARCHAR(max)
) RETURNS NVARCHAR(max)
AS EXTERNAL NAME DotNetFunction.LogFunctions.LogActionInFile;

-- Проверка
SELECT dbo.TestFunction('/.../test_file.csv', GETDATE(), 'test_user', 'obj_t_test', 'obj_n_test', 'sql_test');

-- Аудит действий над функциями и процедурами
CREATE OR ALTER TRIGGER audit_objects
ON DATABASE
FOR 
	CREATE_PROCEDURE, 
	DROP_PROCEDURE, 
	ALTER_PROCEDURE, 
	CREATE_FUNCTION, 
	DROP_FUNCTION, 
	ALTER_FUNCTION
AS 
BEGIN
	DECLARE @Data XML = EVENTDATA()
	DECLARE @LoginName NVARCHAR(100) 
		= @Data.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(100)')
	DECLARE @DBName NVARCHAR(100) 
		= @Data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'NVARCHAR(100)')
	DECLARE @SchemaName NVARCHAR(100) 
		= @Data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'NVARCHAR(100)')
	DECLARE @ObjectName NVARCHAR(100) 
		= @Data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)')
	DECLARE @TSQLCommand NVARCHAR(MAX) 
		= @Data.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)')
	-- ...
END

DROP PROCEDURE IF EXISTS TestAudit
CREATE OR ALTER PROCEDURE TestAudit AS
BEGIN
    SELECT 'TestAudit'
END
