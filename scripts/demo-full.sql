/********************************************************
*	PART 1
*	Plan regression identification & manual tuning
********************************************************/

-- Clear everything
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
ALTER DATABASE current SET QUERY_STORE CLEAR ALL;
ALTER DATABASE current SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = OFF);

-- 1. Execute the query and include "Actual execution plan" in SSMS and show the plan - it should have Hash Match (Aggregate) operator with Columnstore Index Scan
EXEC sp_executesql N'select avg([UnitPrice]*[Quantity]) 
    from Sales.OrderLines 
    where PackageTypeID = @packagetypeid', N'@packagetypeid int', @packagetypeid = 7;
GO 60

-- 2. Show Top Resource Consuming Queries, CPU,AVG 1 plan

-- 3. Execute the procedure that causes plan regression
-- Optionally, include "Actual execution plan" in SSMS and show the plan - it should have Stream Aggregate, Index Seek & Nested Loops
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC sp_executesql N'select avg([UnitPrice]*[Quantity]) 
    from Sales.OrderLines 
    where PackageTypeID = @packagetypeid', N'@packagetypeid int', 
    @packagetypeid = 0;


-- 4. Show Top Resource Consuming Queries, new plan

-- 5. Start the workload again - verify that is slower.
-- Optionally, include "Actual execution plan" in SSMS and show the plan - it should have Stream Aggregate with Non-clustered index seek.
EXEC sp_executesql N'select avg([UnitPrice]*[Quantity]) 
    from Sales.OrderLines 
    where PackageTypeID = @packagetypeid', N'@packagetypeid int', 
    @packagetypeid = 7;
go 30


-- 6. Show Top Resource Consuming Queries, slow plan use index seek

-- 7. Find a recommendation that can fix this issue this view
SELECT reason, score, script = JSON_VALUE(details, '$.implementationDetails.script')
FROM sys.dm_db_tuning_recommendations;


/********************************************************
*	PART 2
*   Enable AUTOMATIC_TUNING
********************************************************/

-- RESET - clear everything
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
ALTER DATABASE current SET QUERY_STORE CLEAR ALL;


-- Enable automatic tuning on the database:
ALTER DATABASE current 
SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);

-- 1. Execute the query and include "Actual execution plan" in SSMS and show the plan - it should have Hash Match (Aggregate) operator with Columnstore Index Scan
EXEC sp_executesql N'select avg([UnitPrice]*[Quantity]) 
    from Sales.OrderLines 
    where PackageTypeID = @packagetypeid', N'@packagetypeid int', @packagetypeid = 7;
GO 60


-- 2. Execute the procedure that causes plan regression
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC sp_executesql N'select avg([UnitPrice]*[Quantity]) 
    from Sales.OrderLines 
    where PackageTypeID = @packagetypeid', N'@packagetypeid int', 
    @packagetypeid = 0;

-- 3. Start the workload again - verify that it is getting faster after some query
EXEC sp_executesql N'select avg([UnitPrice]*[Quantity]) 
    from Sales.OrderLines 
    where PackageTypeID = @packagetypeid', N'@packagetypeid int', 
    @packagetypeid = 7;
go 30

-- 4. Show Top Resource Consuming Queries that back to use plan 1