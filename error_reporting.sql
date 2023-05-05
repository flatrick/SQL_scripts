/* This code is written for SQL Server and has been tested on SQL Server 2019 */

/* Create separate database to store logs in */
USE master;
GO

IF DB_ID(N'Logs') IS NULL
	CREATE DATABASE Logs COLLATE Finnish_Swedish_CI_AS;
GO

ALTER DATABASE Logs SET RECOVERY SIMPLE
GO

/* Table to store the errors in */
CREATE TABLE [Logs].[dbo].[SQLCode_Errors] (
	[ID] BIGINT NOT NULL IDENTITY(1, 1)
	,[Timestamp] DATETIME NOT NULL
	,[ErrorNumber] INT NOT NULL
	,[ErrorSeverity] INT NOT NULL
	,[ErrorState] INT NOT NULL
	,[ErrorProcedure] NVARCHAR(128) NULL
	,[ErrorLine] INT NOT NULL
	,[ErrorMessage] NVARCHAR(4000) NOT NULL
	,[CustomInfo] NVARCHAR(200) NULL
	,CONSTRAINT PK_SQLCode_Errors PRIMARY KEY CLUSTERED (
		[ID]
		,[Timestamp]
		)
	);
GO

/* Stored Procedure to capture the errors and store them in our designated table */
CREATE PROCEDURE usp_SaveError @CustomInfo NVARCHAR(200) = NULL
AS
BEGIN
	INSERT INTO [Logs].[dbo].[SQLCode_Errors] (
		[Timestamp]
		,[ErrorNumber]
		,[ErrorSeverity]
		,[ErrorState]
		,[ErrorProcedure]
		,[ErrorLine]
		,[ErrorMessage]
		,[CustomInfo]
		)
	SELECT GETDATE() AS [Timestamp] 		-- DATETIME
		,ERROR_NUMBER() AS [ErrorNumber]	-- INT
		,ERROR_SEVERITY() AS [ErrorSeverity]	-- INT
		,ERROR_STATE() AS [ErrorState]		-- INT
		,ERROR_PROCEDURE() AS [ErrorProcedure]	-- NVARCHAR(128)
		,ERROR_LINE() AS [ErrorLine]		-- INT
		,ERROR_MESSAGE() AS [ErrorMessage]	-- NVARCHAR(4000)
		,@CustomInfo AS [CustomInfo]		-- NVARCHAR(200);
END
GO

/* Example AD-HOC query to show that even these could use the stored procedure for error reporting */
BEGIN TRY
	SELECT 1 / 0;
END TRY

BEGIN CATCH
	-- Save the error
	EXECUTE usp_SaveError @CustomInfo = 'Beräknar något dumt för inloggningen';

	-- Return the error to the caller/executor of this query
	THROW;
END CATCH;
