
select * from продавцы
select Имя, Руководитель, Руководитель.ToString(),Руководитель.GetLevel()
from продавцы
--Добавление
Insert into продавцы
Values('Ваня Пупкин','/1/2/')
--Сортировка и проход в глубину
select Имя, Руководитель, Руководитель.ToString() as [Текст] ,Руководитель.GetLevel() as [Уровень]
from продавцы
order by [Текст]
--Сортировка и проход в ширину
select Имя, Руководитель, Руководитель.ToString() as [Текст] ,Руководитель.GetLevel() as [Уровень]
from продавцы
order by [Уровень],[текст]
--
declare @phId hierarchyid,@id hierarchyid
select @phId = (SELECT Руководитель FROM продавцы WHERE Имя = 'Евгений Онегин');

select @Id = MAX(Руководитель)
from продавцы
where Руководитель.GetAncestor(1) = @phId
--GetAncestor — выдает hierarchyid предка, можно указать уровень предка, например 1 выберет непосредственного предка;
insert into продавцы
values('Смирнов Иван', @phId.GetDescendant(@id, null))
--GetDescendant — выдает hierarchyid потомка, принимает два параметра, с помощью которых можно управлять тем, какого именно потомка необходимо получить на выходе

declare @phId hierarchyid,@id hierarchyid
select @phId = (SELECT Руководитель FROM продавцы WHERE Имя = 'Смирнов Иван');
select @Id = MAX(Руководитель)
from продавцы
where Руководитель.GetAncestor(1) = @phId
insert into продавцы
values('Смирнова Светлана', @phId.GetDescendant(@id, null))


--GetLevel — выдает уровень hierarchyid;
--GetRoot — выдает уровень корня;
--IsDescendantOf — проверяет является ли hierarchyid переданный через параметр предком;
--Parse — конвертирует строковое представление hierarchyid в собственно hierarchyid;
--Reparent — позволяет изменить текущего предка;
--ToString — конвертирует hierarchyid в строковое представление.

--потомок предок
select p2.Имя, p1.Имя 
from продавцы p1 join продавцы p2
on p2.Руководитель.IsDescendantOf(p1.Руководитель)=1