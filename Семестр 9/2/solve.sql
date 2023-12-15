-- Создание узла "Клиенты"
CREATE TABLE clients (
	phone char(20) NOT NULL,
	name nvarchar(32) NOT NULL,
	personal_sale int DEFAULT 0 NOT NULL,
	birth_date date NULL,
	address nvarchar(128) NULL,
	PRIMARY KEY (phone)
) AS NODE

-- Заполнение данными
INSERT INTO clients
VALUES
	(N'79102356984',N'Архипова М. Ю.',		15,'1986-10-01',N'Ярославль, Гоголя, 4'),
	(N'79102515283',N'Соболева В. Д.',		0, '1999-12-08',N'Данилов, Петербургская, 63'),
	(N'79103205068',N'Кулешова П. А.',		15,'1976-12-30',N'Тутаев, Герцена, 42'),
	(N'79104526983',N'Соловьев В. А.',		0, '1986-02-28',N'Ростов, Декабристов, 3'),
	(N'79105824148',N'Кузнецова Е. С.',		0, '1993-11-19',N'Данилов, Вятская, 17'),
	(N'79151236460',N'Софронова Е. Д.',		0, '1987-06-12',N'Ярославль, Ленина, 40'),
	(N'79151236461',N'Филатов И. М.',		0, '1993-01-18',N'Ярославль, Стопани, 10'),
	(N'79151236462',N'Крючкова В. А.',		5, '2001-11-03',N'Ярославль, Союзная, 144'),
	(N'79151236463',N'Орлова А. Ф.',		7, '1984-06-06',N'Тутаев, Ленина, 10'),
	(N'79151236464',N'Калинин А. Д.',		0, '1999-10-09',N'Углич, Февральская, 28'),
	(N'79151236465',N'Титова П. М.',		0, '1987-06-12',N'Углич, Ленина, 22'),
	(N'79151236466',N'Колесников Я. П.',	0, '1994-03-08',N'Дубки, Гагарина, 3'),
	(N'79159321596',N'Бондарева А. В.',		0, '1989-01-01',N'Ярославль, Папанина, 7'),
	(N'79159452658',N'Орлова А. Е.',		0, '1998-07-18',N'Нерехта, Седова, 5'),
	(N'79159632154',N'Иванов Р. Р.',		0, '2001-12-09',N'Мышкин, Павлова, 10'),
	(N'79159700452',N'Архипова А. М.',		0, '1999-08-03',N'Рыбинск, Луначарского, 99'),
	(N'79159836482',N'Блинова П. А.',		5, '1986-01-12',N'Гаврилов Ям, Клубная, 32'),
	(N'79159842562',N'Третьякова М. Ф.',	0, '1999-03-07',N'Ростов, Моравского, 18'),
	(N'79185263265',N'Семенов С. И.',		30,'1996-04-09',N'Ярославль, 8 марта, 10'),
	(N'79187452525',N'Некрасова А. Д.',		0, '2001-09-04',N'Некрасово, Центральная, 4'),
	(N'79189526452',N'Покровская А. А.',	10,'2002-01-12',N'Переславль Залесский, Светлая, 5'),
	(N'79301274586',N'Малышев Д. М.',		4, '1999-01-06',N'Рыбинск, Пушкина, 4'),
	(N'79401253265',N'Островский Д. Н.',	0, '1975-06-15',N'Ярославль, Углическая, 56'),
	(N'79652635325',N'Назарова В. И.',		0, '1994-07-06',N'Гаврилов Ям, Попова, 17'),
	(N'79653215124',N'Голубева В. Б.',		5, '1998-01-20',N'Рыбинск, Ленина, 17'),
	(N'79653265986',N'Филиппов А. Д.',		0, '1955-11-09',N'Рыбинск, Бульварная, 7'),
	(N'79655175553',N'Тарасова А. Т.',		18,'1945-09-01',N'Углич, Нахимсона, 3'),
	(N'79801256598',N'Марков А. Д.',		0, '1968-03-10',N'Ярославль, Маланова, 14'),
	(N'79802563256',N'Шапошникова М. Ф.',	5, '2002-12-02',N'Ростов, Спартаковская, 1'),
	(N'79803258456',N'Орлов А. А.',			15,'1973-08-16',N'Рыбинск, Свободы, 5'),
	(N'79803265984',N'Панов А. Т.',			8, '1988-08-11',N'Ярославль, 1-ая Новодуховская,1'),
	(N'79804521258',N'Казакова Д. Д.',		0, '1985-09-03',N'Ярославль, пр-т Ленина, 104'),
	(N'79804523265',N'Сорокина В. К.',		0, '2001-09-19',N'Ростов, Карла Маркса, 73')

