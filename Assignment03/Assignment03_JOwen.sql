--*************************************************************************--
-- Title: Assignment03 
-- Desc: This script demonstrates the creation of a typical database with:
--       1) Tables
--       2) Constraints
--       3) Views
-- Dev: JOwen
-- Change Log: When,Who,What
-- 9/21/2021,RRoot,Created File
-- TODO: 9/30/2022,JOwen,Completed File
--**************************************************************************--

--[ Create the Database ]--
--********************************************************************--
USE Master;JOwen
GO
IF EXISTS(SELECT *
          FROM sysdatabases
          WHERE name = 'Assignment03DB_JOwen')
    BEGIN
        USE [master];
        ALTER DATABASE Assignment03DB_JOwen SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- Kick everyone out of the DB
        DROP DATABASE Assignment03DB_JOwen;
    END
GO
CREATE DATABASE Assignment03DB_JOwen;
GO
USE Assignment03DB_JOwen
GO

--[ Create the Tables ]--
--********************************************************************--
CREATE TABLE Categories
(
    [CategoryID]   [int] IDENTITY (1,1) NOT NULL,
    [CategoryName] [nvarchar](100)      NOT NULL
);
GO

CREATE TABLE Products
(
    [ProductID]           [int] IDENTITY (1,1) NOT NULL,
    [ProductName]         [nvarchar](100)      NOT NULL,
    [ProductCurrentPrice] [money]              NOT NULL,
    [CategoryID]          [int]                NULL
);
GO

CREATE TABLE Inventories
(
    [InventoryID]    [int] IDENTITY (1,1) NOT NULL,
    [InventoryDate]  [Date]               NOT NULL,
    [InventoryCount] [int]                NULL,
    [ProductID]      [int]                NOT NULL
);
GO

--[ Add Addtional Constaints ]--
--********************************************************************--
ALTER TABLE dbo.Categories
    ADD CONSTRAINT pkCategories PRIMARY KEY CLUSTERED (CategoryID);
GO
ALTER TABLE dbo.Categories
    ADD CONSTRAINT uCategoryName UNIQUE NONCLUSTERED (CategoryName);
GO

ALTER TABLE dbo.Products
    ADD CONSTRAINT pkProducts PRIMARY KEY CLUSTERED (ProductID);
GO
ALTER TABLE dbo.Products
    ADD CONSTRAINT uProductName UNIQUE NONCLUSTERED (ProductName);
GO
ALTER TABLE dbo.Products
    ADD CONSTRAINT fkProductsCategories
        FOREIGN KEY (CategoryID)
            REFERENCES dbo.Categories (CategoryID);
GO
ALTER TABLE dbo.Products
    ADD CONSTRAINT pkProductsProductCurrentPriceZeroOrMore CHECK (ProductCurrentPrice > 0);
GO

ALTER TABLE dbo.Inventories
    ADD CONSTRAINT pkInventories PRIMARY KEY CLUSTERED (InventoryID);
GO
ALTER TABLE dbo.Inventories
    ADD CONSTRAINT fkInventoriesProducts
        FOREIGN KEY (ProductID)
            REFERENCES dbo.Products (ProductID);
GO
ALTER TABLE dbo.Inventories
    ADD CONSTRAINT ckInventoriesInventoryCountMoreThanZero CHECK (InventoryCount >= 0);
GO
ALTER TABLE dbo.Inventories
    ADD CONSTRAINT dfInventoriesCountIsZero DEFAULT (0)
        FOR [InventoryCount];
GO

--[ Create the Views ]--
--********************************************************************--
CREATE VIEW vCategories
AS
SELECT[CategoryID], [CategoryName]
FROM Categories;
;
GO

CREATE VIEW vProducts
AS
SELECT [ProductID], [ProductName], [CategoryID], [ProductCurrentPrice]
FROM Products;
;
GO

CREATE VIEW vInventories
AS
SELECT [InventoryID], [InventoryDate], [ProductID], [InventoryCount]
FROM Inventories
;
GO

--[Insert Test Data ]--
--********************************************************************--
INSERT INTO Categories
    (CategoryName)
SELECT CategoryName
FROM Northwind.dbo.Categories
ORDER BY CategoryID;
GO

