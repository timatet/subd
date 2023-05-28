-- Список выданных прав
SELECT 
  DB_NAME() AS 'DBName', 
  p.[name] AS 'PrincipalName', 
  p.[type_desc] AS 'PrincipalType', 
  p2.[name] AS 'GrantedBy', 
  dbp.[permission_name], 
  dbp.[state_desc], 
  so.[Name] AS 'ObjectName', 
  so.[type_desc] AS 'ObjectType' 
FROM 
  [sys].[database_permissions] dbp 
  LEFT JOIN [sys].[objects] so 
  	ON dbp.[major_id] = so.[object_id] 
  LEFT JOIN [sys].[database_principals] p 
  	ON dbp.[grantee_principal_id] = p.[principal_id] 
  LEFT JOIN [sys].[database_principals] p2 
	ON dbp.[grantor_principal_id] = p2.[principal_id] 
WHERE 
  p.[name] = 'EmployeeRole' OR p.[name] = 'DirectorRole'

-- 1-я роль должна иметь  доступ к таблицам, хр. процедурам и др. объектам БД, 
-- требующийся для руководителя фирмы 
-- (т.е., ему д.б. разрешено просматривать конфиденциальную информацию, 
-- удалять, исправлять какие-то сведения).
  
-- 2-я роль должна иметь доступ, требующийся для простого сотрудника (просмотр не всей инф-ии, 
-- добавление, изменение, удаление – только того, что нужно для работы).
  
CREATE LOGIN DirectorLogin WITH PASSWORD='passw0$rD!'
CREATE USER DirectorUser FOR LOGIN DirectorLogin
CREATE ROLE DirectorRole

CREATE LOGIN EmployeeLogin WITH PASSWORD='passw0$rD!'
CREATE USER EmployeeUser FOR LOGIN EmployeeLogin
CREATE ROLE EmployeeRole

ALTER ROLE DirectorRole ADD MEMBER DirectorUser
ALTER ROLE EmployeeRole ADD MEMBER EmployeeUser

GRANT SELECT, UPDATE, DELETE, EXECUTE 
TO DirectorRole

GRANT SELECT TO EmployeeRole
DENY SELECT ON dbo.Audit TO EmployeeRole