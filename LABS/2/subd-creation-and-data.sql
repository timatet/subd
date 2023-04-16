DROP TABLE IF EXISTS contracts;
DROP TABLE IF EXISTS insurance;
DROP TABLE IF EXISTS hotels;
DROP TABLE IF EXISTS tours;
DROP TABLE IF EXISTS insurance_types;
DROP TABLE IF EXISTS client_docs;
DROP TABLE IF EXISTS insurance_agents;
DROP TABLE IF EXISTS transport;
DROP TABLE IF EXISTS transport_types;
DROP TABLE IF EXISTS carriers;
DROP TABLE IF EXISTS states;
DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS doc_types;
DROP TABLE IF EXISTS clients;

CREATE TABLE carriers (
	carrier_name nvarchar(32) NOT NULL,
	carrier_INN char(12) NOT NULL,
	carrier_cost decimal(10,2) DEFAULT 0 NULL,
	PRIMARY KEY (carrier_INN),
	UNIQUE (carrier_INN)
);

CREATE TABLE clients (
	client_name nvarchar(32) NOT NULL,
	client_phone char(20) NOT NULL,
	client_personal_sale int DEFAULT 0 NOT NULL,
	client_birth_date date NULL,
	client_address nvarchar(128) NULL,
	PRIMARY KEY (client_phone),
	UNIQUE (client_phone)
);

CREATE TABLE countries (
	country_id int IDENTITY(1,1) NOT NULL,
	country_name nvarchar(32) NOT NULL,
	PRIMARY KEY (country_id)
);

CREATE TABLE doc_types (
	doc_type_id int IDENTITY(1,1) NOT NULL,
	doc_type_name nvarchar(32) NOT NULL,
	PRIMARY KEY (doc_type_id)
);

CREATE TABLE insurance_agents (
	insurance_agent_INN char(12) NOT NULL,
	insurance_agent_name nvarchar(32) NOT NULL,
	PRIMARY KEY (insurance_agent_INN),
	UNIQUE (insurance_agent_INN)
);

CREATE TABLE insurance_types (
	insurance_type_id int IDENTITY(1,1) NOT NULL,
	insurance_type_name nvarchar(64) NOT NULL,
	PRIMARY KEY (insurance_type_id)
);

CREATE TABLE transport_types (
	transport_type_id int IDENTITY(1,1) NOT NULL,
	transport_type_name nvarchar(32) NOT NULL,
	PRIMARY KEY (transport_type_id)
);

CREATE TABLE client_docs (
	client_doc_number char(16) NOT NULL,
	client_doc_issued_by nvarchar(128) NULL,
	client_doc_issue_date date NULL,
	client_phone char(20) NOT NULL,
	doc_type_id int NOT NULL,
	PRIMARY KEY (client_doc_number),
	UNIQUE (client_doc_number),
	FOREIGN KEY (client_phone) REFERENCES clients(client_phone) ON UPDATE CASCADE,
	FOREIGN KEY (doc_type_id) REFERENCES doc_types(doc_type_id)
);

CREATE TABLE insurance (
	insurance_coverage_amount decimal(10,2) NULL,
	insurance_conclusion_date date NULL,
	insurance_period int NULL,
	insurance_contract_id int IDENTITY(1,1) NOT NULL,
	insurance_premium decimal(10,2) DEFAULT 0 NULL,
	insurance_agent_INN char(12) NOT NULL,
	insurance_type_id int NOT NULL,
	PRIMARY KEY (insurance_contract_id),
	FOREIGN KEY (insurance_agent_INN) REFERENCES insurance_agents(insurance_agent_INN) ON UPDATE CASCADE,
	FOREIGN KEY (insurance_type_id) REFERENCES insurance_types(insurance_type_id)
);

