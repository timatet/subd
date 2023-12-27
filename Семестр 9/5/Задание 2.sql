USE master;

CREATE TABLE LogAuditTestAdmin (
	id INT IDENTITY(1,1) PRIMARY KEY,
    EventTime DATETIME,
    UserName VARCHAR(50),
    ComputerName VARCHAR(50)
);

SELECT * FROM LogAuditTestAdmin

CREATE OR ALTER TRIGGER CheckUserLogin
ON ALL SERVER
FOR LOGON
AS
BEGIN
    DECLARE @LoginTime TIME = CONVERT(TIME, GETDATE());
	DECLARE @ComputerName NVARCHAR(100) = HOST_NAME();
	DECLARE @UserName NVARCHAR(100) = ORIGINAL_LOGIN();
   
    IF ((@LoginTime BETWEEN '08:00:00' AND '18:00:00') 
    		AND @ComputerName LIKE '%403%')
    BEGIN
        -- Успешный вход пользователя
        PRINT 'Successful user login';
    END
    ELSE
    BEGIN
	    ROLLBACK TRAN;
        INSERT INTO master.dbo.LogAuditTestAdmin 
        	(EventTime, UserName, ComputerName)
        VALUES (@LoginTime, @UserName, @ComputerName);
        RAISERROR('Access denied. Invalid login time or computer name.', 16, 1);
    END
END;

CREATE LOGIN TestAdminLogin WITH PASSWORD='Qwerty12345!'
CREATE USER TestAdmin FOR LOGIN TestAdminLogin
