--Исходные данные из [Application].[People]
select [FullName], [CustomFields] , *
from [WideWorldImporters].[Application].[People]
--cоздаем схемы
CREATE SCHEMA [Nodes];
GO

CREATE SCHEMA [Edges];
GO
--Создаем таблицу узлов

CREATE TABLE Nodes.Person
(
  PersonID INTEGER NOT NULL PRIMARY KEY
  ,FullName NVARCHAR(50) NOT NULL
  ,[Language] NVARCHAR(50) NOT NULL
) AS NODE;
GO
-- Заполнение таблицы узлов
INSERT INTO Nodes.Person
(
  PersonID
  ,FullName
  ,[Language]
)
SELECT
  PersonID
  ,FullName
  ,[Language] = Languages.[Value]
FROM
  [WideWorldImporters].[Application].[People]
CROSS APPLY
  (SELECT * FROM OPENJSON (CustomFields, '$.OtherLanguages')) As Languages
WHERE
  Languages.[key] = 0;
GO
--просмотр; системный столбец $node_id
SELECT * FROM Nodes.Person;
GO
-- Просмотр системной информации - описание столбцов
SELECT
-- * --  
 name, graph_type,graph_type_desc,Type_name(system_type_id) as type
FROM
  sys.COLUMNS
WHERE
  object_id = object_id(N'[Nodes].[Person]')
GO
--создание таблицы ребер
CREATE TABLE Edges.friends
(
  StartDate DATETIME NOT NULL
)
AS EDGE;
GO
-- заполнение 1. те кто говорят на одном языке
WITH Friends_Same_Language AS
(
  SELECT
    P1.$node_id AS From_Node_Id
    ,P2.$node_id AS To_Node_Id
    ,GETDATE() AS StartDate
    ,Direction = ROW_NUMBER() OVER (PARTITION BY P1.[Language], P2.[language] ORDER BY (SELECT NULL))
    ,From_FullName = P1.FullName
    ,From_Language = P1.[Language]
    ,To_FullName = P2.FullName
    ,To_Language = P2.[Language]
  FROM
    Nodes.Person AS P1
  INNER JOIN
    Nodes.Person AS P2 ON P1.[Language] = P2.[Language]
  WHERE
    -- The person itself isn't included
    (P1.$node_id <> P2.$node_id)
)
INSERT INTO Edges.Friends
(
  $from_id
  ,$to_id
  ,StartDate
)
SELECT
  From_Node_Id
  ,To_Node_Id
  ,StartDate
FROM
  Friends_Same_Language
WHERE
  (Direction = 1);
GO
-- просмотр 
select * from [Edges].[friends]
-- Просмотр системной информации - описание столбцов
SELECT
-- * --  
 name, graph_type,graph_type_desc,Type_name(system_type_id) as type
FROM
  sys.COLUMNS
WHERE
  object_id = object_id(N'[Edges].[friends]')

  SELECT
  C.*
FROM
  sys.tables AS T
JOIN
  INFORMATION_SCHEMA.COLUMNS AS C ON C.Table_Name = T.[name] AND C.Table_Schema = SCHEMA_NAME(T.[schema_id])
WHERE
  (T.is_edge = 1)
ORDER BY
  C.Table_Schema, C.Table_Name
GO
-- заполнение 2. те кто говорят на одном языке
INSERT INTO Edges.Friends
(
  $from_id
  ,$to_id
  ,StartDate
)
SELECT
  From_Node_Id
  ,To_Node_Id
  ,StartDate
FROM
(
  SELECT DISTINCT TOP 40
    New_ID = NEWID()
    ,P1.$node_id AS From_Node_Id
    ,P2.$node_id AS To_Node_Id
    ,GETDATE() AS StartDate
  FROM
    Nodes.Person AS P1
  INNER JOIN
    Nodes.Person AS P2 ON P1.[Language] < P2.[Language]
  WHERE
    (P1.$node_id <> P2.$node_id)
  ORDER BY
    New_ID
) AS T;
GO


SELECT * FROM Edges.Friends;

-- sys.tables

select is_node, is_edge,*
from sys.tables
where is_node = 1 or is_edge=1

--******************
--MATCH
--******************
--все друзья
SELECT
  Person1.FullName
  ,Person2.FullName
 
FROM
   Nodes.Person AS Person1
  ,Edges.friends AS Friends
  ,Nodes.Person AS Person2
WHERE
  MATCH(Person1-(friends)->Person2)
  order by Person1.FullName

  --группировка подсчет друзей по языку
  SELECT
  P1.FullName
  ,P1.[Language]
  ,Friends_Number = COUNT(*)
FROM
  Nodes.Person AS P1
  ,Edges.Friends AS Friends
  ,Nodes.Person AS P2
WHERE
  MATCH(P1-(Friends)->P2)
 AND (P1.[Language] = 'Finnish')
GROUP BY
  P1.FullName, P1.[Language]
ORDER BY
  Friends_Number DESC, P1.[Language];
GO
-- Друзья друзей
SELECT
   P1.FullName as Person
  ,P2.FullName  as friend1
  ,P3.FullName  as friend2
FROM
  Nodes.Person AS P1
  ,Edges.Friends AS F1
  ,Nodes.Person AS P2
  ,Edges.Friends AS F2
  ,Nodes.Person AS P3
WHERE
  MATCH(P1-(F1)-> P2-(F2)-> P3)
  AND P1.FullName = 'Anthony Grosse'

GO
-- найти тех кто дружит с одним человеком
SELECT
  P1.FullName
  ,P2.FullName as CommonFriend
  --,P2.[Language]
  ,P3.FullName
