RAISERROR('You should not be running this script as a whole. Select the parts you want to run instead.',11,1)
	RETURN;

IF DB_ID('DYNAMIC') IS NULL
    CREATE DATABASE DYNAMIC;

USE DYNAMIC;


-- Table with static attributes

CREATE TABLE Orders (
	order_id int identity(1,1) PRIMARY KEY CLUSTERED,
	order_date datetime2 NOT NULL,
	customer_id int NOT NULL,
	delivery_date datetime2 NOT NULL,
	total_amount decimal(18,3)
);


-- Insert some data

INSERT INTO Orders (order_date, customer_id, delivery_date, total_amount)
SELECT TOP 1000000 
	DATEADD(day, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), '20000101'),
	1,
	DATEADD(day, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), '20000201'),
	RAND()
FROM sys.all_columns AS C
CROSS JOIN sys.all_columns AS C1
CROSS JOIN sys.all_columns AS C2
CROSS JOIN sys.all_columns AS C3
CROSS JOIN sys.all_columns AS C4;

--- 1 million --> 4 seconds




-- ################################################################ --
--                  ENTITY - ATTRIBUTE - VALUE
-- ################################################################ --


CREATE TABLE Attributes (
	attribute_id int PRIMARY KEY,
	name sysname
)

INSERT INTO Attributes VALUES (1,'ShipDate')
INSERT INTO Attributes VALUES (2,'PurchaseOrderNumber')
INSERT INTO Attributes VALUES (3,'CreditCardApprovalCode')
INSERT INTO Attributes VALUES (4,'ShipMethodId')
INSERT INTO Attributes VALUES (5,'CurrencyRateId')
INSERT INTO Attributes VALUES (6,'ShipAddressId')
INSERT INTO Attributes VALUES (7,'SalesPerson')
INSERT INTO Attributes VALUES (8,'OnlineFlag')
INSERT INTO Attributes VALUES (9,'DiscountCode')
INSERT INTO Attributes VALUES (10,'ModifiedDate')


CREATE TABLE AttributeValues (
	entity_id int,
	attribute_id int,
	value nvarchar(4000)
)


INSERT INTO AttributeValues
SELECT 
	o.order_id, 
	A.attribute_id, 
	CASE A.attribute_id 
		WHEN 1 THEN CONVERT(nvarchar(4000), o.delivery_date, 126)
		WHEN 2 THEN CAST(CAST(RAND() * o.order_id * 100 AS int) AS nvarchar(4000))
		WHEN 3 THEN 'DSJFSL'
		WHEN 4 THEN CAST(o.order_id % 413 AS nvarchar(4000))
		WHEN 5 THEN '2'
		WHEN 6 THEN '4'
		WHEN 7 THEN 'ADHH'
		WHEN 8 THEN 'N'
		WHEN 9 THEN 'COBRACHICKEN'
		WHEN 10 THEN CONVERT(nvarchar(4000), o.order_date, 126)
	END
FROM Orders AS O
CROSS JOIN Attributes AS A;

-- 10 million rows --> 1 minute


SELECT o.order_id, o.order_date, o.customer_id, o.delivery_date, o.total_amount
	,MIN(CASE av.attribute_id WHEN 1 THEN  value END) AS ShipDate
	,MIN(CASE av.attribute_id WHEN 2 THEN  value END) AS PurchaseOrderNumber
	,MIN(CASE av.attribute_id WHEN 3 THEN  value END) AS CreditCardApprovalCode
	,MIN(CASE av.attribute_id WHEN 4 THEN  value END) AS ShipMethodId
	,MIN(CASE av.attribute_id WHEN 5 THEN  value END) AS CurrencyRateId
	,MIN(CASE av.attribute_id WHEN 6 THEN  value END) AS ShipAddressId
	,MIN(CASE av.attribute_id WHEN 7 THEN  value END) AS SalesPerson
	,MIN(CASE av.attribute_id WHEN 8 THEN  value END) AS OnlineFlag
	,MIN(CASE av.attribute_id WHEN 9 THEN  value END) AS DiscountCode
	,MIN(CASE av.attribute_id WHEN 10 THEN value END) AS ModifiedDate
FROM Orders AS o
INNER JOIN AttributeValues AS av
	ON o.order_id = av.entity_id
GROUP BY o.order_id, o.order_date, o.customer_id, o.delivery_date, o.total_amount

-- 14 seconds




-- ################################################################ --
--                  SPARSE COLUMNS
-- ################################################################ --



CREATE TABLE OrderAttributes (
	order_id int PRIMARY KEY,
	DateAttribute1 datetime2 SPARSE,
	DateAttribute2 datetime2 SPARSE,
	DateAttribute3 datetime2 SPARSE,
	DateAttribute4 datetime2 SPARSE,
	DateAttribute5 datetime2 SPARSE,
	DateAttribute6 datetime2 SPARSE,
	DateAttribute7 datetime2 SPARSE,
	DateAttribute8 datetime2 SPARSE,
	DateAttribute9 datetime2 SPARSE,
	StringAttribute1 nvarchar(4000) SPARSE,
	StringAttribute2 nvarchar(4000) SPARSE,
	StringAttribute3 nvarchar(4000) SPARSE,
	StringAttribute4 nvarchar(4000) SPARSE,
	StringAttribute5 nvarchar(4000) SPARSE,
	StringAttribute6 nvarchar(4000) SPARSE,
	StringAttribute7 nvarchar(4000) SPARSE,
	StringAttribute8 nvarchar(4000) SPARSE,
	StringAttribute9 nvarchar(4000) SPARSE,
	IntegerAttribute1 int SPARSE,
	IntegerAttribute2 int SPARSE,
	IntegerAttribute3 int SPARSE,
	IntegerAttribute4 int SPARSE,
	IntegerAttribute5 int SPARSE,
	IntegerAttribute6 int SPARSE,
	IntegerAttribute7 int SPARSE,
	IntegerAttribute8 int SPARSE,
	IntegerAttribute9 int SPARSE,
	DecimalAttribute1 decimal(18,3) SPARSE,
	DecimalAttribute2 decimal(18,3) SPARSE,
	DecimalAttribute3 decimal(18,3) SPARSE,
	DecimalAttribute4 decimal(18,3) SPARSE,
	DecimalAttribute5 decimal(18,3) SPARSE,
	DecimalAttribute6 decimal(18,3) SPARSE,
	DecimalAttribute7 decimal(18,3) SPARSE,
	DecimalAttribute8 decimal(18,3) SPARSE,
	DecimalAttribute9 decimal(18,3) SPARSE
)

INSERT INTO OrderAttributes (order_id, DateAttribute1, IntegerAttribute1, StringAttribute1, IntegerAttribute2, IntegerAttribute3, IntegerAttribute4, StringAttribute2, StringAttribute3, StringAttribute4, DateAttribute2)
SELECT 
	 o.order_id
	,o.delivery_date
	,CAST(RAND() * o.order_id * 100 AS int) 
	,'DSJFSL'
	,o.order_id % 413
	,2
	,4
	,'ADHH'
	,'N'
	,'COBRACHICKEN'
	, o.order_date
FROM Orders AS O;

-- 1 million --> 3 seconds 

SELECT *
FROM Orders AS o
INNER JOIN OrderAttributes AS oa
	ON o.order_id = oa.order_id;

-- 8 seconds