SELECT * FROM clients c 
	 
-- Создание узла "Туры"
CREATE TABLE tours (
	id int IDENTITY(1,1) NOT NULL,
	name nvarchar(128) NULL,
	cost decimal(10,2) DEFAULT 0 NULL,
	food_type nvarchar(32) DEFAULT 'RO' NULL,
	duration	int	DEFAULT 1 NOT NULL,
	CHECK ([food_type]='UAI' 
		OR [food_type]='AI' 
		OR [food_type]='FB' 
		OR [food_type]='HB' 
		OR [food_type]='BB' 
		OR [food_type]='RO'),
	PRIMARY KEY(id)
) AS NODE

-- Заполнение данными
INSERT INTO tours 
	(name,cost,food_type,duration) 
VALUES
	(N'Пешком по золотому кольцу',	5200.00,	N'RO',	10),	--1
	(N'Каналы Санкт-Петербурга',	9800.00,	N'AI',	7),		--2
	(N'Золотая осень',				2500.00,	N'UAI',	3),		--3
	(N'Тур в Самарканд',			16800.00,	N'FB',	12),	--4
	(N'7 дней в Фетхие',			56000.00,	N'AI',	7),		--5
	(N'Ликийская тропа',			27000.00,	N'RO',	14),	--6
	(N'Новый год в Анапе',			18200.00,	N'FB',	5),		--7
	(N'Шавлинские озера',			11000.00,	N'RO',	21),	--8
	(N'Восхождение на Олимп',		50000.00,	N'UAI',	35),	--9
	(N'Поход в Ергаки',				14300.00,	N'RO',	7),		--10
	(N'Неделя на Таганае',			16000.00,	N'RO',	7),		--11
	(N'Велопоход на Кольский',		37000.00,	N'FB',	21),	--12
	(N'Рождество в Нюрнберге',		45000.00,	N'UAI',	10),	--13
	(N'Горнолыжный тур Германия',	95110.00,	N'HB',	7),		--14
	(N'Зимний Таганай',				31000.00,	N'FB',	12),	--15
	(N'На коньках по Байкалу',		18100.00,	N'RO',	15)		--16

SELECT * FROM tours t 

-- Создание ребра "Контракт"
-- Стоимость тура фиксируется, поскольку в исходном туре она может изменяться
CREATE TABLE contracts (
	id int IDENTITY(1,1) NOT NULL,
	date_start date NULL,
	date_end date NULL,
	doc_number char(16) NOT NULL,
	tour_cost decimal(10,2) DEFAULT 0 NULL,
	PRIMARY KEY(id)
) AS EDGE

-- Заполнение данными
INSERT INTO contracts 
	($from_id, $to_id, date_start,date_end,doc_number,tour_cost) 
