-- =============================================
-- Author:      Gianluca Sartori - @spaghettidba
-- Create date: 2016-09-07
-- Description: Demonstrates the sins of EAV design
-- =============================================

--:r 00_SETUP.sql

USE tempdb;
GO

IF OBJECT_ID('Values')           IS NOT NULL DROP TABLE [Values];
IF OBJECT_ID('Attributes')       IS NOT NULL DROP TABLE Attributes;
IF OBJECT_ID('Entities')         IS NOT NULL DROP TABLE Entities;


CREATE TABLE Attributes (
	 attribute_id   INT           NOT NULL PRIMARY KEY CLUSTERED
	,attribute_name NVARCHAR(128) NOT NULL
)
GO


CREATE TABLE Entities (
	 entity_id      INT           NOT NULL PRIMARY KEY CLUSTERED
	,entity_name    NVARCHAR(128) NOT NULL
)
GO


CREATE TABLE [Values] (
	 attribute_id  INT            NOT NULL FOREIGN KEY (attribute_id) REFERENCES Attributes(attribute_id)
	,entity_id     INT            NOT NULL FOREIGN KEY (entity_id)    REFERENCES Entities(entity_id)
	,id            INT            NOT NULL -- Id from the referencing table
	,value         NVARCHAR(4000) NOT NULL
	,PRIMARY KEY CLUSTERED (
		 attribute_id
		,entity_id
		,id
	)
)
GO



INSERT INTO Entities   VALUES 
	(1, 'Customers'), 
    (2, 'Orders');
								  
INSERT INTO Attributes VALUES 
	(1, 'Delivery Date'),
    (2, 'Canceled Date'),
	(3, 'Email Address'),
	(4, 'Telephone Number'),
	(5, 'Window width');


INSERT INTO [Values]   (
    attribute_id, 
	entity_id, 
	id, 
	value
)   
VALUES 
	(1, 2, 1, '20160401'),            -- Delivery Date Order 1
	(1, 2, 2, '20160409'),            -- Delivery Date Order 2
	(1, 2, 3, '20160612'),            -- Delivery Date Order 3
	(1, 2, 5, '20160230'),            -- Delivery Date Order 5 -- Invalid!
	(1, 2, 6, '20160725'),            -- Delivery Date Order 6
	(1, 2, 7, '20161920'),            -- Delivery Date Order 7

	(2, 2, 3, '20160522'),            -- Cancellation Date Order 3

	(3, 1, 1, 'info@scarpamondo.it'), -- Email address customer 1
    (3, 1, 2, 'info@scarpasport.it'), -- Email address customer 2
	(3, 1, 3, 'info@ilduca.it'),      -- Email address customer 3

	(4, 1, 1, '3282333002'),          -- Telephone number of customer 1
	(4, 1, 2, '3351245963'),          -- Telephone number of customer 2
	(4, 1, 3, '3482386666'),          -- Telephone number of customer 3

	(5, 1, 1, '5,1m'),                -- Window size customer 1 (depends on regional options!)
	(5, 1, 2, '5.1'),                 -- Window size customer 2 (depends on regional options!)
	(5, 1, 3, 'no window'),           -- Window size customer 3
	(5, 1, 4, '410');                 -- Window size customer 2


SELECT *
FROM [Values];


SELECT E.entity_name, A.attribute_name, V.id, V.value
FROM [Values] AS V
INNER JOIN Attributes AS A
	ON V.attribute_id = A.attribute_id
INNER JOIN Entities AS E
	ON V.entity_id = E.entity_id;

-- Customers:

SELECT C.* 
	,Email.Value     AS Email
	,Telephone.Value AS Telephone
	,Window.Value    AS Window
FROM Customers AS C
LEFT JOIN [Values] AS Email
	ON Email.attribute_id     = 3
	AND Email.entity_id       = 1
	AND Email.id              = C.customer_id
LEFT JOIN [Values] AS Telephone
	ON Telephone.attribute_id = 4
	AND Telephone.entity_id   = 1
	AND Telephone.id          = C.customer_id
LEFT JOIN [Values] AS Window
	ON Window.attribute_id    = 5
	AND Window.entity_id      = 1
	AND Window.id             = C.customer_id;



-- Orders:

SELECT O.*
	,Delivery.Value AS DeliveryDate
	,Cancel.Value AS CancelDate
FROM Orders AS O
LEFT JOIN [Values] AS Delivery
	ON Delivery.attribute_id = 1
	AND Delivery.entity_id   = 2
	AND Delivery.id          = O.order_id
LEFT JOIN [Values] AS Cancel
	ON Cancel.attribute_id   = 2
	AND Cancel.entity_id     = 2
	AND Cancel.id            = O.order_id

-- All orders shipped within a week:
WHERE DATEDIFF(day, Delivery.value, O.order_date) <= 7 
	
	
-- PIVOT						  
;	  
WITH CustomerAttributes AS (
	SELECT *
	FROM (
		SELECT id, attribute_id, value
		FROM [Values] 
		WHERE entity_id = 1
	) AS src
	PIVOT( MAX(value) FOR attribute_id IN ([3],[4],[5])) AS pvt
)
SELECT C.*
	,CA.[3] AS Email
	,CA.[4] AS Telephone
	,CA.[5] AS Window
FROM Customers AS C
LEFT JOIN CustomerAttributes AS CA
	ON C.customer_id = CA.id;



-- crosstab
WITH customerattributes as (
	SELECT id
		,email     = max(case attribute_id when 3 then value end)
		,telephone = max(case attribute_id when 4 then value end)
		,window    = max(case attribute_id when 5 then value end)
	FROM [values] 
	WHERE entity_id = 1
	GROUP BY id
)
SELECT *
FROM customers as c
LEFT JOIN customerattributes as ca
	on c.customer_id = ca.id;
