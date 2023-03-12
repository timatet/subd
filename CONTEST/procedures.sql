/* #1
DB: Lessons

Департамент образования просит центр предоставить отчет о загруженности преподавателей. 
Напишите хранимую процедуру AverageBusyEmployees, которая возвращает набор данных, 
содержащий два столбца EmployeeId и AverageBusyEmployee. Загруженность преподавателя 
вычисляется по формуле [количество занятий преподавателя в неделю]*100/[максимально возможное количество занятий].
*/

CREATE OR ALTER PROCEDURE AverageBusyEmployees
AS 
BEGIN 
	SELECT 
		e.Id AS EmployeeId,
		COUNT(l.Id) * 100 / 12 AS AverageBusyEmployee
	FROM Employee e 
	JOIN Lesson l ON e.Id = l.EmployeeId 
	GROUP BY e.Id  
END

/* #2
DB: Zoo

Напишите хранимую процедуру с именем ReportEmployee, которая для сотрудника по имени @Name 
возвращает количество загонов, которые обслуживает данный сотрудник(@CountPlace), суммарную площадь 
этих загонов (@SumSquare) и количество животных в этих загонах(@CountAnimal).
*/

CREATE OR ALTER PROCEDURE ReportEmployee
	@Name NVARCHAR(50),
	@CountPlace INT OUTPUT,
	@SumSquare FLOAT OUTPUT,
	@CountAnimal INT OUTPUT 
AS 
BEGIN 
	SELECT 
		@CountPlace = ISNULL(COUNT(DISTINCT p.Id), 0),
		@SumSquare = ISNULL(
			(
				SELECT 
					SUM(p2.Square)
				FROM Place p2 
				JOIN Employee e2 ON p2.EmployeeId = e2.Id 
				WHERE e2.Name = @Name
			),
			0),
		@CountAnimal = ISNULL(COUNT(a.Id), 0)
	FROM Place p
	FULL JOIN Employee e ON p.EmployeeId = e.Id 
	FULL JOIN Animal a ON p.Id = a.PlaceId 
	WHERE e.Name = @Name
END

/* #3
DB: Zoo

Напишите хранимую процедуру с именем AnimalEmployee, которая для сотрудника 
по имени @Name выводит информацию (данные таблицы Animal) об обслуживаемых им животных
*/

CREATE OR ALTER PROCEDURE AnimalEmployee
	@Name NVARCHAR(50)
AS 
BEGIN 
	SELECT 
		a.*
	FROM Animal a 
	JOIN Place p ON a.PlaceId = p.Id 
	JOIN Employee e ON p.EmployeeId = e.Id 
	WHERE e.Name = @Name
END

/* #4
DB: Zoo

В базе данных есть хранимая процедура, которая на вход принимает пол сотрудника и возвращает случайный Id сотрудника с таким полом.
Прототип этой поцедуры: xp.[RandomEmployee] @Male int, @Id int OUTPUT
Напишите свою хранимую процедуру, которая для выбранного сотрудника вернет его возраст.
Прототип процедуры: DateOfBirthEmployee @Male int, @Age int OUTPUT
*/

CREATE OR ALTER PROCEDURE DateOfBirthEmployee 
	@Male INT, 
	@Age INT OUTPUT
AS 
BEGIN 
	DECLARE @Id INT 
	EXEC xp.[RandomEmployee] @Male, @Id OUTPUT
	SELECT 
		@Age = DATEDIFF(YEAR, e.DateOfBirth, GETDATE())
	FROM Employee e 
	WHERE e.Id = @Id
END