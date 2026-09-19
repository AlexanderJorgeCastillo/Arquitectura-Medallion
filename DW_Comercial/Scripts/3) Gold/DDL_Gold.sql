/*
===============================================================================
Script DDL: Crear Vistas Gold
===============================================================================
*/


USE DataWarehouse;
GO


-- ==========================================
-- 1. Dimensión Clientes (gold.dim_clientes)
-- ==========================================


IF OBJECT_ID('gold.dim_clientes', 'V') IS NOT NULL DROP VIEW gold.dim_clientes;
GO
CREATE VIEW gold.dim_clientes AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY id_cliente) AS clave_cliente, -- Clave subrogada
    id_cliente,
    nombre_completo,    
    nombre,
    apellido,
    email,
    pais,
    genero,
    estado_civil
FROM silver.clientes;
GO


-- ==========================================
-- 2. Dimensión Productos (gold.dim_productos)
-- ==========================================


IF OBJECT_ID('gold.dim_productos', 'V') IS NOT NULL DROP VIEW gold.dim_productos;
GO
CREATE VIEW gold.dim_productos AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY id_producto) AS clave_producto, -- Clave subrogada
    id_producto,
    codigo              AS codigo_producto,
    nombre              AS nombre_producto,
    categoria,
    subcategoria,
    costo_fabricacion
FROM silver.productos;
GO


-- ==========================================
-- 3. Tabla de Hechos (gold.fact_ventas)
-- ==========================================


IF OBJECT_ID('gold.fact_ventas', 'V') IS NOT NULL DROP VIEW gold.fact_ventas;
GO
CREATE VIEW gold.fact_ventas AS
SELECT 
    v.id_transaccion,
    p.clave_producto,     
    c.clave_cliente,      
    v.fecha_venta,
    v.fecha_envio,
    v.cantidad,
    v.precio_unitario,
    v.monto_total,
    v.metodo_pago
FROM silver.ventas_detalle v
LEFT JOIN gold.dim_productos p ON v.id_producto = p.id_producto
LEFT JOIN gold.dim_clientes c ON v.id_cliente = c.id_cliente;
GO