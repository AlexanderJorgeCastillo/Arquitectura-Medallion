/*
=============================================================
Crear Base de Datos y Esquemas
=============================================================
*/

USE master;
GO


-- Eliminar y volver a crear la base de datos 'DataWarehouse'

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO


-- Crear la base de datos 'DataWarehouse'

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO


-- Crear las 3 capas

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO