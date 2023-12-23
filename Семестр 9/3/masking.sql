CREATE DATABASE mask_home;
CREATE DATABASE mask_test;

USE mask_home;
CREATE TABLE Masking (
	Word NVARCHAR(50),
	InfType NVARCHAR(50),
	[Function] NVARCHAR(50)
);

INSERT INTO Masking
VALUES
	('email','E-mail address','email()'),
	('Имя','Personal info','partial(1,"***",1)'),
	('Price','Personal info','random(x,y)'),
	('name','Personal info','partial(1,"***",1)'),
	('password','Confidentially info','default()'),
	('card','Credit card','default()'),
	('код','Confidentially info','random(1,100)');

USE mask_test
CREATE TABLE UserData(
	email nvarchar(50),
	Price int,
	[name] nvarchar(50),
	[password] nvarchar(100),
	[card] nvarchar(50),
	[код] int
)

USE mask_test
INSERT INTO UserData 
values
	('t.teterin@uniyar.ac.ru', 101, 'Timofey', 'P@$$W0!D', '12343210', 123);

SELECT 
	sch.name AS schema_name,
	st.name AS table_name, 
	sc.name AS column_name, 
	m.[Function] 
FROM mask_test.sys.schemas sch
JOIN mask_test.sys.tables st
	ON sch.schema_id = st.schema_id
JOIN mask_test.sys.columns sc 
	ON st.object_id = sc.object_id and st.name != 'Masking'
JOIN mask_home.[dbo].[Masking] m
	ON sc.name LIKE CONCAT('%',m.Word,'%');



USE mask_home;
CREATE OR ALTER PROCEDURE MaskingProcedure
	@DBName NVARCHAR(50)
AS 
BEGIN 
	DROP TABLE IF EXISTS #tmpTable
	CREATE TABLE #tmpTable (
		sch_name NVARCHAR(100),
		table_name NVARCHAR(100),
		column_name NVARCHAR(100),
		[Function] NVARCHAR(50)
	)
	DECLARE @Sql NVARCHAR(450) = N'
	INSERT INTO #tmpTable SELECT 
			sch.name AS sch_name,
			st.name AS table_name, 
			sc.name AS column_name, 
			m.[Function]
		FROM ['+@DBName+'].sys.schemas sch
		JOIN ['+@DBName+'].sys.tables st ON sch.schema_id = st.schema_id
		JOIN ['+@DBName+'].sys.columns sc ON st.object_id = sc.object_id and st.name != ''Masking'' 
		JOIN mask_home.[dbo].[Masking] m ON sc.name LIKE CONCAT(''%'',m.Word,''%'');'
	EXEC(@Sql);
	DECLARE MaskingCursor CURSOR
	FOR 
		SELECT * FROM #tmpTable
	OPEN MaskingCursor
	DECLARE 
		@SchemaName NVARCHAR(100),
		@TableName NVARCHAR(100),
		@ColumnName NVARCHAR(100),
		@FunctionVar NVARCHAR(50)
	FETCH NEXT FROM MaskingCursor
	INTO @SchemaName, @TableName, @ColumnName, @FunctionVar
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF @FunctionVar NOT LIKE '%x,y%'
		BEGIN						
			SET @Sql = '
				ALTER TABLE ['+@DBName+'].['+@SchemaName+'].['+@TableName+'] 
				ALTER COLUMN ['+@ColumnName+'] 
				ADD MASKED WITH (FUNCTION = '''+@FunctionVar+''');'
			EXEC(@Sql)
		END
		ELSE
		BEGIN
			DECLARE @min INT, @max INT
			SET @Sql = '
				SELECT 
					@min = min(['+@ColumnName+']),
					@max = max(['+@ColumnName+']) 
				FROM ['+@DBName+'].['+@SchemaName+'].['+ @TableName + ']'
			EXEC sp_executesql 
				@Sql, 
				N'@min AS INT OUTPUT, @max AS INT OUTPUT', 
				@min = @min OUTPUT, 
				@max = @max OUTPUT;
			SET @Sql = '
				ALTER TABLE ['+@DBname+'].['+@SchemaName+'].['+@TableName+'] 
				ALTER COLUMN ['+@ColumnName+'] 
				ADD MASKED WITH (FUNCTION = ''RANDOM('+CAST(@min AS VARCHAR(10))+','+CAST(@max AS VARCHAR(10))+')'');'
			EXEC(@Sql)
		END
		FETCH NEXT FROM MaskingCursor
		INTO @SchemaName, @TableName, @ColumnName, @FunctionVar
	END
	CLOSE MaskingCursor
	DEALLOCATE MaskingCursor
	DROP TABLE IF EXISTS #tmpTable
END 

USE mask_home
EXEC MaskingProcedure 'mask_test'

CREATE USER TestUser WITHOUT LOGIN
GRANT SELECT ON SCHEMA::[dbo] TO TestUser
GRANT SELECT ON SCHEMA::[dbo] TO TestUser1

USE mask_test
EXECUTE AS USER='TestUser'
SELECT * FROM [dbo].[UserData]
REVERT
EXECUTE AS USER='TestUser1'
SELECT * FROM [dbo].[UserData]
REVERT
SELECT * FROM [dbo].[UserData]

CREATE USER TestUser1 WITHOUT LOGIN

GRANT unmask TO TestUser1

USE mask_test
ALTER TABLE UserData ALTER COLUMN Price 	 DROP masked
ALTER TABLE UserData ALTER COLUMN [name] 	 DROP masked
ALTER TABLE UserData ALTER COLUMN [password] DROP masked
ALTER TABLE UserData ALTER COLUMN [card]   	 DROP masked
ALTER TABLE UserData ALTER COLUMN [код] 	 DROP masked