CREATE TABLE ddl_log 
(
	AttemptDate DATE,
	LoginName NVARCHAR(100),
	DBName NVARCHAR(100),
	SchemaName NVARCHAR(100),
	ObjectName NVARCHAR(100),
	TSQLCommand NVARCHAR(MAX)
)

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
	INSERT INTO ddl_log 
	VALUES
	(GETDATE(), @LoginName, @DBName, @SchemaName, @ObjectName, @TSQLCommand)
END

DROP PROCEDURE IF EXISTS TestAudit
CREATE OR ALTER PROCEDURE TestAudit AS
BEGIN
    SELECT 'TestAudit'
END

SELECT * FROM dbo.ddl_log