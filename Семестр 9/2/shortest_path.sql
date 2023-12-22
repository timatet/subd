CREATE DATABASE L2_SP
USE L2_SP

CREATE TABLE dbo.Person (
  ID INTEGER PRIMARY KEY,
  name VARCHAR(100)
) AS NODE;

CREATE TABLE dbo.Restaurant (
  ID INTEGER NOT NULL,
  name VARCHAR(100),
  City VARCHAR(100)
) AS NODE;

CREATE TABLE dbo.City (
  ID INTEGER PRIMARY KEY,
  name VARCHAR(100),
  stateName VARCHAR(100)
) AS NODE;

CREATE TABLE dbo.likes (rating INTEGER) AS EDGE;
CREATE TABLE dbo.friendOf AS EDGE;
CREATE TABLE dbo.livesIn AS EDGE;
CREATE TABLE dbo.locatedIn AS EDGE;

INSERT INTO dbo.Person (ID, name)
	VALUES (1,N'Ваня')
		 , (2,N'Петя')
		 , (3,N'Катя')
		 , (4,N'Никита')
		 , (5,N'Аня');

INSERT INTO dbo.Restaurant (ID, name, City)
	VALUES (1, N'Мили',N'Ярославль')
		 , (2, N'Топ Хопс',N'Санкт-Петербург')
		 , (3, N'Грабли',N'Москва');

INSERT INTO dbo.City (ID, name, stateName)
	VALUES (1,N'Ярославль',N'ЦФО')
		 , (2,N'Санкт-Петербург',N'СФО')
		 , (3,N'Москва',N'ЦФО');

INSERT INTO dbo.likes
	VALUES ((SELECT $node_id FROM dbo.Person WHERE ID = 1), (SELECT $node_id FROM dbo.Restaurant WHERE ID = 1), 9)
		 , ((SELECT $node_id FROM dbo.Person WHERE ID = 2), (SELECT $node_id FROM dbo.Restaurant WHERE ID = 2), 9)
		 , ((SELECT $node_id FROM dbo.Person WHERE ID = 3), (SELECT $node_id FROM dbo.Restaurant WHERE ID = 3), 9)
		 , ((SELECT $node_id FROM dbo.Person WHERE ID = 4), (SELECT $node_id FROM dbo.Restaurant WHERE ID = 3), 9)
		 , ((SELECT $node_id FROM dbo.Person WHERE ID = 5), (SELECT $node_id FROM dbo.Restaurant WHERE ID = 3), 9);

INSERT INTO dbo.livesIn
	VALUES ((SELECT $node_id FROM dbo.Person WHERE ID = 1), (SELECT $node_id FROM dbo.City WHERE ID = 1))
		 , ((SELECT $node_id FROM dbo.Person WHERE ID = 2), (SELECT $node_id FROM dbo.City WHERE ID = 2))
		 , ((SELECT $node_id FROM dbo.Person WHERE ID = 3), (SELECT $node_id FROM dbo.City WHERE ID = 3))
		 , ((SELECT $node_id FROM dbo.Person WHERE ID = 4), (SELECT $node_id FROM dbo.City WHERE ID = 3))
		 , ((SELECT $node_id FROM dbo.Person WHERE ID = 5), (SELECT $node_id FROM dbo.City WHERE ID = 1));

INSERT INTO dbo.locatedIn
	VALUES ((SELECT $node_id FROM dbo.Restaurant WHERE ID = 1), (SELECT $node_id FROM dbo.City WHERE ID =1))
		 , ((SELECT $node_id FROM dbo.Restaurant WHERE ID = 2), (SELECT $node_id FROM dbo.City WHERE ID =2))
		 , ((SELECT $node_id FROM dbo.Restaurant WHERE ID = 3), (SELECT $node_id FROM dbo.City WHERE ID =3));

INSERT INTO dbo.friendOf
	VALUES ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 1), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 2))
		 , ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 2), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 1))
		 
		 , ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 2), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 3))
		 , ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 3), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 2))
		 
		 , ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 3), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 1))
		 , ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 1), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 3))
		 
		 , ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 4), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 2))
		 , ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 2), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 4))
		 
		 , ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 5), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 4))
		 , ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 4), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 5));

-- Поиск самых короткий путей дружбы Кати с другими людьми
WITH CTE AS (
	SELECT 
		P1.name AS P1, 
		P2.name AS P2, 
		R.name AS R
	FROM 
		dbo.Person AS P1,
		dbo.Person AS P2,
		dbo.Restaurant AS R,
		dbo.likes AS li1,
		dbo.likes AS li2
	WHERE MATCH(P1-(li1)->R<-(li2)-P2) 
	AND P1.name != P2.name 
)
SELECT 
	PersonName, 
	Distance, 
	Friends, 
	LastNode, 
	CTE.R AS Restauraunt
FROM (
	SELECT
		Person1.name AS PersonName,
		COUNT(fo.$edge_id) WITHIN GROUP (GRAPH PATH) AS Distance,
		STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
		LAST_VALUE(Person2.name) WITHIN GROUP (GRAPH PATH) AS LastNode
	FROM
		dbo.Person AS Person1,
		dbo.friendOf FOR PATH AS fo,
		dbo.Person FOR PATH AS Person2
	WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
	AND Person1.name = 'Катя'
) AS Q, CTE
WHERE Q.LastNode != 'Катя'
AND CTE.P1 = Q.PersonName AND CTE.P2 = Q.LastNode

-- Предположим Катя подружилась с Аней
INSERT INTO dbo.friendOf
	VALUES ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 3), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 5))
		 , ((SELECT $NODE_ID FROM dbo.Person WHERE ID = 5), (SELECT $NODE_ID FROM dbo.Person WHERE ID = 3))
		 
-- И вдруг снова перестала дружить
DELETE FROM dbo.friendOf 
	WHERE ($from_id = (SELECT $NODE_ID FROM dbo.Person WHERE ID = 3) 
			AND $to_id = (SELECT $NODE_ID FROM dbo.Person WHERE ID = 5))
	   OR ($from_id = (SELECT $NODE_ID FROM dbo.Person WHERE ID = 5) 
			AND $to_id = (SELECT $NODE_ID FROM dbo.Person WHERE ID = 3));
