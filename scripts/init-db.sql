-- Insert one OrderLine that with PackageTypeID=(0) will cause regression
INSERT INTO Warehouse.PackageTypes (PackageTypeID, PackageTypeName, LastEditedBy)
VALUES (0, 'FLGP', 1);

INSERT INTO Sales.OrderLines(OrderId, StockItemID, Description, PAckageTypeID, quantity, unitprice, taxrate, PickedQuantity,LastEditedBy)
SELECT TOP 1 OrderID, StockItemID, Description, PackageTypeID = 0, Quantity, UnitPrice, taxrate , PickedQuantity,LastEditedBy
FROM Sales.OrderLines;


-- Add PackageTypeID column into the NCCI index on Sales.OrderLines table
DROP INDEX IF EXISTS [NCCX_Sales_OrderLines] ON [Sales].[OrderLines]

CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCX_Sales_OrderLines] ON [Sales].[OrderLines]
(
	[OrderID],
	[StockItemID],
	[Description],
	[Quantity],
	[UnitPrice],
	[PickedQuantity],
	[PackageTypeID] -- adding package type id for demo purpose
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) 
GO
