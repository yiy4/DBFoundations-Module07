--*************************************************************************--
-- Title: Assignment07
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2022-03-01, Ann Yi, Completed File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_AYi')
	 Begin 
	  Alter Database [Assignment07DB_AYi] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_AYi;
	 End
	Create Database Assignment07DB_AYi;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_AYi;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
--Select * From vProducts;
--go
--Select * From vEmployees;
--go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
go

-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

select
	ProductName, 
	format (UnitPrice, 'C', 'en-US') as 'UnitPrice'
from 
	vProducts
order by 
	ProductName;
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

select
	CategoryName, ProductName, 
	format (UnitPrice, 'C', 'en-US') as 'UnitPrice'
from 
	vCategories
		join vProducts on vCategories.CategoryID = vProducts.CategoryID
order by 
	CategoryName, 
	ProductName;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

select 
	ProductName, 
	datename (mm, InventoryDate) + ', ' + datename (yy, InventoryDate) as 'InventoryDate', 
	[count] as 'InventoryCount'
from 
	vProducts
		join vInventories on vProducts.ProductID = vInventories.ProductID
order by 
	ProductName,
	vInventories.InventoryDate;
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

create view vProductInventories
	as
	select top 100000
		ProductName,
		datename (mm, InventoryDate) + ', ' + datename (yy, InventoryDate) as 'InventoryDate', 
		[count] as 'InventoryCount'
	from 
		vProducts
			join vInventories on vProducts.ProductID = vInventories.ProductID
	order by 
		ProductName,
		vInventories.InventoryDate;
	go

-- Check that it works: 

select * from vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

create view vCategoryInventories
	as
	select top 100000
		CategoryName,
		datename (mm, InventoryDate) + ', ' + datename (yy, InventoryDate) as 'InventoryDate', 
		sum ([count]) as 'InventoryCountbyCategory'
	from 
		vCategories
			join vProducts on vCategories.CategoryID = vProducts.CategoryID
			join vInventories on vProducts.ProductID = vInventories.ProductID
	group by 
		CategoryName,
		InventoryDate
	order by 
		CategoryName,
		vInventories.InventoryDate;
go

-- Check that it works: 

select * from vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

--drop view vProductInventoriesWithPreviouMonthCounts
--select * from vProductInventories;

create view vProductInventoriesWithPreviouMonthCounts
	as
	select 
		ProductName,
		InventoryDate, 
		InventoryCount,
		lag (InventoryCount, 1, 0) over (partition by ProductName order by month (InventoryDate)) as PreviousMonthCount
	from 
		vProductInventories;
go

--https://www.sqlshack.com/sql-lag-function-overview-and-examples/

-- Check that it works: 

select * from vProductInventoriesWithPreviouMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

--drop view ProductInventoriesWithPreviousMonthCountsWithKPIs;

create view ProductInventoriesWithPreviousMonthCountsWithKPIs
	as
	select top 100000
		ProductName,
		InventoryDate, 
		InventoryCount,
		PreviousMonthCount,
	case 
		when InventoryCount > PreviousMonthCount then 1
		when InventoryCount = PreviousMonthCount then 0
		when InventoryCount < PreviousMonthCount then -1
		end
		as CountVsPreviousCountKPI
	from 
		vProductInventoriesWithPreviouMonthCounts;
go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: 

select * from ProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

--drop function fProductInventoriesWithPreviousMonthCountsWithKPIs;

create function fProductInventoriesWithPreviousMonthCountsWithKPIs(@CountVsPreviousCountKPI int)
	returns table
	as
		return (
			select top 100000
				ProductName,
				InventoryDate,
				InventoryCount,
				PreviousMonthCount,
				CountVsPreviousCountKPI
			from 
				ProductInventoriesWithPreviousMonthCountsWithKPIs
			where 
				ProductInventoriesWithPreviousMonthCountsWithKPIs.CountVsPreviousCountKPI = @CountVsPreviousCountKPI
			order by
				ProductName,
				month (InventoryDate));
go

--https://www.youtube.com/watch?v=bcPbsofAR5g

--Check that it works:
select * from fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
select * from fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
select * from fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);

go

/***************************************************************************************/