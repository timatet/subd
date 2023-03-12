/* #1
DB: Lessons

Написать скалярную функцию, принимающую на вход (Id преподавателя, Номер Дня недели), 
которая возвращает количество пар у преподавателя в данный день.
Прототип функции: CountOfLessons (@id_empl int, @day_of_week int).
*/

CREATE OR ALTER FUNCTION CountOfLessons (
	@id_empl INT,
	@day_of_week INT
)
RETURNS INT
AS
BEGIN
	DECLARE @count_lessons INT
	SELECT 
		@count_lessons = COUNT(*)
	FROM Lesson
	WHERE DayOfWeek = @day_of_week 
	AND EmployeeId = @id_empl
	RETURN  @count_lessons
END

/* #2
DB: Lessons

Написать функцию, которая принимает на вход (ИД преподавателя, Номер Дня недели), 
и возвращает названия предметов, которые этот преподаватель преподает 
в данный день (названия не должны повторяться).
Прототип функции: NameOfLessons (@id_empl int, @day_of_week int).
*/

CREATE OR ALTER FUNCTION NameOfLessons (
	@id_empl INT,
	@day_of_week INT
)
RETURNS TABLE
AS 
RETURN 
(
	SELECT 
		DISTINCT l.Name 
	FROM Lesson l 
	WHERE l.EmployeeId = @id_empl AND 
	l.DayOfWeek = @day_of_week
)

/* #3
DB: Lessons

Вам необходимо сформировать отчет о ежедневной занятости преподавателей в виде следующей таблицы 
| Преподаватель |	Понедельник |	Вторник |	Среда |	Четверг |	Пятница |
| ------------- | ----------- | ------- | ----- | ------- | ------- |
| Иванов И.И.   |	3           |	0       |	2     |	1       |	3       |
| ...           |	...         |	...     |	...   |	...     |	...     |
Имя функции TeachersUnloading
*/

-- Bad working ?
CREATE OR ALTER FUNCTION TeachersUnloading 
()
RETURNS TABLE
AS RETURN 
(
	WITH HelpCTE AS (
		SELECT 
			e.Name,
			l.DayOfWeek,
			COUNT(l.Id) AS CountLessons
		FROM Employee e 
		LEFT JOIN Lesson l ON e.Id = l.EmployeeId 
		GROUP BY e.Name , l.DayOfWeek 
		--ORDER BY e.Name , l.DayOfWeek 
	) 
	SELECT 
		h.Name AS 'Преподаватель',
	    COALESCE(MAX(CASE WHEN DayOfWeek = 1
          THEN h.CountLessons END), 0) AS 'Понедельник',
	    COALESCE(MAX(CASE WHEN DayOfWeek = 2
          THEN h.CountLessons END), 0) AS 'Вторник',
	    COALESCE(MAX(CASE WHEN DayOfWeek = 3
          THEN h.CountLessons END), 0) AS 'Среда',
	    COALESCE(MAX(CASE WHEN DayOfWeek = 4
          THEN h.CountLessons END), 0) AS 'Четверг',
	    COALESCE(MAX(CASE WHEN DayOfWeek = 5
          THEN h.CountLessons END), 0) AS 'Пятница'
	FROM HelpCTE h
	GROUP BY h.Name
)

/* #4
DB: Lessons

Вам необходимо сформировать отчет о  занятости преподавателя с заданным идентификатором(Id) 
в виде следующей таблицы. Если нет урока, то выведите пустую строку.
| Номер урока |	Понедельник   |	Вторник |	Среда |	Четверг |	Пятница       |
| ----------- | ------------- | ------- | ----- | ------- | ------------- |
| 1           |	Робототехника	|         |	 	    | С#      |	              |
| 3           |	 	 	          |         | С++   |	С++   	| Робототехника |
| 4           |	JS	 	        |	        |       | JS      |               |	 
Прототип функции CouplesTeacher(@Id int)
*/

CREATE OR ALTER FUNCTION CouplesTeacher 
(
	@Id INT
)
RETURNS TABLE
AS RETURN 
(
	WITH HelpCTE AS (
		SELECT 
			e.Id AS Id,
			l.NumberOfLesson AS NumberOfLesson,
			l.DayOfWeek AS DayOfWeek,
			l.Name AS LessonName
		FROM Employee e 
		JOIN Lesson l ON e.Id = l.EmployeeId 
		WHERE e.Id = @Id
	) 
	SELECT
	    h.NumberOfLesson AS 'Номер урока',
	    COALESCE(MAX(CASE WHEN DayOfWeek = 1
          THEN h.LessonName END), '') AS 'Понедельник',
	    COALESCE(MAX(CASE WHEN DayOfWeek = 2
	      THEN h.LessonName END), '') AS 'Вторник',
	    COALESCE(MAX(CASE WHEN DayOfWeek = 3
	      THEN h.LessonName END), '') AS 'Среда',
	    COALESCE(MAX(CASE WHEN DayOfWeek = 4
	      THEN h.LessonName END), '') AS 'Четверг',
	    COALESCE(MAX(CASE WHEN DayOfWeek = 5
	      THEN h.LessonName END), '') AS 'Пятница'
	FROM HelpCTE h
	GROUP BY NumberOfLesson
)