CREATE TABLE states (
	state_id int IDENTITY(1,1) NOT NULL,
	state_name nvarchar(32) NOT NULL,
	country_id int NOT NULL,
	PRIMARY KEY (state_id),
	FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

CREATE TABLE tours (
	tour_id int IDENTITY(1,1) NOT NULL,
	tour_name nvarchar(128) NULL,
	tour_cost decimal(10,2) DEFAULT 0 NULL,
	tour_food_type nvarchar(32) DEFAULT 'RO' NULL,
  tour_duration	int	DEFAULT 1 NOT NULL,
	state_id int NOT NULL,
	PRIMARY KEY (tour_id),
	FOREIGN KEY (state_id) REFERENCES states(state_id),
	CHECK ([tour_food_type]='UAI' OR [tour_food_type]='AI' OR [tour_food_type]='FB' OR [tour_food_type]='HB' OR [tour_food_type]='BB' OR [tour_food_type]='RO')
);

CREATE TABLE transport (
	transport_seats_count int NOT NULL,
	transport_state_id nvarchar(15) NOT NULL,
	carrier_INN char(12) NOT NULL,
	transport_type_id int NULL,
	PRIMARY KEY (transport_state_id),
	UNIQUE (transport_state_id),
	FOREIGN KEY (carrier_INN) REFERENCES carriers(carrier_INN) ON UPDATE CASCADE,
	FOREIGN KEY (transport_type_id) REFERENCES transport_types(transport_type_id)
);

CREATE TABLE hotels (
	hotel_id int IDENTITY(1,1) NOT NULL,
	hotel_stars_count int NULL,
	hotel_name nvarchar(128) NULL,
	hotel_booking_site nvarchar(128) NULL,
	hotel_booking_cost decimal(10,2) DEFAULT 0 NULL,
	state_id int NOT NULL,
	PRIMARY KEY (hotel_id),
	FOREIGN KEY (state_id) REFERENCES states(state_id)
);

CREATE TABLE contracts (
	contract_id int IDENTITY(1,1) NOT NULL,
	contract_date_start date NULL,
	contract_date_end date NULL,
	contract_total_amount decimal(10,2) DEFAULT 0 NULL,
	client_phone char(20) NOT NULL,
	tour_id int NOT NULL,
	hotel_id int NULL,
	client_doc_number char(16) NOT NULL,
	transport_state_id nvarchar(15) NOT NULL,
	insurance_contract_id int NOT NULL,
	PRIMARY KEY (contract_id),
	FOREIGN KEY (client_phone) REFERENCES clients(client_phone) ON UPDATE CASCADE,
	FOREIGN KEY (client_doc_number) REFERENCES client_docs(client_doc_number),
	FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id),
	FOREIGN KEY (insurance_contract_id) REFERENCES insurance(insurance_contract_id),
	FOREIGN KEY (tour_id) REFERENCES tours(tour_id),
	FOREIGN KEY (transport_state_id) REFERENCES transport(transport_state_id)
);

