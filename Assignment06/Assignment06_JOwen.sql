--*************************************************************************--
-- Title: Assignment06
-- Author: JOwen
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2022-05-24,JOwen,Completed Assignment
--**************************************************************************--
BEGIN TRY
    USE Master;
    IF EXISTS(SELECT Name FROM SysDatabases WHERE Name = 'Assignment06DB_JOwen')
        BEGIN
            ALTER DATABASE [Assignment06DB_JOwen] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
            DROP DATABASE Assignment06DB_JOwen;
        END
    CREATE DATABASE Assignment06DB_JOwen;
END TRY
BEGIN CATCH
    PRINT ERROR_NUMBER();
END CATCH
GO
USE Assignment06DB_JOwen;

-- Create Tables (Module 01)-- 
CREATE TABLE Categories
(
    [CategoryID]   [int] IDENTITY (1,1) NOT NULL,
    [CategoryName] [nvarchar](100)      NOT NULL
);
GO

CREATE TABLE Products
(
    [ProductID]   [int] IDENTITY (1,1) NOT NULL,
    [ProductName] [nvarchar](100)      NOT NULL,
    [CategoryID]  [int]                NULL,
    [UnitPrice]   [mOney]              NOT NULL
);
GO

CREATE TABLE Employees -- New Table
(
    [EmployeeID]        [int] IDENTITY (1,1) NOT NULL,
    [EmployeeFirstName] [nvarchar](100)      NOT NULL,
    [EmployeeLastName]  [nvarchar](100)      NOT NULL,
    [ManagerID]         [int]                NULL
);
GO

CREATE TABLE Inventories
(
    [InventoryID]   [int] IDENTITY (1,1) NOT NULL,
    [InventoryDate] [Date]               NOT NULL,
    [EmployeeID]    [int]                NOT NULL -- New Column
    ,
    [ProductID]     [int]                NOT NULL,
    [Count]         [int]                NOT NULL
);
GO

-- Add Constraints (Module 02) -- 
BEGIN
    -- Categories
    ALTER TABLE Categories
        ADD CONSTRAINT pkCategories
            PRIMARY KEY (CategoryId);

    ALTER TABLE Categories
        ADD CONSTRAINT ukCategories
            UNIQUE (CategoryName);
END
GO

BEGIN
    -- Products
    ALTER TABLE Products
        ADD CONSTRAINT pkProducts
            PRIMARY KEY (ProductId);

    ALTER TABLE Products
        ADD CONSTRAINT ukProducts
            UNIQUE (ProductName);

    ALTER TABLE Products
        ADD CONSTRAINT fkProductsToCategories
            FOREIGN KEY (CategoryId) REFERENCES Categories (CategoryId);

    ALTER TABLE Products
        ADD CONSTRAINT ckProductUnitPriceZeroOrHigher
            CHECK (UnitPrice >= 0);
END
GO

BEGIN
    -- Employees
    ALTER TABLE Employees
        ADD CONSTRAINT pkEmployees
            PRIMARY KEY (EmployeeId);

    ALTER TABLE Employees
        ADD CONSTRAINT fkEmployeesToEmployeesManager
            FOREIGN KEY (ManagerId) REFERENCES Employees (EmployeeId);
END
GO

BEGIN
    -- Inventories
    ALTER TABLE Inventories
        ADD CONSTRAINT pkInventories
            PRIMARY KEY (InventoryId);

    ALTER TABLE Inventories
        ADD CONSTRAINT dfInventoryDate
            DEFAULT GETDATE() FOR InventoryDate;

    ALTER TABLE Inventories
        ADD CONSTRAINT fkInventoriesToProducts
            FOREIGN KEY (ProductId) REFERENCES Products (ProductId);

    ALTER TABLE Inventories
        ADD CONSTRAINT ckInventoryCountZeroOrHigher
            CHECK ([Count] >= 0);

    ALTER TABLE Inventories
        ADD CONSTRAINT fkInventoriesToEmployees
            FOREIGN KEY (EmployeeId) REFERENCES Employees (EmployeeId);
END
GO

-- Adding Data (Module 04) -- 
INSERT INTO Categories
    (CategoryName)
SELECT CategoryName
FROM Northwind.dbo.Categories
ORDER BY CategoryID;
GO

INSERT INTO Products
    (ProductName, CategoryID, UnitPrice)
SELECT ProductName, CategoryID, UnitPrice
FROM Northwind.dbo.Products
ORDER BY ProductID;
GO