INSERT INTO Products
    (ProductName, CategoryID, ProductCurrentPrice)
SELECT ProductName, CategoryID, UnitPrice
FROM Northwind.dbo.Products
ORDER BY ProductID;
GO

INSERT INTO Inventories
    (InventoryDate, ProductID, [InventoryCount])
SELECT '20200101' AS InventoryDate, ProductID, UnitsInStock
FROM Northwind.dbo.Products
UNION
SELECT '20200201' AS InventoryDate, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
FROM Northwind.dbo.Products
UNION
SELECT '20200302' AS InventoryDate, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
FROM Northwind.dbo.Products
ORDER BY 1, 2
GO

-- Show all of the data in the Categories, Products, and Inventories Tables
SELECT *
FROM vCategories;
GO
SELECT *
FROM vProducts;
GO
SELECT *
FROM vInventories;
GO

/********************************* TODO: Questions and Answers *********************************/

/********************************* Questions and Answers *********************************/

-- Question 1 (5% pts): How can you show the Category ID and Category Name for 'Seafood'?
-- TODO: Add Your Code Here

-- SELECT * FROM Categories;
-- SELECT * FROM Categories WHERE CategoryName = 'Seafood';
SELECT CategoryID, CategoryName
FROM Categories
WHERE CategoryName = 'Seafood';
GO

-- Question 2 (5% pts): How can you show the Product ID, Product Name, and Product Price 
-- of all Products with the Seafood's Category Id? With the results ordered By the Products Price
-- highest to the lowest!
-- TODO: Add Your Code Here

-- SELECT * FROM Products;
-- SELECT * FROM Products WHERE CategoryID = 8;
-- SELECT ProductID, ProductName, ProductCurrentPrice FROM Products WHERE CategoryID = 8;
SELECT ProductID, ProductName, ProductCurrentPrice
FROM Products
WHERE CategoryID = 8
ORDER BY ProductCurrentPrice DESC;
GO

-- Question 3 (5% pts):  How can you show the Product ID, Product Name, and Product Price 
-- Ordered By the Products Price highest to the lowest?
-- With only the products that have a price Greater than $100! 
-- TODO: Add Your Code Here

-- SELECT ProductID, ProductName, ProductCurrentPrice FROM Products;
-- SELECT ProductID, ProductName, ProductCurrentPrice FROM Products ORDER BY ProductCurrentPrice DESC;
SELECT Productid, ProductName, ProductCurrentPrice
FROM Products
WHERE ProductCurrentPrice > 100
ORDER BY ProductCurrentPrice DESC;
GO

-- Question 4 (10% pts): How can you show the CATEGORY NAME, product name, and Product Price 
-- from both Categories and Products? Order the results by Category Name 
-- and then Product Name, in alphabetical order!
-- (Hint: Join Products to Category)
-- TODO: Add Your Code Here

-- SELECT * FROM Products;
-- SELECT * FROM Products JOIN Categories ON Categories.CategoryID = Products.CategoryID;
-- SELECT Categories.CategoryName, Products.ProductName, Products.ProductCurrentPrice FROM Products JOIN Categories ON Categories.CategoryID = Products.CategoryID;
SELECT Categories.CategoryName, Products.ProductName, Products.ProductCurrentPrice
FROM Products
         JOIN Categories
              ON Categories.CategoryID = Products.CategoryID
ORDER BY Categories.CategoryName, Products.ProductName;
GO

-- Question 5 (5% pts): How can you show the Product ID and Number of Products in Inventory
-- for the Month of JANUARY? Order the results by the ProductIDs! 
-- TODO: Add Your Code Here

SELECT ProductID, InventoryCount
FROM Inventories
WHERE MONTH(InventoryDate) = 1;
GO

-- Question 6 (10% pts): How can you show the Category Name, Product Name, and Product Price 
-- from both Categories and Products. Order the results by price highest to lowest?
-- Show only the products that have a PRICE FROM $10 TO $20! 
-- TODO: Add Your Code Here