INSERT INTO clients (client_name,client_phone,client_personal_sale,client_birth_date,client_address) VALUES
	 (N'Архипова М. Ю.',N'79102356984',15,'1986-10-01',N'Ярославль, Гоголя, 4'),
	 (N'Соболева В. Д.',N'79102515283',0,'1999-12-08',N'Данилов, Петербургская, 63'),
	 (N'Кулешова П. А.',N'79103205068',15,'1976-12-30',N'Тутаев, Герцена, 42'),
	 (N'Соловьев В. А.',N'79104526983',0,'1986-02-28',N'Ростов, Декабристов, 3'),
	 (N'Кузнецова Е. С.',N'79105824148',0,'1993-11-19',N'Данилов, Вятская, 17'),
	 (N'Софронова Е. Д.',N'79151236460',0,'1987-06-12',N'Ярославль, Ленина, 40'),
	 (N'Филатов И. М.',N'79151236461',0,'1993-01-18',N'Ярославль, Стопани, 10'),
	 (N'Крючкова В. А.',N'79151236462',5,'2001-11-03',N'Ярославль, Союзная, 144'),
	 (N'Орлова А. Ф.',N'79151236463',7,'1984-06-06',N'Тутаев, Ленина, 10'),
	 (N'Калинин А. Д.',N'79151236464',0,'1999-10-09',N'Углич, Февральская, 28'),
	 (N'Титова П. М.',N'79151236465',0,'1987-06-12',N'Углич, Ленина, 22'),
	 (N'Колесников Я. П.',N'79151236466',0,'1994-03-08',N'Дубки, Гагарина, 3'),
	 (N'Бондарева А. В.',N'79159321596',0,'1989-01-01',N'Ярославль, Папанина, 7'),
	 (N'Орлова А. Е.',N'79159452658',0,'1998-07-18',N'Нерехта, Седова, 5'),
	 (N'Иванов Р. Р.',N'79159632154',0,'2001-12-09',N'Мышкин, Павлова, 10'),
	 (N'Архипова А. М.',N'79159700452',0,'1999-08-03',N'Рыбинск, Луначарского, 99'),
	 (N'Блинова П. А.',N'79159836482',5,'1986-01-12',N'Гаврилов Ям, Клубная, 32'),
	 (N'Третьякова М. Ф.',N'79159842562',0,'1999-03-07',N'Ростов, Моравского, 18'),
	 (N'Семенов С. И.',N'79185263265',30,'1996-04-09',N'Ярославль, 8 марта, 10'),
	 (N'Некрасова А. Д.',N'79187452525',0,'2001-09-04',N'Некрасово, Центральная, 4'),
	 (N'Покровская А. А.',N'79189526452',10,'2002-01-12',N'Переславль Залесский, Светлая, 5'),
	 (N'Малышев Д. М.',N'79301274586',4,'1999-01-06',N'Рыбинск, Пушкина, 4'),
	 (N'Островский Д. Н.',N'79401253265',0,'1975-06-15',N'Ярославль, Углическая, 56'),
	 (N'Назарова В. И.',N'79652635325',0,'1994-07-06',N'Гаврилов Ям, Попова, 17'),
	 (N'Голубева В. Б.',N'79653215124',5,'1998-01-20',N'Рыбинск, Ленина, 17'),
	 (N'Филиппов А. Д.',N'79653265986',0,'1955-11-09',N'Рыбинск, Бульварная, 7'),
	 (N'Тарасова А. Т.',N'79655175553',18,'1945-09-01',N'Углич, Нахимсона, 3'),
	 (N'Марков А. Д.',N'79801256598',0,'1968-03-10',N'Ярославль, Маланова, 14'),
	 (N'Шапошникова М. Ф.',N'79802563256',5,'2002-12-02',N'Ростов, Спартаковская, 1'),
	 (N'Орлов А. А.',N'79803258456',15,'1973-08-16',N'Рыбинск, Свободы, 5'),
	 (N'Панов А. Т.',N'79803265984',8,'1988-08-11',N'Ярославль, 1-ая Новодуховская,1'),
	 (N'Казакова Д. Д.',N'79804521258',0,'1985-09-03',N'Ярославль, пр-т Ленина, 104'),
	 (N'Сорокина В. К.',N'79804523265',0,'2001-09-19',N'Ростов, Карла Маркса, 73');
	 
SET IDENTITY_INSERT doc_types ON;
INSERT INTO doc_types (doc_type_id,doc_type_name) VALUES
	 (1,N'Паспорт'),
	 (2,N'Свидетельство о рождении'),
	 (3,N'Водительские права'),
	 (4,N'СНИЛС'),
	 (5,N'Приписное');
SET IDENTITY_INSERT doc_types OFF;
	 
SET IDENTITY_INSERT countries ON;
INSERT INTO countries (country_id,country_name) VALUES
	 (1,N'Россия'),
	 (2,N'Казахстан'),
	 (3,N'Узбекистан'),
	 (4,N'Турция'),
	 (5,N'Греция'),
	 (6,N'Германия'),
	 (7,N'Польша'),
	 (8,N'Венгрия'),
	 (9,N'Армения'),
	 (10,N'Черногория'),
	 (11,N'Китай');