INSERT INTO Employees
    (EmployeeFirstName, EmployeeLastName, ManagerID)
SELECT E.FirstName, E.LastName, ISNULL(E.ReportsTo, E.EmployeeID)
FROM Northwind.dbo.Employees AS E
ORDER BY E.EmployeeID;
GO

INSERT INTO Inventories
    (InventoryDate, EmployeeID, ProductID, [Count])
SELECT '20170101' AS InventoryDate, 5 AS EmployeeID, ProductID, UnitsInStock
FROM Northwind.dbo.Products
UNION
SELECT '20170201' AS InventoryDate,
       7          AS EmployeeID,
       ProductID,
       UnitsInStock + 10 -- Using this is to create a made up value
FROM Northwind.dbo.Products
UNION
SELECT '20170301' AS InventoryDate,
       9          AS EmployeeID,
       ProductID,
       UnitsInStock + 20 -- Using this is to create a made up value
FROM Northwind.dbo.Products
ORDER BY 1, 2
GO

-- Show the Current data in the Categories, Products, and Inventories Tables
SELECT *
FROM Categories;
GO
SELECT *
FROM Products;
GO
SELECT *
FROM Employees;
GO
SELECT *
FROM Inventories;
GO

/********************************* Questions and Answers *********************************/
PRINT
    'NOTES------------------------------------------------------------------------------------
     1) You can use any name you like for you views, but be descriptive and consistent
     2) You can use your working code from assignment 5 for much of this assignment
     3) You must use the BASIC views for each table after they are created in Question 1
    ------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- First rename existing tables to add 'tbl' prefix
EXECUTE sp_rename 'dbo.Categories', 'tblCategories';
GO
EXECUTE sp_rename 'dbo.Employees', 'tblEmployees';
GO
EXECUTE sp_rename 'dbo.Inventories', 'tblInventories';
GO
EXECUTE sp_rename 'dbo.Products', 'tblProducts';
GO

-- Define Base Views
CREATE VIEW Categories WITH SCHEMABINDING AS
SELECT CategoryID, CategoryName
FROM dbo.tblCategories;
GO

CREATE OR ALTER VIEW Employees WITH SCHEMABINDING AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM dbo.tblEmployees;
GO

CREATE OR ALTER VIEW Inventories WITH SCHEMABINDING AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
FROM dbo.tblInventories;
GO

CREATE OR ALTER VIEW Products WITH SCHEMABINDING AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM dbo.tblProducts;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Set Deny permission
DENY SELECT ON tblCategories TO Public;
DENY SELECT ON tblEmployees TO Public;
DENY SELECT ON tblInventories TO Public;
DENY SELECT ON tblProducts TO Public;
GO

-- Set Grant permission
GRANT SELECT ON Categories TO Public;
GRANT SELECT ON Employees TO Public;
GRANT SELECT ON Inventories TO Public;
GRANT SELECT ON Products TO Public;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- NOTE: The largest table has 231 results, Using a TOP value of 1000 will return all results with head room for all questions

CREATE OR ALTER VIEW vwProductsByCategories AS
SELECT TOP 1000 CategoryName, ProductName, UnitPrice
FROM Categories C
         FULL JOIN Products P ON C.CategoryID = P.CategoryID
ORDER BY CategoryName, ProductName;
GO

-- SELECT *
-- FROM vwProductsByCategories;
-- GO

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE OR ALTER VIEW vwInventoriesByProductsByDates AS
SELECT TOP 1000 ProductName, InventoryDate, Count
FROM Products P
         JOIN Inventories I ON P.ProductID = I.ProductID
ORDER BY ProductName, InventoryDate, Count;
GO

-- SELECT *
-- FROM vwInventoriesByProductsByDates;
-- GO

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

