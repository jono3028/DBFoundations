--*************************************************************************--
-- Title: Assignment04
-- Author: JOwen
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2022-05-10, JOwen, Completed File
--**************************************************************************--
USE Master;
GO

IF EXISTS(SELECT Name
          FROM SysDatabases
          WHERE Name = 'Assignment04DB_JOwen')
    BEGIN
        ALTER DATABASE [Assignment04DB_JOwen] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE Assignment04DB_JOwen;
    END
GO

CREATE DATABASE Assignment04DB_JOwen;
GO

USE Assignment04DB_JOwen;
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
    [UnitPrice]   [money]              NOT NULL
);
GO

CREATE TABLE Inventories
(
    [InventoryID]   [int] IDENTITY (1,1) NOT NULL,
    [InventoryDate] [Date]               NOT NULL,
    [ProductID]     [int]                NOT NULL,
    [Count]         [int]                NOT NULL
);
GO

-- Add Constraints (Module 02) -- 
ALTER TABLE Categories
    ADD CONSTRAINT pkCategories
        PRIMARY KEY (CategoryId);
GO

ALTER TABLE Categories
    ADD CONSTRAINT ukCategories
        UNIQUE (CategoryName);
GO

ALTER TABLE Products
    ADD CONSTRAINT pkProducts
        PRIMARY KEY (ProductId);
GO

ALTER TABLE Products
    ADD CONSTRAINT ukProducts
        UNIQUE (ProductName);
GO

ALTER TABLE Products
    ADD CONSTRAINT fkProductsToCategories
        FOREIGN KEY (CategoryId) REFERENCES Categories (CategoryId);
GO

ALTER TABLE Products
    ADD CONSTRAINT ckProductUnitPriceZeroOrHigher
        CHECK (UnitPrice >= 0);
GO

ALTER TABLE Inventories
    ADD CONSTRAINT pkInventories
        PRIMARY KEY (InventoryId);
GO

ALTER TABLE Inventories
    ADD CONSTRAINT dfInventoryDate
        DEFAULT GETDATE() FOR InventoryDate;
GO

ALTER TABLE Inventories
    ADD CONSTRAINT fkInventoriesToProducts
        FOREIGN KEY (ProductId) REFERENCES Products (ProductId);
GO

ALTER TABLE Inventories
    ADD CONSTRAINT ckInventoryCountZeroOrHigher
        CHECK ([Count] >= 0);
GO


-- Show the Current data in the Categories, Products, and Inventories Tables
SELECT *
FROM Categories;
GO
SELECT *
FROM Products;
GO
SELECT *
FROM Inventories;
GO

/********************************* TASKS *********************************/

-- Add the following data to this database.
-- All answers must include the Begin Tran, Commit Tran, and Rollback Tran transaction statements. 
-- All answers must include the Try/Catch blocks around your transaction processing code.
-- Display the Error message if the catch block Changis invoked.

/* Add the following data to this database:
Beverages	Chai	                        18.00	2017-01-01	61
Beverages	Chang	                        19.00	2017-01-01	87
Condiments	Aniseed Syrup	                10.00	2017-01-01	19
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-01-01	81
Beverages	Chai	                        18.00	2017-02-01	13
Beverages	Chang	                        19.00	2017-02-01	2
Condiments	Aniseed Syrup	                10.00	2017-02-01	1
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-02-01	79
Beverages	Chai	                        18.00	2017-03-02	18
Beverages	Chang	                        19.00	2017-03-02	12
Condiments	Aniseed Syrup	                10.00	2017-03-02	84
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-03-02	72
*/

-- Task 1 (20 pts): Add data to the Categories table
BEGIN TRY
    BEGIN TRANSACTION
        INSERT INTO Categories (CategoryName)
        VALUES ('Beverages'),
               ('Condiments');
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    RAISERROR ('Error inserting to categories table', 9, 1);
    PRINT ERROR_MESSAGE();
    ROLLBACK TRANSACTION
END CATCH
GO