SET IDENTITY_INSERT countries OFF;
	 
SET IDENTITY_INSERT states ON;
INSERT INTO states (state_id,state_name,country_id) VALUES
	 (1,N'Москва',1),
	 (2,N'Ярославль',1),
	 (3,N'Санкт-Петербург',1),
	 (4,N'Плес',1),
	 (5,N'Астана',2),
	 (6,N'Караганда',2),
	 (7,N'Павлодар',2),
	 (8,N'Ташкент',3),
	 (9,N'Самарканд',3),
	 (10,N'Стамбул',4),
	 (11,N'Анкара',4),
	 (12,N'Анталья',4),
	 (13,N'Фетхие',4),
	 (14,N'Анапа',1),
	 (16,N'Абакан',1),
	 (17,N'Салоники',5),
	 (18,N'Катерини',5),
	 (19,N'Лариса',5),
	 (20,N'Горно-Алтайск',1),
	 (21,N'Минусинк',1),
	 (22,N'Шушенское',1),
	 (23,N'Златоуст',1),
	 (24,N'Екатеринбург',1),
	 (25,N'Мурманск',1),
	 (26,N'Никель',1),
	 (27,N'Бонн',6),
	 (28,N'Нюрнберг',6),
	 (29,N'Патрикен-Кирхе',6),
	 (30,N'Мюнхен',6),
	 (31,N'Троисдорф',6),
	 (32,N'Иркутск',1);
SET IDENTITY_INSERT states OFF;
	 
INSERT INTO carriers (carrier_name,carrier_INN,carrier_cost) VALUES
	 (N'Автобусы 76',N'1234567891',12500.00),
	 (N'Неоплан',N'1234567892',15700.00),
	 (N'S7',N'2342325345',18900.00),
	 (N'БлаБлаКар',N'2342342342',3200.00),
	 (N'Евросиб',N'2342342433',14005.00),
	 (N'Башавтотранс',N'2344242334',8000.00),
	 (N'Победа',N'3243433434',5700.00),
	 (N'Русский экспресс',N'3424342424',71000.00),
	 (N'Яндекс Драйв',N'5434545444',3900.00),
	 (N'РЖД',N'7708503727',9800.00),
	 (N'Аэрофлот',N'7712040126',19600.00),
	 (N'Аврора',N'7712043444',8000.00);
	 
SET IDENTITY_INSERT transport_types ON;
INSERT INTO transport_types (transport_type_id,transport_type_name) VALUES
	 (1,N'Автобус'),
	 (2,N'Автомобиль'),
	 (3,N'Поезд'),
	 (4,N'Бизнес-джет'),
	 (5,N'Самолет'),
	 (6,N'Такси');
SET IDENTITY_INSERT transport_types OFF;
	 
INSERT INTO transport (transport_seats_count,transport_state_id,carrier_INN,transport_type_id) VALUES
	 (250,N'12345000',N'7708503727',3),
	 (8,N'12345001',N'7712040126',4),
	 (8,N'12345002',N'7712040126',4),
	 (70,N'12345003',N'7712040126',5),
	 (200,N'14668432',N'3243433434',5),
	 (120,N'54345688',N'3243433434',5),
	 (600,N'54645655',N'2342325345',5),
	 (12,N'ВА543455',N'2342342433',4),
	 (5,N'Н225ОО76',N'5434545444',2),
	 (12,N'Н785ТР76',N'7708503727',1),
	 (10,N'С152КВ76',N'7708503727',NULL),
	 (7,N'Т852ВЕ04',N'2342342342',2),
	 (5,N'Х415АР44',N'2342342342',2),
	 (5,N'Х432ВХ76',N'1234567892',NULL);

INSERT INTO insurance_agents (insurance_agent_INN,insurance_agent_name) VALUES
	 (N'123701',N'Альфа-Страхование'),
	 (N'123702',N'Тинькофф-Страхование'),
	 (N'123703',N'Сбер-Страхование');
	
