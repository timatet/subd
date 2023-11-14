﻿
/****** Object:  Table [dbo].[Заказы]    Script Date: 04.09. 2023  20:07:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Заказы](
	[Номер] [int] IDENTITY(1,1) NOT NULL,
	[Дата оформления] [date] NULL,
	[Продавец] [nvarchar](20) NULL,
	[Товар] [nvarchar](20) NULL,
	[Количество] [int] NULL,
	[Цена] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Мои продажи]    Script Date: 04.09. 2023  20:07:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Table [dbo].[Продавцы]    Script Date: 04.09. 2023  20:07:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Продавцы](
	[Имя] [nvarchar](20) NULL,
	[Руководитель] [hierarchyid] NULL
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Заказы] ON 
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (1, CAST(N' 2023 -09-14' AS Date), N'Владимир Ленский', N'Утюг', 7, 90.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (2, CAST(N' 2023 -08-11' AS Date), N'Татьяна Ларина', N'Утюг', 2, 90.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (3, CAST(N' 2023 -09-14' AS Date), N'Евгений Онегин', N'Телефон', 6, 120.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (4, CAST(N' 2023 -09-13' AS Date), N'Татьяна Ларина', N'Телефон', 3, 120.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (5, CAST(N' 2023 -09-13' AS Date), N'Ольга Ларина', N'Телефон', 7, 120.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (6, CAST(N' 2023 -08-29' AS Date), N'Ольга Ларина', N'Утюг', 6, 90.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (7, CAST(N' 2023 -08-14' AS Date), N'Ольга Ларина', N'Телефон', 4, 120.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (8, CAST(N' 2023 -05-14' AS Date), N'Евгений Онегин', N'Чайник', 3, 70.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (9, CAST(N' 2023 -09-13' AS Date), N'Татьяна Ларина', N'Утюг', 4, 90.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (10, CAST(N' 2023 -09-14' AS Date), N'Татьяна Ларина', N'Кофеварка', 4, 110.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (11, CAST(N' 2023 -09-14' AS Date), N'Владимир Ленский', N'Чайник', 5, 70.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (12, CAST(N' 2023 -09-11' AS Date), N'Татьяна Ларина', N'Чайник', 7, 70.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (13, CAST(N' 2023 -09-13' AS Date), N'Татьяна Ларина', N'Кофеварка', 4, 110.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (14, CAST(N' 2023 -09-14' AS Date), N'Евгений Онегин', N'Телефон', 6, 120.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (15, CAST(N' 2023 -09-13' AS Date), N'Татьяна Ларина', N'Телефон', 3, 120.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (16, CAST(N' 2023 -09-13' AS Date), N'Ольга Ларина', N'Телефон', 7, 120.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (17, CAST(N' 2023 -08-29' AS Date), N'Ольга Ларина', N'Утюг', 6, 90.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (18, CAST(N' 2023 -08-14' AS Date), N'Ольга Ларина', N'Телефон', 4, 120.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (19, CAST(N' 2023 -05-14' AS Date), N'Евгений Онегин', N'Чайник', 3, 70.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (20, CAST(N' 2023 -09-13' AS Date), N'Татьяна Ларина', N'Утюг', 4, 90.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (21, CAST(N' 2023 -09-14' AS Date), N'Татьяна Ларина', N'Кофеварка', 4, 110.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (22, CAST(N' 2023 -09-14' AS Date), N'Владимир Ленский', N'Чайник', 5, 70.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (23, CAST(N' 2023 -09-11' AS Date), N'Татьяна Ларина', N'Чайник', 7, 70.0000)
GO
INSERT [dbo].[Заказы] ([Номер], [Дата оформления], [Продавец], [Товар], [Количество], [Цена]) VALUES (24, CAST(N' 2023 -09-13' AS Date), N'Татьяна Ларина', N'Кофеварка', 4, 110.0000)
GO
SET IDENTITY_INSERT [dbo].[Заказы] OFF
GO
INSERT [dbo].[Продавцы] ([Имя], [Руководитель]) VALUES (N'Евгений Онегин', N'/')
GO
INSERT [dbo].[Продавцы] ([Имя], [Руководитель]) VALUES (N'Татьяна Ларина', N'/1/')
GO
INSERT [dbo].[Продавцы] ([Имя], [Руководитель]) VALUES (N'Владимир Ленский', N'/2/')
GO
INSERT [dbo].[Продавцы] ([Имя], [Руководитель]) VALUES (N'Ольга Ларина', N'/2/1/')
GO
INSERT [dbo].[Продавцы] ([Имя], [Руководитель]) VALUES (N'Мартын Захаров', N'/2/2/')
GO

