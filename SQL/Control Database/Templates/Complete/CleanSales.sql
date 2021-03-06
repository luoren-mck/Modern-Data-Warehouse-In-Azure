
DROP PROC IF EXISTS SalesSystem.CleanSales
GO

CREATE PROC SalesSystem.CleanSales
(
    @LoadId INTEGER = NULL
)

AS
BEGIN

    DROP TABLE IF EXISTS #Sales
	
	TRUNCATE TABLE Stage.Sales

	BEGIN TRY

		SELECT
             @LoadId AS LoadId
            ,GETDATE() AS LoadDate
		    			,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([SalesPerson], char(9),''),char(10),''),char(13),'')))
			,COALESCE([SalesAmount],0)
			,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([ProductName], char(9),''),char(10),''),char(13),'')))
			,REPLACE(REPLACE([ProductName],'Unknown',NULL),'N/A',NULL)
			,REPLACE(REPLACE([ProductId],'Unknown',NULL),'N/A',NULL)
			,REPLACE(REPLACE([CustomerId],'Unknown',NULL),'N/A',NULL)

		INTO #Sales
		FROM
		    Stage.Sales

		INSERT INTO Clean.Sales
		SELECT
			 LoadId
            ,GETDATE() AS LoadDate
						,CAST([SalesPerson] AS NVARCHAR(100))
			,CAST([SalesAmount] AS DECIMAL(10,2))
			,CAST([ProductName] AS NVARCHAR(100))
			,CAST([ProductName] AS NVARCHAR(100))
			,CAST([ProductId] AS INTEGER)
			,CAST([CustomerId] AS INTEGER)

		FROM
			#Sales

	END TRY

	BEGIN CATCH
		
		RAISERROR('Could not complete the clean / rules step for SalesSystem.Sales',1,1);

	END CATCH