INSERT INTO client_docs (client_doc_number,client_doc_issued_by,client_doc_issue_date,client_phone,doc_type_id) VALUES
	 (N'1234560004',NULL,NULL,N'79151236461',3),
	 (N'1234560015',NULL,NULL,N'79151236462',1),
	 (N'2365783445',N'РОВД Мурманска','2000-09-19',N'79105824148',1),
	 (N'2506738100',N'РОВД Москвы','2009-06-15',N'79102356984',1),
	 (N'3453534534',N'МФЦ Ярославль','2008-07-14',N'79103205068',1),
	 (N'3454767567',N'УМВД Уссурийска','2021-02-18',N'79102515283',1),
	 (N'3465455675',N'МФЦ Костромы','2005-12-26',N'79159452658',3),
	 (N'3556674333',N'УМВД Вологды','2020-12-21',N'79151236464',1),
	 (N'3916559445',N'УМВД Углича','2017-06-02',N'79187452525',2),
	 (N'5434677664',N'УМВД Москвы','2008-10-07',N'79104526983',1),
	 (N'5645672222',N'МФЦ Вологоды','2004-09-30',N'79159321596',1),
	 (N'7629559531',N'г. Грозный','2003-10-20',N'79803258456',1),
	 (N'7800149749',N'РОВД Ярославля','2006-02-02',N'79159842562',1),
	 (N'7800185415',N'УМВД Перми','2012-12-20',N'79159836482',2),
	 (N'7801645993',N'УМВД Тутаева','2014-03-18',N'79185263265',2),
	 (N'7802154142',N'МВД Мышкина','2005-05-24',N'79189526452',3),
	 (N'7810121314',N'УМВД РОССИИ','2010-10-05',N'79151236460',1),
	 (N'7810122629',N'МФЦ Некрасово','2014-12-15',N'79401253265',3),
	 (N'7810151599',N'УМВД Углича','2003-10-20',N'79301274586',3),
	 (N'7812121314',N'УМВД РОССИИ','2012-06-23',N'79151236466',1),
	 (N'7812121319',N'УМВД РОССИИ','2011-11-13',N'79151236463',1),
	 (N'7812125659',N'МФЦ Костромы','2008-10-07',N'79653265986',1),
	 (N'7812129992',N'УМВД Переславля-Залесского','2019-02-13',N'79653215124',1),
	 (N'7813124599',N'УМВД Пошехонья','2013-11-27',N'79652635325',1),
	 (N'7814559252',N'УМВД Красноярска','2017-11-10',N'79655175553',1),
	 (N'7815256625',N'УМВД Уссурийска','2013-11-27',N'79803265984',1),
	 (N'7815262894',N'МВД Читы','2008-02-20',N'79159632154',3),
	 (N'7815855995',N'УМВД Москвы','2020-12-21',N'79804521258',1),
	 (N'7815986332',N'УМВД Абакана','2006-02-02',N'79801256598',1),
	 (N'7816569895',N'МВД Тутаева','2017-06-02',N'79802563256',1),
	 (N'7821849955',N'УМВД Перми','2017-11-10',N'79159700452',1),
	 (N'7841515262',N'РОВД Тутаева','2014-03-18',N'79804523265',1),
	 (N'9019125656',N'УМВД Красноярска','2008-03-22',N'79151236465',3);

SET IDENTITY_INSERT insurance_types ON;
INSERT INTO insurance_types (insurance_type_id,insurance_type_name) VALUES
	 (1,N'Медицинское страхование'),
	 (2,N'Страхование багажа'),
	 (3,N'Страхование билетов');
SET IDENTITY_INSERT insurance_types OFF;
	
