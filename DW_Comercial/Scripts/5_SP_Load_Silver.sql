/*
===============================================================================
Procedimiento Almacenado: Cargar Capa Silver
===============================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS

BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT ('================================================');
        PRINT ('Cargando la Capa Silver');
        PRINT ('================================================');
        PRINT ('')
        PRINT(CONCAT('Iniciando la carga de la capa Silver: ',CAST(@batch_start_time AS VARCHAR(50))));
        PRINT ('')


        -- 1. Carga de Tabla Clientes


        SET @start_time = GETDATE();

        PRINT ('-----------------------------------');
        PRINT ('>> Truncando Tabla: silver.clientes');
        TRUNCATE TABLE silver.clientes;

        PRINT ('>> Insertando Datos en: silver.clientes');
        INSERT INTO silver.clientes (id_cliente, nombre, apellido, nombre_completo, email, pais, genero, estado_civil)
        SELECT 
            id_cliente, 
            TRIM(nombre_cliente), 
            TRIM(apellido_cliente), 
            TRIM(apellido_cliente) + ', ' + TRIM(nombre_cliente) AS nombre_completo,            
            email_cliente,
            CASE 
                WHEN UPPER(TRIM(pais_cliente)) IN ('US', 'USA', 'ESTADOS UNIDOS') THEN 'Estados Unidos'
                WHEN UPPER(TRIM(pais_cliente)) IN ('MX', 'MEXICO') THEN 'Mexico'
                WHEN UPPER(TRIM(pais_cliente)) IN ('ES', 'ESPAÑA') THEN 'España'
                WHEN UPPER(TRIM(pais_cliente)) IN ('CO', 'COLOMBIA') THEN 'Colombia'
                ELSE 'n/a'
            END,
            CASE 
                WHEN UPPER(TRIM(genero_cliente)) IN ('M', 'MALE') THEN 'Masculino'
                WHEN UPPER(TRIM(genero_cliente)) IN ('F', 'FEMALE') THEN 'Femenino'
                ELSE 'n/a'
            END,
            CASE 
                WHEN UPPER(TRIM(estado_civil_cliente)) IN ('S', 'SOLTERO') THEN 'Soltero'
                WHEN UPPER(TRIM(estado_civil_cliente)) IN ('C', 'CASADO') THEN 'Casado'
                ELSE 'n/a'
            END
        FROM (
            SELECT *, ROW_NUMBER() OVER(PARTITION BY id_cliente ORDER BY id_transaccion DESC) as rw 
            FROM bronze.ventas WHERE id_cliente IS NOT NULL
        ) t WHERE rw = 1;

        SET @end_time = GETDATE();
        PRINT ('')
        PRINT ('>> Duracion de la Carga: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos');
        PRINT ('')




        -- 2. Carga de Tabla Productos


        SET @start_time = GETDATE();

        PRINT ('-----------------------------------');
        PRINT ('>> Truncando Tabla: silver.productos');
        TRUNCATE TABLE silver.productos;

        PRINT ('>> Insertando Datos en: silver.productos');
        INSERT INTO silver.productos (id_producto, codigo, nombre, categoria, subcategoria, costo_fabricacion)
        SELECT 
            id_producto, TRIM(codigo_producto), TRIM(nombre_producto), TRIM(categoria_producto), TRIM(subcategoria_producto),
            TRY_CAST(costo_fabricacion AS FLOAT)
        FROM (
            SELECT *, ROW_NUMBER() OVER(PARTITION BY id_producto ORDER BY id_transaccion DESC) as rw 
            FROM bronze.ventas WHERE id_producto IS NOT NULL
        ) t WHERE rw = 1;

        SET @end_time = GETDATE();   
        PRINT ('')
        PRINT ('>> Duracion de la Carga: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos');
        PRINT ('')


        -- 3. Carga de Tabla Ventas


        SET @start_time = GETDATE();

        PRINT ('-----------------------------------');
        PRINT ('>> Truncando Tabla: silver.ventas_detalle');
        TRUNCATE TABLE silver.ventas_detalle;


        PRINT '>> Insertando Datos en: silver.ventas_detalle';
        INSERT INTO silver.ventas_detalle (
            id_transaccion, fecha_venta, fecha_envio, id_cliente, id_producto, cantidad, precio_unitario, monto_total, metodo_pago
        )
        SELECT 
            id_transaccion,
            TRY_CAST(fecha_venta AS DATE),
            CASE 
                WHEN fecha_envio = '' OR fecha_envio IS NULL THEN NULL 
                ELSE TRY_CAST(fecha_envio AS DATE) 
            END,
            id_cliente, id_producto,
            ABS(TRY_CAST(cantidad AS INT)) AS cantidad,
            TRY_CAST(precio_unitario AS FLOAT),
            CASE 
                WHEN TRY_CAST(monto_total AS FLOAT) IS NULL OR TRY_CAST(monto_total AS FLOAT) <= 0 
                THEN ABS(TRY_CAST(cantidad AS INT)) * TRY_CAST(precio_unitario AS FLOAT)
                ELSE TRY_CAST(monto_total AS FLOAT)
            END AS monto_total,
            TRIM(metodo_pago)
        FROM (
            SELECT *, ROW_NUMBER() OVER(PARTITION BY id_transaccion ORDER BY id_transaccion) as rw 
            FROM bronze.ventas
            WHERE fecha_venta != '0' AND len(fecha_venta) >= 8 AND TRY_CAST(fecha_venta AS DATE) IS NOT NULL
        ) t WHERE rw = 1;

        SET @end_time = GETDATE();
        PRINT ('')
        PRINT ('>> Duracion de la Carga: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos');
        PRINT ('')


        SET @batch_end_time = GETDATE();
        PRINT ('-----------------------------------');
        PRINT ('');
        PRINT(CONCAT('Finalización de la carga de la capa Silver: ',CAST(@batch_end_time AS VARCHAR(50))));
        PRINT ('');
        PRINT ('>> Duracion Total de la Carga: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' segundos');
        PRINT ('');

    END TRY
    BEGIN CATCH

        PRINT ('==============================================================================');
        PRINT ('OCURRIO UN ERROR DURANTE LA CARGA DE LA CAPA SILVER');
        PRINT ('');
        PRINT ('Mensaje de Error: ' + ERROR_MESSAGE());
        PRINT ('Numero de Error: ' + CAST (ERROR_NUMBER() AS NVARCHAR));
        PRINT ('Estado de Error: ' + CAST (ERROR_STATE() AS NVARCHAR));
        PRINT ('==============================================================================');

    END CATCH

END;
GO  

