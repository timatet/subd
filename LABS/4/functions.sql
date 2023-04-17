-- ЛАБОРАТОРНАЯ 4. ФУНКЦИИ

-- Скалярная функция, получающая на входе идентификатор клиента и 
-- возвращающая возможный размер скидки для него, рассчитанный по схеме: 
-- если клиент уже покупал тур 1  раз, то скидки нет, 
-- если 2 – скидка 10%, 3 – 20%, 4 и более – 25%

CREATE OR ALTER FUNCTION CalculatePersonalSale
(
	@ClientPhone CHAR(20)
)
RETURNS INT
AS
BEGIN
	DECLARE @PersonalSale INT,
			@PurchasedToursCount INT
	SET @PurchasedToursCount = (
		SELECT 
			COUNT(*)
		FROM contracts c 
		WHERE c.client_phone = @ClientPhone
	)
	IF @PurchasedToursCount = 2
		SET @PersonalSale = 10
	ELSE IF @PurchasedToursCount = 3
		SET @PersonalSale = 20
	ELSE IF @PurchasedToursCount >= 4
		SET @PersonalSale = 25
	ELSE 
		SET @PersonalSale = 0
	RETURN  @PersonalSale
END

SELECT 
	c.client_phone,
	COUNT(*) AS cnt
FROM contracts c 
GROUP BY c.client_phone 
ORDER BY cnt
-- 79151236462 нет контрактов
-- 79159836482 1 контракт
-- 79189526452 2 контракта
-- 79185263265 3 контракта

SELECT dbo.CalculatePersonalSale('79185263265')

-- Inline. Для каждого страхового агента указать количество 
-- выданных за год страховок по турам и общим итогом.

CREATE OR ALTER FUNCTION InsurancesStat 
(
	@Year INT
)
RETURNS TABLE
AS RETURN
(
	SELECT -- TODO: Добавить тур в отдельный атрибут приведения статистики
		*
	FROM (
		SELECT 
			COALESCE(i.insurance_agent_INN, 'Всего:') AS 'Страховой агент',
			COUNT(i.insurance_contract_id) AS 'Число выданных страховок'
		FROM insurance_agents ia 
		JOIN insurance i ON i.insurance_agent_INN = ia.insurance_agent_INN
		WHERE YEAR(i.insurance_conclusion_date) = @Year
		GROUP BY ROLLUP (i.insurance_agent_INN)
	) res_table
)

SELECT * FROM dbo.InsurancesStat(2021)

-- Multi-statement-функция, выдающая список наиболее популярных регионов для каждой страны
-- Наиболее популярные регионы это регионы в которое максимальное число оформленных контрактов

CREATE OR ALTER FUNCTION PopularRegions ()
RETURNS @ResTable TABLE
(
	country_name NVARCHAR(32), 
	state_name NVARCHAR(32), 
	tours_count INT
)
AS
BEGIN
	WITH res_table AS (
		SELECT 
		 	c.country_name,
			s.state_name,
		 	COUNT(t.tour_id) AS count_tours
		FROM contracts contr
		JOIN tours t ON t.tour_id = contr.tour_id 
		JOIN states s ON t.state_id = s.state_id 
		JOIN countries c ON s.country_id = c.country_id
		GROUP BY s.state_name, c.country_name
	)
	INSERT INTO @ResTable
  		SELECT
			*
		FROM res_table -- Использовать группировку или оконные функция. Искать максимум в каждой стране.
									 -- Ожидается от каждой страны наиболее популярный регион 
  	WHERE count_tours = (SELECT MAX(count_tours) FROM res_table)
  RETURN
END

SELECT * FROM dbo.PopularRegions()