SET IDENTITY_INSERT tours ON;
INSERT INTO tours (tour_id,tour_name,tour_cost,tour_food_type,state_id,tour_duration) VALUES
	 (1,N'Пешком по золотому кольцу',5200.00,N'RO',2,10),
	 (2,N'Каналы Санкт-Петербурга',9800.00,N'AI',3,7),
	 (3,N'Золотая осень',2500.00,N'UAI',4,3),
	 (4,N'Тур в Самарканд',16800.00,N'FB',9,12),
	 (5,N'7 дней в Фетхие',56000.00,N'AI',13,7),
	 (6,N'Ликийская тропа',27000.00,N'RO',12,14),
	 (7,N'Новый год в Анапе',18200.00,N'FB',14,5),
	 (8,N'Шавлинские озера',11000.00,N'RO',16,21),
	 (9,N'Восхождение на Олимп',50000.00,N'UAI',18,35),
	 (10,N'Поход в Ергаки',14300.00,N'RO',21,7),
	 (11,N'Неделя на Таганае',16000.00,N'RO',23,7),
	 (12,N'Велопоход на Кольский',37000.00,N'FB',26,21),
	 (13,N'Рождество в Нюрнберге',45000.00,N'UAI',28,10),
	 (14,N'Горнолыжный тур Германия',95110.00,N'HB',29,7),
	 (15,N'Зимний Таганай',31000.00,N'FB',23,12),
	 (16,N'На коньках по Байкалу',18100.00,N'RO',32,15);
SET IDENTITY_INSERT tours OFF;

SET IDENTITY_INSERT hotels ON;
INSERT INTO hotels (hotel_id,hotel_stars_count,hotel_name,hotel_booking_site,hotel_booking_cost,state_id) VALUES
	 (1,5,N'Летуния Клуб',NULL,14000.00,13),
	 (2,4,N'Ринг Премьер',NULL,6500.00,2),
	 (3,4,N'ИБИС',NULL,5600.00,2),
	 (4,3,N'Космос',NULL,4200.00,1),
	 (5,4,N'Хостел Друзья',NULL,3200.00,3),
	 (6,4,N'Гостинница Астана',NULL,5000.00,5),
	 (7,5,N'Отель Самарканд',NULL,4000.00,9),
	 (8,1,N'Хостел',NULL,890.00,4),
	 (9,5,N'Отель Премьер',NULL,3500.00,9),
	 (10,0,N'Загородный сад',NULL,8500.00,12),
	 (11,1,N'Хостел Достоевский',NULL,840.00,14),
	 (12,5,N'Отель Яхонт',NULL,5600.00,16),
	 (13,4,N'Усадьба Уткино',NULL,12000.00,18),
	 (14,0,N'Ранчо 6666',NULL,6900.00,21),
	 (15,3,N'Комаровский',NULL,3100.00,23),
	 (16,0,N'Хостел Верный',NULL,360.00,26),
	 (17,5,N'Отель у театра',NULL,7800.00,28),
	 (18,5,N'СК Круиз',NULL,5200.00,29),
	 (19,4,N'Ринг Рояль',NULL,8500.00,23),
	 (20,0,N'Хостел Южный',NULL,950.00,32);
SET IDENTITY_INSERT hotels OFF;
	
SET IDENTITY_INSERT insurance ON;
INSERT INTO insurance (insurance_coverage_amount,insurance_conclusion_date,insurance_period,insurance_contract_id,insurance_premium,insurance_agent_INN,insurance_type_id) VALUES
	 (100000.00,'2021-08-11',14,1,2500.00,N'123701',1),
	 (25000.00,'2022-04-05',100,2,500.00,N'123701',3),
	 (75000.00,'2022-06-01',14,3,3500.00,N'123703',2),
	 (50000.00,'2022-09-30',90,4,6500.30,N'123701',1),
	 (98100.00,'2022-12-19',7,5,18360.40,N'123702',2),
	 (36200.00,'2022-01-09',14,6,2500.00,N'123701',2),
	 (80000.00,'2021-09-07',14,7,30000.00,N'123702',3),
	 (5000.00,'2022-08-29',30,8,150.00,N'123702',1),
	 (8900.00,'2021-12-01',180,9,900.00,N'123701',1),
	 (15000.00,'2022-01-09',180,10,3000.00,N'123703',2),
	 (32000.00,'2022-09-25',90,11,8000.00,N'123703',3),
	 (25000.00,'2022-07-16',30,12,1200.00,N'123703',3),
	 (7800.00,'2021-09-08',60,13,800.00,N'123701',2),
	 (17000.00,'2020-05-08',7,14,1600.00,N'123702',1);
