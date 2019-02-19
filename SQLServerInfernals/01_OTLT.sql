-- =============================================
-- Author:      Gianluca Sartori - @spaghettidba
-- Create date: 2016-09-07
-- Description: Creates the One True Lookup Table
-- =============================================
USE tempdb;
GO

IF OBJECT_ID('Orders')           IS NOT NULL DROP TABLE Orders;
IF OBJECT_ID('Customers')        IS NOT NULL DROP TABLE Customers;
IF OBJECT_ID('Countries')        IS NOT NULL DROP TABLE Countries;
IF OBJECT_ID('States')           IS NOT NULL DROP TABLE States;
IF OBJECT_ID('Order_Status')     IS NOT NULL DROP TABLE Order_Status;
IF OBJECT_ID('Order_Priorities') IS NOT NULL DROP TABLE Order_Priorities;
IF OBJECT_ID('LookupTable')      IS NOT NULL DROP TABLE LookupTable;
GO

CREATE TABLE LookupTable (
	table_name sysname,
	lookup_code nvarchar(500),
	lookup_description nvarchar(4000),
	PRIMARY KEY CLUSTERED(table_name, lookup_code),
	CHECK(
		CASE 
			WHEN table_name = 'states'     AND lookup_code LIKE '[A-Z][A-Z]'      THEN 1
			WHEN table_name = 'priorities' AND lookup_code LIKE '[0-8]'           THEN 1
			WHEN table_name = 'countries'  AND lookup_code LIKE '[A-Z][A-Z][A-Z]' THEN 1
			WHEN table_name = 'status'     AND lookup_code LIKE '[A-Z][A-Z]'      THEN 1
			ELSE 0
		END = 1
	)
)
GO

INSERT INTO LookupTable 
	(table_name, lookup_code, lookup_description)
VALUES 
	('countries','ITA','Italy'),
	('countries','DEN','Denmark'),
	('countries','SLO','Slovenia'),
	--
	('states','TV','Treviso'),
	('states','PN','Pordenone'),
	('states','NY','New York'),
	('states','WA','Washington'),
	('states','CO','Colorado'),
	--
	('priorities','1','Highest'),
	('priorities','2','High'),
	('priorities','3','Normal'),
	('priorities','4','Low'),
	--
	('status','CO','Confirmed'),
	('status','IN','Inserted'),
	('status','AN','Canceled'),
	('status','SO','Suspended');



CREATE TABLE Customers (
	 customer_id   INT            NOT NULL PRIMARY KEY CLUSTERED
	,name          NVARCHAR(100)  NOT NULL
	,address       NVARCHAR(50)   NOT NULL
	,ZIP           CHAR(5)        NOT NULL
	,city          NVARCHAR(50)   NOT NULL
	,state_id      CHAR(2)        NOT NULL --FOREIGN KEY ??
	,country_id    CHAR(3)        NOT NULL --FOREIGN KEY ??
)
GO


CREATE TABLE Orders (
	 order_id      INT            NOT NULL PRIMARY KEY CLUSTERED
	,order_date    DATETIME       NOT NULL 
	,customer_id   INT            NOT NULL FOREIGN KEY REFERENCES Customers(customer_id)
	,status_id     CHAR(2)        NOT NULL --FOREIGN KEY ??
	,priority_id   TINYINT        NOT NULL --FOREIGN KEY ??
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

SELECT * FROM LookupTable;

SELECT * FROM Customers;

SELECT * FROM Orders;
GO