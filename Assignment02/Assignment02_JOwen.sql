--*************************************************************************--
-- Title: Assignment02 
-- Desc: This script demonstrates the creation of a typical database with:
--       1) Tables
--       2) Constraints
--       3) Views
-- Dev: RRoot
-- Change Log: When,Who,What
-- 9/21/2021,RRoot,Created File
-- TODO: 4/22/2022,JOwen,Completed File
--**************************************************************************--

--[ Create the Database ]--
--********************************************************************--
Use Master;
go
If exists (Select * From sysdatabases Where name='Assignment02DB_JOwen')
  Begin
  	Use [master];
	  Alter Database Assignment02DB_JOwen Set Single_User With Rollback Immediate; -- Kick everyone out of the DB
		Drop Database Assignment02DB_JOwen;
  End
go
Create Database Assignment02DB_JOwen;
go
Use Assignment02DB_JOwen;
go

--[ Create the Tables ]--
--********************************************************************--
-- NOTE: Include identity "default" when creating your tables

-- TODO: Create table for Categories 
CREATE TABLE Categories (
    CategoryID          int             NOT NULL IDENTITY,
    CategoryName        nvarchar(100)   NOT NULL
);

-- TODO: Create table for Products
CREATE TABLE Products (
    ProductID           int             NOT NULL IDENTITY ,
    ProductName         nvarchar(100)   NOT NULL,
    ProductCurrentPrice money           NOT NULL,
    CategoryID          int             NULL
);

-- TODO: Create table for Inventories
CREATE TABLE Inventories (
    InventoryID         int             NOT NULL IDENTITY ,
    InventoryDate       date            NOT NULL,
    InventoryCount      int             NULL,
    ProductID           int             NOT NULL
);
GO

--[ Add Constaints ]--
--********************************************************************--
-- TODO: Add Constraints for Categories (Primary Key, Identity, Unique)
ALTER TABLE Categories ADD
    CONSTRAINT pk_Categories PRIMARY KEY CLUSTERED (CategoryID),
    CONSTRAINT uq_CategoryName UNIQUE (CategoryName);

-- EXEC sp_helpconstraint Categories;
GO

-- TODO: Add Constraints for Products (Primary Key, Unique, Foreign Key, Check)
ALTER TABLE Products ADD
    CONSTRAINT pk_Products PRIMARY KEY CLUSTERED (ProductID),
    CONSTRAINT fk_ProductsToCategories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT uq_ProductName UNIQUE (ProductName),
    CONSTRAINT ck_ProductCurrentPriceGreaterThan CHECK (ProductCurrentPrice > 0);

-- EXEC sp_helpconstraint Products;
GO

-- TODO: Add Constraints for Inventories (Primary Key, Foreign Key, Check, Default)
ALTER TABLE Inventories ADD
    CONSTRAINT pk_Inventories PRIMARY KEY CLUSTERED (InventoryID),
    CONSTRAINT fk_InventoriesToProducts FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT df_InventoryCount DEFAULT (0) FOR InventoryCount,
    CONSTRAINT ck_InventoryCountGreaterThanOrEqual CHECK (InventoryCount >= 0);

-- EXEC sp_helpconstraint Inventories;
GO

--[ Create the Views ]--
--********************************************************************--
-- TODO: Create View for Categories (Primary Key, Unique)
CREATE VIEW vwCategories AS
    SELECT CategoryID, CategoryName FROM Categories;
GO

-- TODO: Create View for Products (Primary Key, Unique, Foreign Key, Check)
CREATE VIEW vwProducts AS
    SELECT ProductID, ProductName, CategoryID, ProductCurrentPrice FROM Products;
GO

-- TODO: Create View for Inventories (Primary Key, Foreign Key, Check, Default)
CREATE VIEW vwInventories AS
    SELECT InventoryID, ProductID, InventoryCount, InventoryDate FROM Inventories;
GO

--[Insert Test Data ]--
--********************************************************************--

-- TODO: Add data to Categories
/*
CategoryID	CategoryName
1	        CatA
2	        CatB
*/
INSERT INTO Categories (CategoryName) VALUES ('CatA'), ('CatB');
GO
-- TODO: Add data to Products••••••
/*
ProductID	ProductName	CategoryID	UnitPrice
1	        Prod1	    1	        9.99
2	        Prod2	    1	        19.99
3	        Prod3	    2	        14.99
*/
INSERT INTO Products (ProductName, CategoryID, ProductCurrentPrice) VALUES
    ('Prod1', 1, 9.99),
    ('Prod2', 1, 19.99),
    ('Prod3', 2, 14.00);
