CREATE DATABASE L6;
USE L6;

-- Настройки clr
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
EXEC sp_configure 'clr enabled', 1
EXEC sp_configure 'clr strict security', 0
RECONFIGURE

ALTER DATABASE master SET TRUSTWORTHY ON

DROP TRIGGER IF EXISTS audit_objects ON DATABASE;
DROP FUNCTION IF EXISTS TestFunction;
DROP ASSEMBLY IF EXISTS DotNetFunction;

CREATE ASSEMBLY DotNetFunction 
FROM 'D:\repos\subd\Семестр 9\5\CLR2\bin\Release\CLR2.dll'
WITH PERMISSION_SET = SAFE;

ALTER ASSEMBLY DotNetFunction
WITH PERMISSION_SET = UNSAFE;

--- Доверенные сборки ---
SELECT * FROM sys.assembly_files
SELECT * FROM sys.assemblies

DECLARE @asmBin VARBINARY(MAX) =
	(SELECT content FROM sys.assembly_files WHERE assembly_id=65565);
DECLARE @hash VARBINARY(64) = HASHBYTES('SHA2_512', @asmBin);
EXEC sp_add_trusted_assembly @hash, N'clr2, version=0.0.0.0, culture=neutral, publickeytoken=null, processorarchitecture=msil'
--- ****************** ---

CREATE OR ALTER FUNCTION dbo.TestFunction(
	@log_file NVARCHAR(100),
	@date NVARCHAR(50), 
	@user NVARCHAR(50), 
	@object_type NVARCHAR(50), 
	@object_name NVARCHAR(50), 
	@sql NVARCHAR(max)
) RETURNS NVARCHAR(max)
AS EXTERNAL NAME DotNetFunction.LogFunctions.LogActionInFile;

-- Проверка
SELECT dbo.TestFunction('D:\test_file.csv', GETDATE(), 'test_user', 'obj_t_test', 'obj_n_test', 'sql_test');

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
	DECLARE @ObjectType NVARCHAR(100) 
		= @Data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)')
	DECLARE @TSQLCommand NVARCHAR(MAX) 
		= @Data.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)')
	DECLARE @LogResult INT = (
		SELECT dbo.TestFunction(
			'D:/test_file.csv', 
			GETDATE(), 
			@LoginName, 
			@ObjectType, 
			CONCAT(@DBName, '.', @SchemaName, '.', @ObjectName), 
			@TSQLCommand
		)
	);
END;

SELECT GETDATE();

-- Проверка триггера
DROP PROCEDURE IF EXISTS TestAudit;

CREATE OR ALTER PROCEDURE TestAudit AS
BEGIN
	SELECT 'TestAudit'
END;