VALUES
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79151236460'), --1
		(SELECT $node_id FROM tours   t WHERE t.id = 2),
		'2022-11-10','2023-11-14',N'7810121314',
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236460')) / 100.00 * 9800.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79151236466'), --2
		(SELECT $node_id FROM tours   t WHERE t.id = 2),
		'2022-11-10','2022-11-14',N'7812121314', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 9800.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79151236463'), --3
		(SELECT $node_id FROM tours   t WHERE t.id = 5),
		'2021-06-05','2021-06-15',N'7812121319', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 56000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79803258456'), --4
		(SELECT $node_id FROM tours   t WHERE t.id = 15),
		'2022-05-25','2022-06-14',N'7629559531', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 31000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79103205068'), --5
		(SELECT $node_id FROM tours   t WHERE t.id = 13),
		'2022-06-29','2022-07-10',N'3453534534', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 45000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79801256598'), --6
		(SELECT $node_id FROM tours   t WHERE t.id = 8),
		'2022-08-10','2022-08-20',N'7815986332', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 11000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79159842562'), --7
		(SELECT $node_id FROM tours   t WHERE t.id = 9),
		'2022-09-02','2022-09-11',N'7800149749', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 50000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79185263265'), --8
		(SELECT $node_id FROM tours   t WHERE t.id = 12),
		'2022-03-10','2022-03-16',N'7801645993', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 37000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79301274586'), --9
		(SELECT $node_id FROM tours   t WHERE t.id = 11),
		'2022-01-27','2022-02-04',N'7810151599', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 16000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79803265984'), --10
		(SELECT $node_id FROM tours   t WHERE t.id = 1),
		'2022-01-17','2022-02-27',N'7815256625', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 5200.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79189526452'), --11
		(SELECT $node_id FROM tours   t WHERE t.id = 12),
		'2022-06-16','2022-06-30',N'7802154142', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 31000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79159700452'), --12
		(SELECT $node_id FROM tours   t WHERE t.id = 16),
		'2022-09-22','2022-09-29',N'7821849955', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 18100.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79185263265'), --13
		(SELECT $node_id FROM tours   t WHERE t.id = 3),
		'2022-07-04','2022-07-19',N'7801645993', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 2500.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79301274586'), --14
		(SELECT $node_id FROM tours   t WHERE t.id = 11),
		'2022-05-04','2022-05-14',N'7810151599', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 16000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79185263265'), --15
		(SELECT $node_id FROM tours   t WHERE t.id = 2),
		'2022-12-15','2022-12-25',N'7801645993', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 9800.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79655175553'), --16
		(SELECT $node_id FROM tours   t WHERE t.id = 5),
		'2022-08-26','2022-09-09',N'7814559252', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 56000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79159842562'), --17
		(SELECT $node_id FROM tours   t WHERE t.id = 7),
		'2021-03-23','2021-03-30',N'7800149749', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 18200.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79159836482'), --18
		(SELECT $node_id FROM tours   t WHERE t.id = 10),
		'2021-11-01','2021-11-14',N'7800185415', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 14300.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79189526452'), --19
		(SELECT $node_id FROM tours   t WHERE t.id = 4),
		'2021-08-24','2021-08-30',N'7802154142', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 16800.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79159452658'), --20
		(SELECT $node_id FROM tours   t WHERE t.id = 13),
		'2022-09-19','2022-09-28',N'3465455675', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 45000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79151236463'), --21
		(SELECT $node_id FROM tours   t WHERE t.id = 13),
		'2021-02-03','2021-02-10',N'7812121319', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 45000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79804523265'), --22
		(SELECT $node_id FROM tours   t WHERE t.id = 9),
		'2021-05-20','2021-05-27',N'7841515262', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 50000.00),
	(	(SELECT $node_id FROM clients c WHERE c.phone = '79803258456'), --23
		(SELECT $node_id FROM tours   t WHERE t.id = 1),
		'2022-12-02','2022-12-30',N'7629559531', 
		(100.00 - (SELECT c.personal_sale FROM clients c WHERE c.phone = '79151236463')) / 100.00 * 5200.00)

SELECT * FROM contracts c 

-- Запрос
-- Среди клиентов, пользовавшихся услугами фирмы более 2-х раз, найти самых «дорогих» 
SELECT clientName, toursSum FROM (
	SELECT 
		cl.phone clientPhone, 
		cl.name clientName, 
		RANK() OVER(ORDER BY SUM(ct.tour_cost) DESC) rnkByCostSum, 
		SUM(ct.tour_cost) toursSum
	FROM clients cl, contracts ct, tours tr
	WHERE MATCH(cl-(ct)->tr)
	GROUP BY cl.phone, cl.name
	HAVING COUNT(*) >= 2
) AS tbl
WHERE rnkByCostSum = 1

