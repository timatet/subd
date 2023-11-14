-- Написать функцию, которая для указанного учителя выдает количество 
-- различных кабинетов, посещаемых им в каждый рабочий день
CREATE OR ALTER FUNCTION [TeacherFunction]
(
	@Учитель NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
	DECLARE @Результат INT;
	WITH [УчительКабинет] AS (
		SELECT 
			[Учитель],
			[Кабинет],
			COUNT(DISTINCT [День недели])
			AS [Продолжительность]
		FROM R1
		GROUP BY [Учитель], [Кабинет]
	)
	SELECT 
		@Результат = COUNT(*)
	FROM [УчительКабинет]
	WHERE [Учитель] = @Учитель
	AND [Продолжительность] = 5
	RETURN  @Результат
END

CREATE OR ALTER FUNCTION [TeacherFunction2]
(
	@Учитель NVARCHAR(50)
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		[День недели],
		[Количество кабинетов]
	FROM (
		SELECT 
			[Учитель],
			DATENAME(WEEKDAY, [День недели] - 1)
			AS 'День недели',
			COUNT(DISTINCT [Кабинет])
			AS 'Количество кабинетов'
		FROM R1
		WHERE [Учитель] = @Учитель
		GROUP BY [Учитель], [День недели]
	) res_table
)

DECLARE @Учитель NVARCHAR(50) = 'Петров'
DECLARE @Результат INT = dbo.TeacherFunction(@Учитель)
PRINT 'Учитель ' + @Учитель + ' посещает кабинетов каждый день: ' + CAST(@Результат AS NVARCHAR)
SELECT * FROM TeacherFunction2(@Учитель)