SET IDENTITY_INSERT insurance OFF;
	
SET IDENTITY_INSERT contracts ON;
INSERT INTO contracts (contract_id,contract_date_start,contract_date_end,contract_total_amount,client_phone,tour_id,hotel_id,client_doc_number,transport_state_id,insurance_contract_id) VALUES
	 (1,'2022-11-10','2023-11-14',12500.00,N'79151236460',2,5,N'7810121314',N'Н785ТР76',1),
	 (2,'2022-11-10','2022-11-14',13000.00,N'79151236466',2,5,N'7812121314',N'12345002',1),
	 (8,'2021-06-05','2021-06-15',9625.00,N'79151236463',5,1,N'7812121319',N'Н785ТР76',2),
	 (12,'2022-05-25','2022-06-14',14300.00,N'79803258456',15,19,N'7629559531',N'Х432ВХ76',3),
	 (13,'2022-06-29','2022-07-10',19700.00,N'79103205068',13,17,N'3453534534',N'Х432ВХ76',10),
	 (14,'2022-08-10','2022-08-20',9400.00,N'79801256598',8,12,N'7815986332',N'54345688',2),
	 (15,'2022-09-02','2022-09-11',5200.00,N'79159842562',9,13,N'7800149749',N'54345688',7),
	 (16,'2022-03-10','2022-03-16',7356.00,N'79185263265',12,16,N'7801645993',N'Н225ОО76',1),
	 (17,'2022-01-27','2022-02-04',9560.00,N'79301274586',11,15,N'7810151599',N'14668432',12),
	 (18,'2022-01-17','2022-02-27',6520.00,N'79803265984',1,2,N'7815256625',N'Т852ВЕ04',14),
	 (19,'2022-06-16','2022-06-30',45320.00,N'79189526452',12,16,N'7802154142',N'ВА543455',4),
	 (20,'2022-09-22','2022-09-29',14600.00,N'79159700452',16,20,N'7821849955',N'12345000',11),
	 (21,'2022-07-04','2022-07-19',17900.00,N'79185263265',3,8,N'7801645993',N'12345000',3),
	 (22,'2022-05-04','2022-05-14',25000.00,N'79301274586',11,15,N'7810151599',N'54345688',7),
	 (23,'2022-12-15','2022-12-25',36100.00,N'79185263265',2,5,N'7801645993',N'Х432ВХ76',1),
	 (24,'2022-08-26','2022-09-09',11450.00,N'79655175553',5,1,N'7814559252',N'Н225ОО76',8),
	 (25,'2021-03-23','2021-03-30',12200.00,N'79159842562',7,11,N'7800149749',N'54645655',4),
	 (26,'2021-11-01','2021-11-14',9650.00,N'79159836482',10,14,N'7800185415',N'С152КВ76',11),
	 (27,'2021-08-24','2021-08-30',18705.00,N'79189526452',4,9,N'7802154142',N'12345001',7),
	 (28,'2022-09-19','2022-09-28',32410.00,N'79159452658',13,17,N'3465455675',N'12345001',6),
	 (29,'2021-02-03','2021-02-10',9652.00,N'79151236463',13,17,N'7812121319',N'С152КВ76',2),
	 (30,'2021-05-20','2021-05-27',36385.00,N'79804523265',9,13,N'7841515262',N'54645655',5),
	 (31,'2022-12-02','2022-12-30',14650.00,N'79803258456',1,2,N'7629559531',N'Х432ВХ76',4);
SET IDENTITY_INSERT contracts OFF;	
