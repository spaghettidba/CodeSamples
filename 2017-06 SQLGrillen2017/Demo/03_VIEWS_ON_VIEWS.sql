-- =============================================
-- Author:      Gianluca Sartori - @spaghettidba
-- Create date: 2016-09-07
-- Description: Demonstrates the sins nested views
-- =============================================

USE AdventureWorks2012;
GO




IF OBJECT_ID('Sales.vOpenOrders') IS NOT NULL 
	DROP VIEW Sales.vOpenOrders;
GO


CREATE VIEW Sales.vOpenOrders
AS
SELECT 
	oh.SalesOrderId, 
	oh.Status, 
	cust.CustomerID, 
	cust.StoreId
FROM Sales.SalesOrderHeader AS oh
INNER JOIN Sales.Customer AS cust
	ON oh.CustomerID = cust.CustomerID
WHERE oh.Status IN (0,1)
GO


IF OBJECT_ID('Sales.vOpenOrdersUSA') IS NOT NULL 
	DROP VIEW Sales.vOpenOrdersUSA;
GO

CREATE VIEW Sales.vOpenOrdersUSA
AS
SELECT 
	openord.status,
	openord.customerId,
	openord.storeId,
	pers.FirstName,
	pers.LastName,
	SUM(oh.TotalDue) AS SumTotalDue
FROM Sales.vOpenOrders AS openord
INNER JOIN Sales.Customer AS cust
	ON openord.CustomerId = cust.CustomerID
INNER JOIN Person.Person AS pers
	ON pers.BusinessEntityID = cust.PersonID  -- we need personId from Customer
INNER JOIN Sales.SalesTerritory AS st
	ON cust.TerritoryID = st.TerritoryID
INNER JOIN Sales.SalesOrderHeader AS oh
	ON openord.SalesOrderID = oh.SalesOrderID
WHERE st.CountryRegionCode = 'US'
GROUP BY 
	openord.status,
	openord.customerId,
	openord.storeId,
	pers.FirstName,
	pers.LastName
GO



SELECT *
FROM SAles.vOpenOrdersUSA