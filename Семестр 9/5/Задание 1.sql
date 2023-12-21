--Задание 1

--Создать роль базы данных “DevUserRole”. Эта роль должна быть членом
--ролей базы данных db_datareader и db_datawriter. Напишите скрипт для
--предоставления прав DevUserRole на выполнение всех существующих в
--заданной БД хранимых процедур.
--Реализуйте триггер DDL для того чтобы автоматически выдавать права роли
--DevUserRole на выполнение всех вновь создаваемых в схеме “dbo” хранимых
--процедур.

DROP ROLE IF EXISTS DevUserRole
DROP USER IF EXISTS DevUser

CREATE ROLE DevUserRole
CREATE USER DevUser WITHOUT LOGIN

ALTER ROLE db_datareader ADD MEMBER DevUserRole
ALTER ROLE db_datawriter ADD MEMBER DevUserRole

ALTER ROLE DevUserRole ADD MEMBER DevUser

CREATE PROCEDURE DevUserRoleProc1
AS
BEGIN
	SELECT 'DevUserRoleProc1'
END

EXEC DevUserRoleProc1

-- Назначение прав DevUserRole на все существующие процедуры
DECLARE @DBProcedureNameWithSchema NVARCHAR(200)
DECLARE GrantPrivilegeCursor CURSOR FOR
	SELECT 
		sys.schemas.name + '.' + sys.procedures.name AS schemaAndProcNames
	FROM sys.procedures
	JOIN sys.schemas 
		ON sys.procedures.schema_id = sys.schemas.schema_id
OPEN GrantPrivilegeCursor
FETCH NEXT FROM GrantPrivilegeCursor INTO @DBProcedureNameWithSchema
WHILE @@FETCH_STATUS=0 
BEGIN
    DECLARE @Sql NVARCHAR(300) = '
		GRANT EXECUTE 
		ON '+@DBProcedureNameWithSchema+' 
		TO DevUserRole'
        EXEC sp_executesql @Sql 
        FETCH NEXT FROM GrantPrivilegeCursor INTO @DBProcedureNameWithSchema
END
CLOSE GrantPrivilegeCursor
DEALLOCATE GrantPrivilegeCursor

-- Проверка
EXECUTE AS USER = 'DevUser'
EXECUTE DevUserRoleProc1
REVERT

-- Создание DDL триггера назначение прав DevUserRole
CREATE OR ALTER TRIGGER DDL
ON DATABASE
AFTER CREATE_PROCEDURE
AS
BEGIN
    DECLARE @SchemaName NVARCHAR(300) = 
    	EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]', 'NVARCHAR(256)')
    IF @SchemaName != 'dbo'
        RETURN
    DECLARE @ProcName NVARCHAR(300) = 
    	EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(256)')
    DECLARE @DBProcedureNameWithSchema NVARCHAR(600) = 
    	@SchemaName + '.' + @ProcName
    DECLARE @Sql NVARCHAR(200) = '
		GRANT EXECUTE 
		ON '+@DBProcedureNameWithSchema+' 
		TO DevUserRole'
    EXEC sp_executesql @Sql
END

-- Проверка
CREATE PROCEDURE DevUserRoleProc2 AS
BEGIN
    SELECT 'DevUserRoleProc2'
END

EXECUTE AS USER = 'DevUser'
EXECUTE DevUserRoleProc2
REVERT