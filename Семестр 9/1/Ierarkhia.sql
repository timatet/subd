
select * from ��������
select ���, ������������, ������������.ToString(),������������.GetLevel()
from ��������
--����������
Insert into ��������
Values('���� ������','/1/2/')
--���������� � ������ � �������
select ���, ������������, ������������.ToString() as [�����] ,������������.GetLevel() as [�������]
from ��������
order by [�����]
--���������� � ������ � ������
select ���, ������������, ������������.ToString() as [�����] ,������������.GetLevel() as [�������]
from ��������
order by [�������],[�����]
--
declare @phId hierarchyid,@id hierarchyid
select @phId = (SELECT ������������ FROM �������� WHERE ��� = '������� ������');

select @Id = MAX(������������)
from ��������
where ������������.GetAncestor(1) = @phId
--GetAncestor � ������ hierarchyid ������, ����� ������� ������� ������, �������� 1 ������� ����������������� ������;
insert into ��������
values('������� ����', @phId.GetDescendant(@id, null))
--GetDescendant � ������ hierarchyid �������, ��������� ��� ���������, � ������� ������� ����� ��������� ���, ������ ������ ������� ���������� �������� �� ������

declare @phId hierarchyid,@id hierarchyid
select @phId = (SELECT ������������ FROM �������� WHERE ��� = '������� ����');
select @Id = MAX(������������)
from ��������
where ������������.GetAncestor(1) = @phId
insert into ��������
values('�������� ��������', @phId.GetDescendant(@id, null))


--GetLevel � ������ ������� hierarchyid;
--GetRoot � ������ ������� �����;
--IsDescendantOf � ��������� �������� �� hierarchyid ���������� ����� �������� �������;
--Parse � ������������ ��������� ������������� hierarchyid � ���������� hierarchyid;
--Reparent � ��������� �������� �������� ������;
--ToString � ������������ hierarchyid � ��������� �������������.

--������� ������
select p2.���, p1.��� 
from �������� p1 join �������� p2
on p2.������������.IsDescendantOf(p1.������������)=1