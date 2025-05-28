/* 
   This script checks if the database "datawerehouse" exists.
   If it exists, it disconnects all users and deletes it.
   After that, it creates a new database with the same name.
*/

USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'datawerehouse')
BEGIN
    ALTER DATABASE datawerehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE datawerehouse;
END;

Go

CREATE DATABASE datawerehouse;

GO

USE datawerehouse;

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
END

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
END


