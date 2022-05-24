--*************************************************************************--
-- Title: Assignment05
-- Author: JOwen
-- Desc: This file demonstrates how to use Joins and Subqueiers
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2022-05-16, JOwen, Completed File
--**************************************************************************--
USE Master;
GO

IF EXISTS(SELECT Name
          FROM SysDatabases
          WHERE Name = 'Assignment05DB_JOwen')
    BEGIN
        ALTER DATABASE [Assignment05DB_JOwen] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE Assignment05DB_JOwen;
    END
GO

CREATE DATABASE Assignment05DB_JOwen;
GO

USE Assignment05DB_JOwen;
GO

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
-- Question 1 (10 pts): How can you show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

SELECT CategoryName, ProductName, UnitPrice
FROM Categories C
         FULL JOIN Products P ON C.CategoryID = P.CategoryID
ORDER BY CategoryName, ProductName;
GO

-- Question 2 (10 pts): How can you show a list of Product name 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Date, Product,  and Count!

SELECT ProductName, InventoryDate, Count
FROM Products P
         JOIN Inventories I ON P.ProductID = I.ProductID
ORDER BY InventoryDate, ProductName, Count;
GO

-- Question 3 (10 pts): How can you show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

SELECT InventoryDate, CONCAT(EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
FROM Inventories I
         JOIN Employees E ON I.EmployeeID = E.EmployeeID
GROUP BY InventoryDate, CONCAT(EmployeeFirstName, ' ', EmployeeLastName)
ORDER BY InventoryDate;
GO

-- Question 4 (10 pts): How can you show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

SELECT CategoryName, ProductName, InventoryDate, Count
FROM Products P
         JOIN Categories C ON P.CategoryID = C.CategoryID
         JOIN Inventories I ON P.ProductID = I.ProductID
ORDER BY CategoryName, ProductName, InventoryDate, Count;
GO

-- Question 5 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

SELECT CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
FROM Inventories I
         LEFT JOIN Employees E ON E.EmployeeID = I.EmployeeID
         JOIN (SELECT ProductID, CategoryName, ProductName
               FROM Products P1
                        LEFT JOIN Categories C ON P1.CategoryID = C.CategoryID) P2 ON P2.ProductID = I.ProductID
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
GO

-- Question 6 (20 pts): How can you show a list of Categories, Products,
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- For Practice; Use a Subquery to get the ProductID based on the Product Names 
-- and order the results by the Inventory Date, Category, and Product!

SELECT CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
FROM Inventories I
         LEFT JOIN Employees E ON E.EmployeeID = I.EmployeeID
         JOIN (SELECT ProductID, CategoryName, ProductName
               FROM Products P1
                        LEFT JOIN Categories C ON P1.CategoryID = C.CategoryID) P2 ON P2.ProductID = I.ProductID
WHERE I.ProductID IN (SELECT ProductID FROM Products P3 WHERE P3.ProductName = 'Chai' OR P3.ProductName = 'Chang')
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
GO

-- Question 7 (20 pts): How can you show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

SELECT CONCAT(M.EmployeeFirstName, ' ', M.EmployeeLastName) AS Manager,
       CONCAT(E.EmployeeFirstName, ' ', E.EmployeeLastName) AS Employee
FROM Employees E
         JOIN Employees M ON M.EmployeeID = E.ManagerID
ORDER BY Manager, Employee;
GO
/***************************************************************************************/