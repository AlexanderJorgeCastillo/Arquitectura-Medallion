/*
===============================================================================
Procedimiento Almacenado: Cargar Capa Bronze
===============================================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY

        SET @start_time = GETDATE();

        PRINT ('================================================');
        PRINT ('Cargando la Capa Bronze');
        PRINT ('================================================');
        PRINT ('');
        PRINT(CONCAT('Iniciando la carga de la capa Bronze: ',CAST(@start_time AS VARCHAR(50))));
        PRINT ('');
        PRINT ('-----------------------------------');
        PRINT ('>> Truncando Tabla: bronze.ventas');
        TRUNCATE TABLE bronze.ventas;
        PRINT ('>> Insertando Datos en: bronze.ventas');
        BULK INSERT bronze.ventas
        FROM 'C:\SQL\SQL_IngenieriaDatos\DW_Comercial\Dataset\ventas.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT ('-----------------------------------');
        PRINT ('');
        PRINT(CONCAT('Finalización de la carga de la capa Bronze: ',CAST(@end_time AS VARCHAR(50))));
        PRINT ('');
        PRINT '>> Duracion Total de la Carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT ('');

    END TRY

    BEGIN CATCH
        PRINT ('==============================================================================');
        PRINT ('OCURRIO UN ERROR DURANTE LA CARGA DE LA CAPA BRONZE');
        PRINT ('');
        PRINT ('Mensaje de Error: ' + ERROR_MESSAGE());
        PRINT ('Numero de error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10)));
        PRINT ('Estado de error: '+ CAST(ERROR_STATE() AS VARCHAR(10)));
        PRINT ('==============================================================================');
    END CATCH

END;
GO