CREATE OR ALTER VIEW vwInventoryDatesByEmployee AS
SELECT DISTINCT TOP 1000 InventoryDate, CONCAT(EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
FROM Inventories I
         JOIN Employees E ON I.EmployeeID = E.EmployeeID
ORDER BY InventoryDate;
GO

-- SELECT *
-- FROM vwInventoryDatesByEmployee;
-- GO
-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE OR ALTER VIEW vwInventoriesByCategoryByProductsByByDate AS
SELECT TOP 1000 CategoryName, ProductName, InventoryDate, Count
FROM Products P
         JOIN Categories C ON P.CategoryID = C.CategoryID
         JOIN Inventories I ON P.ProductID = I.ProductID
ORDER BY CategoryName, ProductName, InventoryDate, Count;
GO

-- SELECT *
-- FROM vwInventoriesByCategoryByProductsByByDate;
-- GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
CREATE OR ALTER VIEW vwInventoriesByCategoryByProductsByEmployees AS
SELECT TOP 1000 CategoryName,
                ProductName,
                InventoryDate,
                Count,
                EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
FROM Inventories I
         JOIN Employees E ON E.EmployeeID = I.EmployeeID
         JOIN Products P ON P.ProductID = I.ProductID
         JOIN Categories C ON C.CategoryID = P.CategoryID
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
GO

-- SELECT *
-- FROM vwInventoriesByCategoryByProductsByEmployees;
-- GO

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Cote de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guarana Fantastica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikoori	      2017-01-01	  57	  Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'?

-- A better solution would be to roll this function and view into a stored procedure
CREATE OR ALTER FUNCTION dbo.fnGetProductIdsFromNames(@productNames NVARCHAR(MAX))
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT ProductID
                FROM Products P
                WHERE P.ProductName IN (SELECT value FROM STRING_SPLIT(@productNames, ','))
            );
GO

CREATE OR ALTER VIEW vwInventoriesForChaiAndChangByCategoryByProductsByEmployees AS
SELECT TOP 1000 CategoryName,
                ProductName,
                InventoryDate,
                Count,
                EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
FROM Inventories I
         JOIN Employees E ON E.EmployeeID = I.EmployeeID
         JOIN Products P ON P.ProductID = I.ProductID
         JOIN Categories C ON C.CategoryID = P.CategoryID
WHERE I.ProductID IN (SELECT ProductID FROM dbo.fnGetProductIdsFromNames('Chai,Chang'))
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
GO

-- SELECT *
-- FROM vwInventoriesForChaiAndChangByCategoryByProductsByEmployees;
-- GO

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE OR ALTER VIEW vwEmployeesByManager AS
SELECT TOP 1000 CONCAT(M.EmployeeFirstName, ' ', M.EmployeeLastName) AS Manager,
                CONCAT(E.EmployeeFirstName, ' ', E.EmployeeLastName) AS Employee
FROM Employees E
         JOIN Employees M ON M.EmployeeID = E.ManagerID
ORDER BY Manager, Employee;
GO

-- SELECT *
-- FROM vwEmployeesByManager;
-- GO

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE OR ALTER VIEW vwInventoriesByCategoriesByProductsByEmployees AS
SELECT TOP 1000 C.CategoryID,
                CategoryName,
                I.ProductID,
                ProductName,
                UnitPrice,
                InventoryID,
                InventoryDate,
                Count,
                E.EmployeeID,
                CONCAT(E.EmployeeFirstName, ' ', E.EmployeeLastName) AS Employee,
                M.EmployeeID                                         AS ManagerID,
                CONCAT(M.EmployeeFirstName, ' ', M.EmployeeLastName) AS Manager
FROM Products
         JOIN Categories C ON Products.CategoryID = C.CategoryID
         JOIN Inventories I ON Products.ProductID = I.ProductID
         JOIN Employees E ON I.EmployeeID = E.EmployeeID
         JOIN Employees M ON E.ManagerID = M.EmployeeID
ORDER BY CategoryName, ProductName, InventoryID, Employee;
GO

-- SELECT *
-- FROM vwInventoriesByCategoriesByProductsByEmployees;
-- GO

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
PRINT 'Note: You will get an error until the views are created!'
SELECT *
FROM [dbo].[Categories]
SELECT *
FROM [dbo].[Products]
SELECT *
FROM [dbo].[Inventories]
SELECT *
FROM [dbo].[Employees]

SELECT *
FROM [dbo].[vwProductsByCategories]
SELECT *
FROM [dbo].[vwInventoriesByProductsByDates]
SELECT *
FROM [dbo].[vwInventoryDatesByEmployee]
SELECT *
FROM [dbo].[vwInventoriesByCategoryByProductsByByDate]
SELECT *
FROM [dbo].[vwInventoriesByCategoryByProductsByEmployees]
SELECT *
FROM [dbo].[vwInventoriesForChaiAndChangByCategoryByProductsByEmployees]
SELECT *
FROM [dbo].[vwEmployeesByManager]
SELECT *
FROM [dbo].[vwInventoriesByCategoriesByProductsByEmployees]

/***************************************************************************************/