----------------------------------------------------------------------
-- Title: Assignment01
-- Desc: Creating a normalized database from sample data
-- Author: JOwen
-- ChangeLog: (When,Who,What)
-- 9/21/2021,RRoot,Created Script
-- TODO: 4/18/2022,JOwen,Completed Script
----------------------------------------------------------------------

--[ Create the Database ]--
--********************************************************************--
Use Master;
go
If exists (Select * From sysdatabases Where name='Assignment01DB_JOwen')
  Begin
  	Use [master];
	  Alter Database Assignment01DB_JOwen Set Single_User With Rollback Immediate; -- Kick everyone out of the DB
		Drop Database Assignment01DB_JOwen;
  End
go
Create Database Assignment01DB_JOwen;
go
Use Assignment01DB_JOwen;
go

--[ Create the Tables ]--
--********************************************************************--

-- TODO: Create Multiple tables to hold the following data --

/*  Products,Price,Units,Customer,Address,Date
    Apples,$0.89,12,Bob Smith,123 Main Bellevue Wa,5/5/2006 
    Milk,$1.59,2,Bob Smith,123 Main Bellevue Wa,5/5/2006 
    Bread,$2.28,1,Bob Smith,123 Main Bellevue Wa,5/5/2006
*/

-- Create Table Example(Col1 int, Col2 nvarchar(100));

/*
   Create three tables:
     - Products: Name, Price
     - Customers: Name, Address
     - Orders: ProductID, Quantity, CustomerID, OrderDate
*/
CREATE TABLE Products(
  ID int PRIMARY KEY, 
  ItemName nvarchar(100) NOT NULL, 
  Price money NOT NULL
);
GO
CREATE TABLE Customers(
  ID int PRIMARY KEY, 
  CustomerFirstName nvarchar(100) NOT NULL, 
  CustomerLastName nvarchar(100) NOT NULL, 
  CustomerAddress1 nvarchar(100) NOT NULL,
  CustomerCity nvarchar(100) NOT NULL,
  CustomerState nvarchar(2) NOT NULL
);
GO
CREATE TABLE Orders(
  ID int PRIMARY KEY,
  CustomerID int FOREIGN KEY REFERENCES Customers(ID) NOT NULL,
  OrderDate nvarchar(10) NOT NULL
);
GO
CREATE TABLE OrderLineItems(
  LineItemID int,
  OrderID int FOREIGN KEY REFERENCES Orders(ID), 
  ProductID int FOREIGN KEY REFERENCES Products(ID) NOT NULL, 
  Quantity int NOT NULL, 
  PRIMARY KEY(LineItemID, OrderID)
);
GO

-- TODO: Insert the provided data to test your design -- 

-- Insert product data
INSERT INTO Products(ID, ItemName, Price) VALUES 
  (1, 'Apples', .89), 
  (2, 'Milk', 1.59), 
  (3, 'Bread', 2.28);
GO
-- Insert customer data 
INSERT INTO Customers (ID, CustomerFirstName, CustomerLastName, CustomerAddress1, CustomerCity, CustomerState) VALUES (1, 'Bob', 'Smith', '123 Main', 'Bellevue', 'WA');
GO
-- Insert order data
INSERT INTO Orders (ID, CustomerID, OrderDate) VALUES (1, 1, '5/5/2006');
GO
-- Insert order line item data
INSERT INTO OrderLineItems (LineItemID, OrderID, ProductID, Quantity) VALUES 
  (1, 1, 1, 12), 
  (2, 1, 2, 2),
  (3, 1, 3, 1);
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