GO

-- TODO: Add data to Inventories
/*
InventoryID	InventoryDate	ProductID	InventoryCount
1	        2020-01-01	    1	        100
2	        2020-01-01	    2	        50
3	        2020-01-01	    3	        34
4	        2020-02-01	    1	        100
5	        2020-02-01	    2	        50
6	        2020-02-01	    3	        34
*/
INSERT INTO Inventories (InventoryDate, ProductID, InventoryCount) VALUES
    ('2020-01-01', 1, 100),
    ('2020-01-01', 2, 50),
    ('2020-01-01', 3, 34),
    ('2020-02-01', 1, 100),
    ('2020-02-01', 2, 50),
    ('2020-02-01', 3, 34);
GO
--[ Review the design ]--
--********************************************************************--
-- Note: This is advanced code and it is NOT expected that you should be able to read it yet. 
-- However, you will be able to by the end of the course! :-)
-- Meta Data Query:
With 
TablesAndColumns As (
Select  
  [SourceObjectName] = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
, [IS_NULLABLE]=[IS_NULLABLE]
, [DATA_TYPE] = Case [DATA_TYPE]
                When 'varchar' Then  [DATA_TYPE] + '(' + IIf(DATA_TYPE = 'int','', IsNull(Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)), '')) + ')'
                When 'nvarchar' Then [DATA_TYPE] + '(' + IIf(DATA_TYPE = 'int','', IsNull(Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)), '')) + ')'
                When 'money' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                When 'decimal' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                When 'float' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                Else [DATA_TYPE]
                End                          
, [TABLE_NAME]
, [COLUMN_NAME]
, [ORDINAL_POSITION]
, [COLUMN_DEFAULT]
From Information_Schema.columns 
),
Constraints As (
Select 
 [SourceObjectName] = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
,[CONSTRAINT_NAME]
From [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE]
), 
IdentityColumns As (
Select 
 [ObjectName] = object_name(c.[object_id]) 
,[ColumnName] = c.[name]
,[IsIdentity] = IIF(is_identity = 1, 'Identity', Null)
From sys.columns as c Join Sys.tables as t on c.object_id = t.object_id
) 
Select 
  TablesAndColumns.[SourceObjectName]
, [IsNullable] = [Is_Nullable]
, [DataType] = [Data_Type] 
, [ConstraintName] = IsNull([CONSTRAINT_NAME], 'NA')
, [COLUMN_DEFAULT] = IsNull(IIF([IsIdentity] Is Not Null, 'Identity', [COLUMN_DEFAULT]), 'NA')
--, [ORDINAL_POSITION]
From TablesAndColumns 
Full Join Constraints On TablesAndColumns.[SourceObjectName]= Constraints.[SourceObjectName]
Full Join IdentityColumns On TablesAndColumns.COLUMN_NAME = IdentityColumns.[ColumnName]
                          And TablesAndColumns.Table_NAME = IdentityColumns.[ObjectName]
Where [TABLE_NAME] Not In (Select [TABLE_NAME] From [INFORMATION_SCHEMA].[VIEWS])
Order By [TABLE_NAME],[ORDINAL_POSITION]


-- Important: The correct design should match this output when my meta data query runs
/*
SourceObjectName	                                    IsNullable	DataType	    ConstraintName	                        COLUMN_DEFAULT
Assignment02DB_RRoot.dbo.Categories.CategoryID	        NO	        int	            pkCategories	                        Identity
Assignment02DB_RRoot.dbo.Categories.CategoryName	    NO	        nvarchar(100)	uCategoryName	                        NA
Assignment02DB_RRoot.dbo.Inventories.InventoryID	    NO	        int	            pkInventories	                        Identity
Assignment02DB_RRoot.dbo.Inventories.InventoryDate	    NO	        date	        NA	                                    NA
Assignment02DB_RRoot.dbo.Inventories.InventoryCount	    YES	        int	            ckInventoriesInventoryCountMoreThanZero	((0))
Assignment02DB_RRoot.dbo.Inventories.ProductID	        NO	        int	            fkInventoriesProducts	                NA
Assignment02DB_RRoot.dbo.Products.ProductID	            NO	        int	            pkProducts	                            Identity
Assignment02DB_RRoot.dbo.Products.ProductName	        NO	        nvarchar(100)	uProductName	                        NA
Assignment02DB_RRoot.dbo.Products.ProductCurrentPrice	NO	        money(19,4)	    pkProductsUnitPriceZeroOrMore	        NA
Assignment02DB_RRoot.dbo.Products.CategoryID	        YES	        int	            fkProductsCategories	                NA
*/

