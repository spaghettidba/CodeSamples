-- =============================================
-- Author:      Gianluca Sartori - @spaghettidba
-- Create date: 2016-09-07
-- Description: Setup
-- =============================================
USE tempdb;
GO

IF OBJECT_ID('Orders')           IS NOT NULL DROP TABLE Orders;
IF OBJECT_ID('Customers')        IS NOT NULL DROP TABLE Customers;
IF OBJECT_ID('Countries')        IS NOT NULL DROP TABLE Countries;
IF OBJECT_ID('States')           IS NOT NULL DROP TABLE States;
IF OBJECT_ID('Order_Status')     IS NOT NULL DROP TABLE Order_Status;
IF OBJECT_ID('Order_Priorities') IS NOT NULL DROP TABLE Order_Priorities;
GO

CREATE TABLE Countries (
	country_id char(3) PRIMARY KEY,
	description nvarchar(50) NOT NULL
)
GO

CREATE TABLE States (
	state_id char(2) PRIMARY KEY,
	description nvarchar(50) NOT NULL
)
GO

CREATE TABLE Order_Status (
	status_id char(2) PRIMARY KEY,
	description nvarchar(50) NOT NULL
)
GO

CREATE TABLE Order_Priorities (
	priority_id tinyint PRIMARY KEY,
	description nvarchar(50) NOT NULL
)
GO

INSERT INTO Countries VALUES 
	('ITA',N'Italy'), 
	('DEN',N'Denmark'), 
	('SLO',N'Slovenia'), 
    ('USA',N'United States Of America');

INSERT INTO States VALUES 
	('TV', N'Treviso'),
	('PN', N'Pordenone'),
	('NY', N'New York'),
	('WA', N'Washington'),
	('CO', N'Colorado');

INSERT INTO Order_Status VALUES 
	('CO', N'Confirmed'),
	('IN', N'Inserted'),
	('AN', N'Canceled'),
	('SO', N'Suspended');

INSERT INTO Order_Priorities VALUES 
	(1, N'Highest'),
	(2, N'High'),
	(3, N'Normal'),
	(4, N'Low');




CREATE TABLE Customers (
	 customer_id   INT            NOT NULL PRIMARY KEY CLUSTERED
	,name          NVARCHAR(100)  NOT NULL
	,address       NVARCHAR(50)   NOT NULL
	,ZIP           CHAR(5)        NOT NULL
	,city          NVARCHAR(50)   NOT NULL
	,state_id      CHAR(2)        NOT NULL FOREIGN KEY REFERENCES States(state_id)
	,country_id    CHAR(3)        NOT NULL FOREIGN KEY REFERENCES Countries(country_id)
)
GO


CREATE TABLE Orders (
	 order_id      INT            NOT NULL PRIMARY KEY CLUSTERED
	,order_date    DATETIME       NOT NULL 
	,customer_id   INT            NOT NULL FOREIGN KEY REFERENCES Customers(customer_id)
	,status_id     CHAR(2)        NOT NULL FOREIGN KEY REFERENCES Order_status(status_id)
	,priority_id   TINYINT        NOT NULL FOREIGN KEY REFERENCES Order_priorities(priority_id)
)
GO


INSERT INTO Customers VALUES 
	(1, 'Scarpamondo',  'via XXIV Maggio 121/F', '31015', 'Conegliano', 'TV', 'ITA'),
	(2, 'Shoe Master',  '275 Mott St',           '10012', 'New York',   'NY', 'USA'),
	(3, 'Il duca',      'via dei nobili 12/A',   '64533', 'Pordenone',  'PN', 'ITA');

INSERT INTO Orders VALUES 
	(1, '20160319', 1, 'CO', 1),
	(2, '20160401', 1, 'IN', 4),
	(3, '20160521', 1, 'AN', 2),
	(4, '20160611', 1, 'CO', 1),
	(5, '20160213', 2, 'SO', 1),
	(6, '20160710', 2, 'CO', 1),
	(7, '20160912', 2, 'IN', 1);
GO


SELECT * FROM Customers;

SELECT * FROM Orders;
GO