FROM
  Nodes.Person AS P1
  ,Edges.Friends AS F1
  ,Nodes.Person AS P2
  ,Edges.Friends AS F2
  ,Nodes.Person AS P3
WHERE
  MATCH(P1-(F1)-> P2 <-(F2)-P3)
   AND (P1.$node_id <> P3.$node_id);

-- общие друзья говоряшие на одном языке
SELECT
  P1.FullName
  ,P2.FullName as CommonFriend
  --,P2.[Language]
  ,P3.FullName
FROM
  Nodes.Person AS P1
  ,Edges.Friends AS F1
  ,Nodes.Person AS P2
  ,Edges.Friends AS F2
  ,Nodes.Person AS P3
WHERE
 -- MATCH(P1-(F1)-> P2 <-(F2)-P3)  
  MATCH(P1-(F1)-> P2 and P3 -(F2)->P2)
   AND (P1.$node_id <> P3.$node_id) 
    AND (P1.[Language] = 'Greek') AND (P3.[Language] = 'Greek')


-- List of the top 5 people who have friends that speak Greek
-- in the first and second connections
SELECT
  TOP 5
  P1.FullName
  ,P1.[Language]
  ,GreekFriends = COUNT(*)
FROM
  Nodes.Person AS P1
  ,Edges.Friends AS F1
  ,Nodes.Person AS P2
  ,Edges.Friends AS F2
  ,Nodes.Person AS P3
WHERE
  MATCH(P1-(F1)-> P2-(F2)-> P3)
  AND ((P2.[Language] = 'Greek') OR (P3.[Language] = 'Greek'))
GROUP BY
  P1.FullName, P1.[Language]
ORDER BY
  GreekFriends DESC, P1.[Language];
GO
--Рекомендательная система
select * from [WideWorldImporters].[Sales].[Customers]
-- покупатели
Create table Nodes.[Customers](
[CustomerID] int not null primary key,
[CustomerName] nvarchar(100),
[WebsiteURL] nvarchar(256)) as node

insert into Nodes.[Customers]
select [CustomerID],[CustomerName],[WebsiteURL] from [WideWorldImporters].[Sales].[Customers]

select * from Nodes.[Customers]
--товары
select * from [WideWorldImporters].[Warehouse].[StockItems]

create table nodes.[StockItems](
StockItemID INTEGER IDENTITY(1, 1) NOT NULL
  ,StockItemName NVARCHAR(100) NOT NULL
  ,Barcode NVARCHAR(50) NULL
  ,Photo VARBINARY(MAX)  
  ,LastEditedBy INTEGER NOT NULL
)
as NODE

insert into  nodes.[StockItems](StockItemName   ,Barcode   ,Photo   ,LastEditedBy )
select StockItemName   ,Barcode   ,Photo   ,LastEditedBy 
  from [WideWorldImporters].[Warehouse].[StockItems]

select * from nodes.[StockItems]
--Создаем связи
create table Edges.bought(
PurchasedCount bigint) as edge

insert into Edges.bought
($from_id, $to_id, [PurchasedCount])
select
c.$node_id as CustomerNodeId,
si.$node_id as ProductNodeID, 
count(ordl.OrderLineID) as [PurchasedCount]
from [WideWorldImporters].[Sales].[OrderLines] as ordl 
join [WideWorldImporters].[Sales].[Orders] as ord on ord.orderID=ordl.OrderId
join Nodes.[Customers] as c on c.customerId= ord.customerId
join nodes.[StockItems] as si on si.StockItemID = ordl.StockItemID
group by c.$node_id, si.$node_id


select * from Edges.bought

--поиск рекомендаций
select top  5
RecommendedItem.StockItemName,
count(*) as ProductCount
from
[Nodes].[StockItems] as Item,
[Nodes].[Customers] as Customers,
[Edges].[bought] as bougthOther,
[Edges].[bought] as bougthThis,
[Nodes].[StockItems] as RecommendedItem
where 
match(RecommendedItem <-( bougthOther)-Customers-(bougthThis)->Item)
and Item.StockItemName='USB food flash drive - pizza slice'
and Item.StockItemName<>RecommendedItem.StockItemName
group by RecommendedItem.StockItemName
order by count(*) desc

--новое


SELECT
  table_name = OBJECT_NAME([object_id])
  ,[name]
  ,graph_type
  ,graph_type_desc
  ,is_hidden
  ,collation_name
FROM
  sys.columns
WHERE
  (graph_type IS NOT NULL);
GO

SELECT
  graph_id_from_node_id = GRAPH_ID_FROM_NODE_ID($node_id)
  ,object_id_from_node_id = OBJECT_ID_FROM_NODE_ID($node_id)
  ,table_name = OBJECT_NAME(OBJECT_ID_FROM_NODE_ID($node_id))
  ,node_id = NODE_ID_FROM_PARTS(OBJECT_ID_FROM_NODE_ID($node_id),
                                GRAPH_ID_FROM_NODE_ID($node_id))
  ,$node_id
FROM
  Nodes.Person;
GO

SELECT
  graph_id_from_edge_id = GRAPH_ID_FROM_EDGE_ID($edge_id)
  ,object_id_from_edge_id = OBJECT_ID_FROM_EDGE_ID($edge_id)
  ,table_name = OBJECT_NAME(OBJECT_ID_FROM_EDGE_ID($edge_id))
  ,edge_id = EDGE_ID_FROM_PARTS(OBJECT_ID_FROM_EDGE_ID($edge_id),
                                GRAPH_ID_FROM_EDGE_ID($edge_id))
  ,$edge_id
FROM
  Edges.Friends;
GO