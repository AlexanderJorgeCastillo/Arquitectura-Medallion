# 📊 Data Warehouse Comercial: Arquitectura Medallion

Bienvenido a la documentación del **Data Warehouse Comercial** desarrollado en **SQL Server**. Este proyecto implementa un flujo automatizado ETL (Extracción, Transformación y Carga) utilizando una arquitectura **Medallion (Bronze ➔ Silver ➔ Gold)**. 

El objetivo es tomar una fuente de datos transaccional plana y desnormalizada (CSV), limpiarla y estructurarla en un Modelo Dimensional listo para el análisis y la toma de decisiones en Power BI / Tableau.

---

## 🎯 1. Justificación y Necesidad de Negocio

### 1.1. Contexto y Problemática Actual
La empresa generaba sus reportes de ventas directamente desde un archivo plano (`ventas_2025_2026.csv`) que contenía transacciones, datos del cliente y detalles del producto mezclados en una sola "sábana" de más de 10,000 registros. Esto generaba los siguientes problemas:
* **Falta de Integridad Relacional:** Nombres de clientes y detalles de productos repetidos miles de veces.
* **Datos Sucios y Errores:** Fechas de ventas inválidas (ej. `0`), cantidades negativas y montos totales que no cuadraban matemáticamente.
* **Inconsistencias de Formato:** Paises con múltiples nomenclaturas (US, USA, Estados Unidos).
* **Bajo Rendimiento:** Dificultad para segmentar rápidamente clientes o productos en herramientas de BI.

### 1.2. Propósito del Proyecto
Construir un almacén de datos estructurado que centralice la información, audite la limpieza de los datos (mediante marcas de tiempo en la capa Silver) y exponga un **Esquema Estrella** eficiente para responder preguntas críticas del negocio.

---

## ⚙️ 2. Arquitectura del Flujo de Datos

El proyecto sigue una estrategia de capas progresivas para garantizar la calidad del dato:

1. **🥉 Capa Bronze (Raw / Ingesta):** 
   * Extrae los datos exactos del archivo CSV original usando `BULK INSERT`.
   * **Tabla:** `bronze.ventas` (20 columnas, todo en formato texto para evitar bloqueos por errores de origen).

2. **🥈 Capa Silver (Limpieza y Normalización):** 
   * Se lee de Bronze, se castean los tipos de datos (Fechas, Enteros, Flotantes) y se **normaliza** la información en tres tablas independientes para eliminar redundancias.
   * **Transformaciones:** Filtrado de fechas inválidas (`!= '0'`), estandarización de países/géneros, recálculo de montos nulos y creación de la columna `nombre_completo`. Se añade fecha de auditoría (`dwh_fecha_carga`).
   * **Tablas:** `silver.clientes`, `silver.productos`, `silver.ventas_detalle`.

3. **🥇 Capa Gold (Modelo de Negocio):** 
   * Consolidación final mediante Vistas (Views) formando un Modelo Dimensional. Se asignan **Claves Subrogadas** para proteger el modelo de cambios en los sistemas de origen.
   * **Vistas:** `gold.dim_clientes`, `gold.dim_productos`, `gold.fact_ventas`.

---

## 📐 3. Diagrama del Modelo de Datos Final (Esquema Estrella)

La capa Gold está diseñada para responder al instante consultas analíticas:

```mermaid
erDiagram
    gold_dim_clientes ||--o{ gold_fact_ventas : "realiza (1:N)"
    gold_dim_productos ||--o{ gold_fact_ventas : "es vendido en (1:N)"

    gold_dim_clientes {
        int clave_cliente PK "Clave Subrogada"
        nvarchar id_cliente "ID Origen"
        nvarchar nombre_completo "Apellidos, Nombres"
        nvarchar email "Correo analítico"
        nvarchar pais "Estandarizado"
        nvarchar genero "Masculino/Femenino"
        nvarchar estado_civil "Soltero/Casado"
    }

    gold_dim_productos {
        int clave_producto PK "Clave Subrogada"
        nvarchar id_producto "ID Origen"
        nvarchar codigo_producto "SKU"
        nvarchar nombre_producto "Descripción"
        nvarchar categoria "Ej: Electrónica"
        nvarchar subcategoria "Ej: Smartphones"
        float costo_fabricacion "Costo Unitario"
    }

    gold_fact_ventas {
        nvarchar id_transaccion "Ticket"
        int clave_producto FK "FK a dim_productos"
        int clave_cliente FK "FK a dim_clientes"
        date fecha_venta "Fecha de la transacción"
        date fecha_envio "Puede ser Nula (En proceso)"
        int cantidad "Unidades vendidas"
        float precio_unitario "Precio unitario"
        float monto_total "Monto final validado"
        nvarchar metodo_pago "Tarjeta, Efectivo, etc."
    }