-- Task 2 (20 pts): Add data to the Products table
BEGIN TRY
    BEGIN TRANSACTION
        DECLARE @CategoryID AS nvarchar(100);

        -- Insert Beverages
        SET @CategoryID = (SELECT TOP (1) [CategoryID]
                           FROM Categories
                           WHERE [CategoryName] = 'Beverages'); --Unique constraint on [CategoryName]

        INSERT INTO Products([ProductName], [CategoryID], [UnitPrice])
        VALUES ('Chai', @CategoryID, 18),
               ('Chang', @CategoryID, 19);

        -- Insert Condiments
        SET @CategoryID = (SELECT TOP (1) [CategoryID]
                           FROM Categories
                           WHERE [CategoryName] = 'Condiments'); --Unique constraint on [CategoryName]

        INSERT INTO Products([ProductName], [CategoryID], [UnitPrice])
        VALUES ('Aniseed Syrup', @CategoryID, 10),
               ('Chef Anton''s Cajun Seasoning', @CategoryID, 22);
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    RAISERROR ('Error inserting to products table', 9, 1);
    PRINT ERROR_MESSAGE();
    ROLLBACK TRANSACTION
END CATCH
GO

-- Task 3 (20 pts): Add data to the Inventories table
BEGIN TRY
    BEGIN TRANSACTION
        DECLARE @ProductID int;

        -- Insert Chai data
        SET @ProductID = (SELECT TOP (1) [ProductID]
                          FROM Products
                          WHERE [ProductName] = 'Chai'); --Unique constraint on [ProductName]
        INSERT INTO Inventories (InventoryDate, ProductID, Count)
        VALUES ('2017-01-01', @ProductID, 61),
               ('2017-02-01', @ProductID, 13),
               ('2017-03-02', @ProductID, 18);

        -- Insert Chang data
        SET @ProductID = (SELECT TOP (1) [ProductID]
                          FROM Products
                          WHERE [ProductName] = 'Chang'); --Unique constraint on [ProductName]
        INSERT INTO Inventories (InventoryDate, ProductID, Count)
        VALUES ('2017-01-01', @ProductID, 87),
               ('2017-02-01', @ProductID, 2),
               ('2017-03-02', @ProductID, 12);

        -- Insert Aniseed Syrup data
        SET @ProductID = (SELECT TOP (1) [ProductID]
                          FROM Products
                          WHERE [ProductName] = 'Aniseed Syrup'); --Unique constraint on [ProductName]
        INSERT INTO Inventories (InventoryDate, ProductID, Count)
        VALUES ('2017-01-01', @ProductID, 19),
               ('2017-02-01', @ProductID, 1),
               ('2017-03-02', @ProductID, 84);

        -- Insert Chef Anton's Cajun Seasoning data
        SET @ProductID = (SELECT TOP (1) [ProductID]
                          FROM Products
                          WHERE [ProductName] = 'Chef Anton''s Cajun Seasoning'); --Unique constraint on [ProductName]
        INSERT INTO Inventories (InventoryDate, ProductID, Count)
        VALUES ('2017-01-01', @ProductID, 81),
               ('2017-02-01', @ProductID, 79),
               ('2017-03-02', @ProductID, 72);

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    RAISERROR ('Error inserting to inventory table', 9, 1);
    PRINT ERROR_MESSAGE();
    ROLLBACK TRANSACTION
END CATCH
GO

-- Task 4 (10 pts): Write code to update the Category "Beverages" to "Drinks"
BEGIN TRY
    BEGIN TRANSACTION
        DECLARE @RowID int;
        SET @RowID = (SELECT [CategoryID] FROM Categories WHERE [CategoryName] = 'Beverages');

        UPDATE Categories SET [CategoryName] = 'Drinks' WHERE [CategoryID] = @RowID;
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    RAISERROR ('Error updating categories table', 9, 1);
    PRINT ERROR_MESSAGE();
    ROLLBACK TRANSACTION
END CATCH
GO

-- Task 5 (30 pts): Write code to delete all Condiments data from the database (in all three tables!)
BEGIN TRY
    BEGIN TRANSACTION
    DECLARE @CategoryID int;
    SET @CategoryID = (SELECT [CategoryID] FROM Categories WHERE [CategoryName] = 'Condiments');
    SELECT [ProductID] INTO #SelectedCategoryProducts FROM Products WHERE [CategoryID] = @CategoryID;

    DELETE
    FROM Inventories
    WHERE [ProductID] IN (SELECT [ProductID]
                          FROM #SelectedCategoryProducts);
    DELETE FROM Products WHERE [CategoryID] = @CategoryID;
    DELETE FROM Categories WHERE [CategoryID] = @CategoryID;

    DROP TABLE #SelectedCategoryProducts;

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    RAISERROR ('Error deleting condiments', 9, 1);
    PRINT ERROR_MESSAGE();
    ROLLBACK TRANSACTION
END CATCH
GO

/***************************************************************************************/