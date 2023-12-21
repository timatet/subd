CREATE TABLE dbo_s.Person (
  ID INTEGER PRIMARY KEY,
  name VARCHAR(100)
) AS NODE;

CREATE TABLE dbo_s.Restaurant (
  ID INTEGER NOT NULL,
  name VARCHAR(100),
  City VARCHAR(100)
) AS NODE;

CREATE TABLE dbo_s.City (
  ID INTEGER PRIMARY KEY,
  name VARCHAR(100),
  stateName VARCHAR(100)
) AS NODE;

CREATE TABLE dbo_s.likes (rating INTEGER) AS EDGE;
CREATE TABLE dbo_s.friendOf AS EDGE;
CREATE TABLE dbo_s.livesIn AS EDGE;
CREATE TABLE dbo_s.locatedIn AS EDGE;

INSERT INTO dbo_s.Person (ID, name)
	VALUES (1,N'Ваня')
		 , (2,N'Петя')
		 , (3,N'Катя')
		 , (4,N'Никита')
		 , (5,N'Аня');

INSERT INTO dbo_s.Restaurant (ID, name, City)
	VALUES (1, N'Мили',N'Ярославль')
		 , (2, N'Топ Хопс',N'Санкт-Петербург')
		 , (3, N'Грабли',N'Москва');

INSERT INTO dbo_s.City (ID, name, stateName)
	VALUES (1,N'Ярославль',N'ЦФО')
		 , (2,N'Санкт-Петербург',N'СФО')
		 , (3,N'Москва',N'ЦФО');

INSERT INTO dbo_s.likes
	VALUES ((SELECT $node_id FROM dbo_s.Person WHERE ID = 1), (SELECT $node_id FROM dbo_s.Restaurant WHERE ID = 1), 9)
		 , ((SELECT $node_id FROM dbo_s.Person WHERE ID = 2), (SELECT $node_id FROM dbo_s.Restaurant WHERE ID = 2), 9)
		 , ((SELECT $node_id FROM dbo_s.Person WHERE ID = 3), (SELECT $node_id FROM dbo_s.Restaurant WHERE ID = 3), 9)
		 , ((SELECT $node_id FROM dbo_s.Person WHERE ID = 4), (SELECT $node_id FROM dbo_s.Restaurant WHERE ID = 3), 9)
		 , ((SELECT $node_id FROM dbo_s.Person WHERE ID = 5), (SELECT $node_id FROM dbo_s.Restaurant WHERE ID = 3), 9);

INSERT INTO dbo_s.livesIn
	VALUES ((SELECT $node_id FROM dbo_s.Person WHERE ID = 1), (SELECT $node_id FROM dbo_s.City WHERE ID = 1))
		 , ((SELECT $node_id FROM dbo_s.Person WHERE ID = 2), (SELECT $node_id FROM dbo_s.City WHERE ID = 2))
		 , ((SELECT $node_id FROM dbo_s.Person WHERE ID = 3), (SELECT $node_id FROM dbo_s.City WHERE ID = 3))
		 , ((SELECT $node_id FROM dbo_s.Person WHERE ID = 4), (SELECT $node_id FROM dbo_s.City WHERE ID = 3))
		 , ((SELECT $node_id FROM dbo_s.Person WHERE ID = 5), (SELECT $node_id FROM dbo_s.City WHERE ID = 1));

INSERT INTO dbo_s.locatedIn
	VALUES ((SELECT $node_id FROM dbo_s.Restaurant WHERE ID = 1), (SELECT $node_id FROM dbo_s.City WHERE ID =1))
		 , ((SELECT $node_id FROM dbo_s.Restaurant WHERE ID = 2), (SELECT $node_id FROM dbo_s.City WHERE ID =2))
		 , ((SELECT $node_id FROM dbo_s.Restaurant WHERE ID = 3), (SELECT $node_id FROM dbo_s.City WHERE ID =3));

INSERT INTO dbo_s.friendOf
	VALUES ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 1), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 2))
		 , ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 2), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 1))
		 
		 , ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 2), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 3))
		 , ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 3), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 2))
		 
		 , ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 3), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 1))
		 , ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 1), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 3))
		 
		 , ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 4), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 2))
		 , ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 2), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 4))
		 
		 , ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 5), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 4))
		 , ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 4), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 5));

-- Поиск самых короткий путей дружбы Кати с другими людьми
WITH CTE AS (
	SELECT 
		P1.name AS P1, 
		P2.name AS P2, 
		R.name AS R
	FROM 
		dbo_s.Person AS P1,
		dbo_s.Person AS P2,
		dbo_s.Restaurant AS R,
		dbo_s.likes AS li1,
		dbo_s.likes AS li2
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
		dbo_s.Person AS Person1,
		dbo_s.friendOf FOR PATH AS fo,
		dbo_s.Person FOR PATH AS Person2
	WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
	AND Person1.name = 'Катя'
) AS Q, CTE
WHERE Q.LastNode != 'Катя'
AND CTE.P1 = Q.PersonName AND CTE.P2 = Q.LastNode

-- Предположим Катя подружилась с Аней
INSERT INTO dbo_s.friendOf
	VALUES ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 3), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 5))
		 , ((SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 5), (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 3))
		 
-- И вдруг снова перестала дружить
DELETE FROM dbo_s.friendOf 
	WHERE ($from_id = (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 3) 
			AND $to_id = (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 5))
	   OR ($from_id = (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 5) 
			AND $to_id = (SELECT $NODE_ID FROM dbo_s.Person WHERE ID = 3));