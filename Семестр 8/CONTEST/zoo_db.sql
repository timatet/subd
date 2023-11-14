CREATE TABLE [BiologicalSpecies]
(
  [Id]                  INT NOT NULL ,
  [Name]                NVARCHAR(50) NOT NULL ,
  [RedBookExist]        TINYINT NOT NULL ,
  [AverageFemaleWeight] REAL NOT NULL ,
  [AverageMaleWeight]   REAL NOT NULL ,
	PRIMARY KEY (Id)
);

CREATE TABLE [Employee]
(
  [Id]             INT NOT NULL PRIMARY KEY,
  [Name]           NVARCHAR(50) NOT NULL ,
  [DateOfBirth]    DATE NOT NULL ,
  [Male]           TINYINT NOT NULL ,
);

CREATE TABLE [Place]
(
  [Id]         INT NOT NULL ,
  [EmployeeId] INT NOT NULL ,
  [Square]     REAL NOT NULL ,
	PRIMARY KEY (Id),
  FOREIGN KEY (EmployeeId) REFERENCES [Employee](Id) ON DELETE CASCADE,
);

CREATE TABLE [Animal]
(
  [Id]                  INT NOT NULL ,
  [BiologicalSpeciesId] INT NOT NULL ,
  [PlaceId]             INT NOT NULL ,
  [Name]                NVARCHAR(50) NOT NULL ,
  [Weight]              REAL NOT NULL ,
  [Male]                INT NOT NULL ,
  PRIMARY KEY (ID),
  FOREIGN KEY (BiologicalSpeciesId) REFERENCES [BiologicalSpecies](Id) ON DELETE CASCADE,
  FOREIGN KEY (PlaceId) REFERENCES [Place](Id) ON DELETE CASCADE
);

INSERT INTO [BiologicalSpecies]
VALUES
  (1, 'Гепард', 0, 200, 250),
  (2, 'Носорог', 0, 400, 500),
  (3, 'Жираф', 0, 200, 220),
  (4, 'Лев', 1, 300, 310),
  (5, 'Альпака', 0, 100, 120),
  (6, 'Лесная соня', 1, 0.2, 0.25),
  (7, 'Снежный барс', 1, 120, 150),
  (8, 'Манул', 1, 100, 120),
  (9, 'Лори', 1, 1, 1.5),
  (10, 'Фенек', 0, 1.5, 2),
  (11, 'Суррикат', 0, 1, 1.3),
  (12, 'Тигр', 0, 180, 300),
  (13, 'Амурский Тигр',1, 200, 280),
  (14,'Лошадь Пржевальского',1,300,350)


INSERT INTO [Employee]
VALUES
  (1, 'Иван', '1995-05-25', 1),
  (2, 'Юлия', '1991-05-23', 0),
  (3, 'Игорь', '1983-08-21', 1),
  (4, 'Антон', '1972-09-01', 1),
  (5, 'Елена', '1956-11-11', 0),
  (6, 'Мария', '1953-11-12', 0),
  (7, 'Андрей', '1954-01-01', 1),
	(8, 'Петр', '1953-01-01', 1),
  (9, 'Павел', '1957-01-01', 1)

INSERT INTO [Place]
VALUES
  (1, 1, 300),
  (2, 1, 230),
  (3, 1, 504),
  (4, 1, 200),
  (5, 2, 140),
  (6, 2, 70),
  (7, 2, 2),
  (8, 3, 1),
  (9, 3, 0.5),
  (10, 3, 50),
  (11, 3, 12),
  (12, 4, 18),
  (13, 4, 30),
  (14, 5, 100),
  (15, 5, 103),
	(16, 4, 400),
  (17, 4, 50),
  (18, 5, 300),
  (19, 5, 500),
  (20, 5, 500),
  (21, 9, 100)


INSERT INTO [Animal]
VALUES
  (1, 1, 1, 'Беззубик', 230, 1),
  (2, 1, 1, 'Триана', 202, 0),
  (3, 1, 1, 'Лесси', 100, 0),

  (4, 2, 3, 'Мотомото', 550, 1),

  (5, 3, 2, 'Жирафа', 150, 0),
  (6, 3, 4, 'Длинношей', 202, 1),

  (7, 4, 5, 'Симба', 303, 1),
  (8, 4, 5, 'Нала', 287, 0),

  (9, 5, 10, 'Альпа', 102, 0),

  (10, 6, 9, 'Соня', 0.15, 0),
  (11, 6, 9, 'Аппа', 0.2, 1),

  (12, 7, 15, 'Холодок', 138, 1),

  (13, 8, 14, 'Трим', 130, 1),
  (14, 8, 14, 'Трея', 90, 0),

  (15, 9, 11, 'Лора', 1, 0),
  (16, 9, 11, 'Нера', 1.1, 0),
  (17, 9, 11, 'Иртис', 1.4, 1),

  (18, 10, 13, 'Фуня', 1.8, 0),

  (19, 11, 13, 'Сеня', 1.9, 1),
  (20, 11, 13, 'Сури', 1.2, 0),
  (21, 12, 17,'Вася', 210, 1),
  (22, 13, 13,'Умар', 280, 1),
  (23, 12, 11,'Умар', 250, 1)
