/*
===============================================================================
Script DDL: Crear Tablas en Capa Silver
===============================================================================
*/


USE DataWarehouse;
GO


IF OBJECT_ID('silver.clientes', 'U') IS NOT NULL DROP TABLE silver.clientes;
GO
CREATE TABLE silver.clientes (
    id_cliente          NVARCHAR(50),
    nombre              NVARCHAR(100),
    apellido            NVARCHAR(100),
    nombre_completo     NVARCHAR(200),
    email               NVARCHAR(100),
    pais                NVARCHAR(50),
    genero              NVARCHAR(50),
    estado_civil        NVARCHAR(50),
    dwh_fecha_carga     DATETIME2 DEFAULT GETDATE()
);
GO


IF OBJECT_ID('silver.productos', 'U') IS NOT NULL DROP TABLE silver.productos;
GO
CREATE TABLE silver.productos (
    id_producto         NVARCHAR(50),
    codigo              NVARCHAR(50),
    nombre              NVARCHAR(100),
    categoria           NVARCHAR(50),
    subcategoria        NVARCHAR(50),
    costo_fabricacion   FLOAT,
    dwh_fecha_carga     DATETIME2 DEFAULT GETDATE()
);
GO


IF OBJECT_ID('silver.ventas_detalle', 'U') IS NOT NULL DROP TABLE silver.ventas_detalle;
GO
CREATE TABLE silver.ventas_detalle (
    id_transaccion      NVARCHAR(50),
    fecha_venta         DATE,
    fecha_envio         DATE,
    id_cliente          NVARCHAR(50),
    id_producto         NVARCHAR(50),
    cantidad            INT,
    precio_unitario     FLOAT,
    monto_total         FLOAT,
    metodo_pago         NVARCHAR(50),
    dwh_fecha_carga     DATETIME2 DEFAULT GETDATE()
);
GO