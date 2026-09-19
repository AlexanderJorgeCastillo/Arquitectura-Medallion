/*
===============================================================================
Script DDL: Crear Tabla en Capa Bronze
===============================================================================
*/


USE DataWarehouse;
GO


IF OBJECT_ID('bronze.ventas', 'U') IS NOT NULL
    DROP TABLE bronze.ventas;
GO


CREATE TABLE bronze.ventas (
    id_transaccion          NVARCHAR(50),
    fecha_venta             NVARCHAR(50),
    fecha_envio             NVARCHAR(50),
    id_cliente              NVARCHAR(50),
    nombre_cliente          NVARCHAR(100),
    apellido_cliente        NVARCHAR(100),
    email_cliente           NVARCHAR(100),
    pais_cliente            NVARCHAR(50),
    genero_cliente          NVARCHAR(50),
    estado_civil_cliente    NVARCHAR(50),
    id_producto             NVARCHAR(50),
    codigo_producto         NVARCHAR(50),
    nombre_producto         NVARCHAR(100),
    categoria_producto      NVARCHAR(50),
    subcategoria_producto   NVARCHAR(50),
    costo_fabricacion       NVARCHAR(50),
    cantidad                NVARCHAR(50),
    precio_unitario         NVARCHAR(50),
    monto_total             NVARCHAR(50),
    metodo_pago             NVARCHAR(50)
);
GO