-- SELECT CategoryName, ProductName, ProductCurrentPrice FROM Products JOIN Categories ON Products.CategoryID = Categories.CategoryID;
-- SELECT CategoryName, ProductName, ProductCurrentPrice FROM Products JOIN Categories ON Products.CategoryID = Categories.CategoryID WHERE ProductCurrentPrice BETWEEN 10 AND 20;
SELECT CategoryName, ProductName, ProductCurrentPrice
FROM Products
         JOIN Categories ON Products.CategoryID = Categories.CategoryID
WHERE ProductCurrentPrice BETWEEN 10 AND 20
ORDER BY ProductCurrentPrice DESC;

GO

-- Question 7 (10% pts) How can you show the Product ID and Number of Products in Inventory
-- for the Month of JANUARY? Order the results by the ProductIDs
-- and where the Product IDs are only in the seafood category!
-- (Hint: Use a subquery to get the list of productIds with a category ID of 8)
-- TODO: Add Your Code Here

-- SELECT ProductID, InventoryCount FROM Inventories WHERE MONTH(InventoryDate) = 1 ORDER BY ProductID;
SELECT ProductID, InventoryCount
FROM Inventories
WHERE MONTH(InventoryDate) = 1
  AND ProductID IN (SELECT ProductID FROM Products WHERE CategoryID = 8)
ORDER BY ProductID;
GO

-- Question 8 (10% pts) How can you show the PRODUCT NAME and Number of Products in Inventory
-- for January? Order the results by the Product Names
-- and where the ProductID as only the ones in the seafood category!
-- (Hint: Use a Join between Inventories and Products to get the Name)
-- TODO: Add Your Code Here

-- Copied code from Question 7 to start
-- SELECT ProductID, InventoryCount
-- FROM Inventories
-- WHERE MONTH(InventoryDate) = 1
--   AND ProductID IN (SELECT ProductID FROM Products WHERE CategoryID = 8)
-- ORDER BY ProductID;
SELECT ProductName, InventoryCount
FROM Inventories
         JOIN Products ON Inventories.ProductID = Products.ProductID
WHERE Products.CategoryID = 8
  AND MONTH(InventoryDate) = 1
ORDER BY ProductName;
GO

-- Question 9 (20% pts) How can you show the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBRUARY? Show what the AVERAGE AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names! 
-- TODO: Add Your Code Here

-- Copied code from Question 8 to start
-- SELECT ProductName, InventoryCount
-- FROM Inventories
--          JOIN Products ON Inventories.ProductID = Products.ProductID
-- WHERE Products.CategoryID = 8
--   AND MONTH(InventoryDate) = 1
-- ORDER BY ProductName;
-- SELECT ProductName, InventoryCount
-- FROM Inventories
--          JOIN Products ON Inventories.ProductID = Products.ProductID
-- WHERE Products.CategoryID = 8
--   AND MONTH(InventoryDate) IN(1, 2)
-- ORDER BY ProductName;
SELECT ProductName, AVG(InventoryCount) AS [AvgAmountInInventory]
FROM Inventories
         JOIN Products ON Inventories.ProductID = Products.ProductID
WHERE Products.CategoryID = 8
  AND MONTH(InventoryDate) IN (1, 2)
GROUP BY ProductName
ORDER BY ProductName;
GO

-- Question 10 (20% pts) How can you show the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBRUARY? Show what the AVERAGE AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names! 
-- Restrict the results to rows with a Average COUNT OF 100 OR HIGHER!
-- TODO: Add Your Code Here

-- Copied code from Question 9 to start
-- SELECT ProductName, AVG(InventoryCount) AS [AvgAmountInInventory]
-- FROM Inventories
--          JOIN Products ON Inventories.ProductID = Products.ProductID
-- WHERE Products.CategoryID = 8
--   AND MONTH(InventoryDate) IN (1, 2)
-- GROUP BY ProductName
-- ORDER BY ProductName;
SELECT ProductName, AVG(InventoryCount) AS [AvgAmountInInventory]
FROM Inventories
         JOIN Products ON Inventories.ProductID = Products.ProductID
WHERE Products.CategoryID = 8
  AND MONTH(InventoryDate) IN (1, 2)
GROUP BY ProductName
HAVING AVG(InventoryCount) >= 100
ORDER BY ProductName;
GO


/***************************************************************************************/