-- Создаем узел "Локация"
CREATE TABLE location (
	id int IDENTITY(1,1) NOT NULL,
	country_name nvarchar(32) NOT NULL,
	state_name nvarchar(32) NOT NULL,
	PRIMARY KEY(id)
) AS NODE

-- Заполнение данными
INSERT INTO location
	(country_name,state_name)
VALUES
	(N'Россия', 	N'Анапа'),			--1
	(N'Россия', 	N'Абакан'),			--2
	(N'Россия', 	N'Минусинк'),		--3
	(N'Россия', 	N'Никель'),			--4
	(N'Россия', 	N'Мурманск'),		--5
	(N'Россия', 	N'Екатеринбург'),	--6
	(N'Россия', 	N'Златоуст'),		--7
	(N'Россия', 	N'Шушенское'),		--8	
	(N'Россия', 	N'Горно-Алтайск'),	--9
	(N'Россия', 	N'Ярославль'),		--10
	(N'Россия', 	N'Москва'),			--11
	(N'Россия', 	N'Санкт-Петербург'),--12
	(N'Россия', 	N'Плес'),			--13
	(N'Россия', 	N'Иркутск'),		--14
	(N'Казахстан', 	N'Астана'),			--15
	(N'Казахстан', 	N'Павлодар'),		--16
	(N'Казахстан', 	N'Караганда'),		--17
	(N'Узбекистан', N'Ташкент'),		--18
	(N'Узбекистан', N'Самарканд'),		--19
	(N'Турция', 	N'Стамбул'),		--20
	(N'Турция', 	N'Анкара'),			--21
	(N'Турция', 	N'Анталья'),		--22
	(N'Турция', 	N'Фетхие'),			--23
	(N'Греция', 	N'Салоники'),		--24
	(N'Греция', 	N'Катерини'),		--25
	(N'Греция', 	N'Лариса'),			--26
	(N'Германия', 	N'Бонн'),			--27
	(N'Германия', 	N'Нюрнберг'),		--27
	(N'Германия', 	N'Патрикен-Кирхе'),	--28
	(N'Германия', 	N'Мюнхен'),			--29
	(N'Германия', 	N'Троисдорф')		--30

SELECT * FROM location l 	

-- Создаем ребро "Проживает"
CREATE TABLE lodging (
	hotel_name nvarchar(128) NULL,
	hotel_stars_count int NULL,
	hotel_booking_site nvarchar(128) NULL,
	hotel_booking_cost decimal(10,2) DEFAULT 0 NULL
) AS EDGE

-- Заполнение данными
INSERT INTO lodging 
	($from_id,$to_id,hotel_stars_count,hotel_name,hotel_booking_site,hotel_booking_cost) 
VALUES
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 1),
		(SELECT $node_id FROM location	l WHERE l.id = 10),
		5,N'SK Рояль',	 					NULL,3500.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 2),
		(SELECT $node_id FROM location	l WHERE l.id = 12),
		4,N'Хостел Друзья',					NULL,2150.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 3),
		(SELECT $node_id FROM location	l WHERE l.id = 13),
		3,N'Гостевой дом Волжский',			NULL,1200.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 4),
		(SELECT $node_id FROM location	l WHERE l.id = 19),
		5,N'Отель Nippon',					NULL,6700.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 5),
		(SELECT $node_id FROM location	l WHERE l.id = 23),
		5,N'Отель Литуния',					NULL,9100.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 6),
		(SELECT $node_id FROM location	l WHERE l.id = 20),
		2,N'Палаточный лагерь',				NULL,500.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 7),
		(SELECT $node_id FROM location	l WHERE l.id = 1),
		3,N'Апартаменты у моря',			NULL,3250.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 8),
		(SELECT $node_id FROM location	l WHERE l.id = 9),
		4,N'Гостевой дом в Центре',			NULL,1700.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 9),
		(SELECT $node_id FROM location	l WHERE l.id = 24),
		4,N'Отель Роз Мари',				NULL,8500.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 10),
		(SELECT $node_id FROM location	l WHERE l.id = 2),
		3,N'Заезжий дворик',				NULL,740.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 11),
		(SELECT $node_id FROM location	l WHERE l.id = 7),
		5,N'Гостевой дом Урал',				NULL,1900.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 12),
		(SELECT $node_id FROM location	l WHERE l.id = 5),
		3,N'Отель Ледовитый',				NULL,2350.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 13),
		(SELECT $node_id FROM location	l WHERE l.id = 4),
		5,'Отель Leonardo',					NULL,6900.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 14),
		(SELECT $node_id FROM location	l WHERE l.id = 28),
		5,N'Шале Альпы',					NULL,15000.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 15),
		(SELECT $node_id FROM location	l WHERE l.id = 7),
		5,N'Гостевой дом Урал',				NULL,1900.00
	),
	(	(SELECT $node_id FROM tours   	t WHERE t.id = 16),
		(SELECT $node_id FROM location	l WHERE l.id = 14),
		5,N'Хостел Харбор',					NULL,1100.00
	)
	
SELECT * FROM lodging l 

-- Запрос
-- Найти регион, в который предлагается наибольшее кол-во туров
SELECT countryName, stateName, toursCount FROM (
	SELECT 
		lc.country_name countryName, 
		lc.state_name	stateName, 
		COUNT(tr.id)	toursCount,
		RANK() OVER(ORDER BY COUNT(tr.id) DESC) rnkByTourInRegionCount
	FROM tours tr, lodging ld, location lc
	WHERE MATCH(tr-(ld)->lc)
	GROUP BY lc.country_name, lc.state_name
) tbl
WHERE rnkByTourInRegionCount = 1

-- Запрос
-- Выдать список туров, для которых нет 5-звездочных отелей
SELECT tourName FROM (
	SELECT 
		tr.id, 
		tr.name tourName, 
		MAX(ld.hotel_stars_count) maxStarsInTour 
	FROM tours tr, lodging ld, location lc
	WHERE MATCH(tr-(ld)->lc)
	GROUP BY tr.id, tr.name
) tbl
WHERE maxStarsInTour < 5

-- Найти наиболее и наименее популярные туры
WITH CTE AS (
	SELECT 
		tr.name, 
		COUNT(ct.id) countContracts
	FROM clients cl, contracts ct, tours tr
	WHERE MATCH(cl-(ct)->tr)
	GROUP BY tr.name 
)
SELECT tourType,name,countContracts count FROM (
	SELECT 
		N'Популярный' tourType,
		CTE.name,
		RANK() OVER(ORDER BY MAX(CTE.countContracts) DESC) rnkP,
		MAX(CTE.countContracts) countContracts
	FROM CTE
	GROUP BY CTE.name
) tblP
WHERE rnkP = 1 
UNION ALL 
SELECT tourType,name,countContracts FROM (
	SELECT 
		N'Редкий' tourType,
		CTE.name,
		RANK() OVER(ORDER BY MIN(CTE.countContracts)) rnkM,
		MIN(CTE.countContracts) countContracts
	FROM CTE
	GROUP BY CTE.name
) tblM
WHERE rnkM = 1

-- Найти регион, принесший фирме наибольшую выручку с начала текущего года
SELECT countryName,stateName,sumCostInRegion FROM (
	SELECT 
		lc.country_name countryName, 
		lc.state_name stateName, 
		RANK() OVER(ORDER BY SUM(ct.tour_cost) DESC) rnkByCost, 
		SUM(ct.tour_cost) sumCostInRegion
	FROM clients cl, contracts ct, tours tr, lodging ld, location lc
	WHERE MATCH(cl-(ct)->tr-(ld)->lc)
	GROUP BY lc.country_name, lc.state_name 
) tbl
WHERE rnkByCost = 1