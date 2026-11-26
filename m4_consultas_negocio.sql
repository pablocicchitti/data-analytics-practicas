-- Motor utilizado: SQL Server (T-SQL)
-- Pre-entrega 4: Consultas SQL de negocio — RetailPro
-- Base: Ventas_Tech_DB (creada en M3). Se trabaja solo sobre la tabla ventas.

USE Ventas_Tech_DB;
GO

-- ============================================================
-- Consulta 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
-- Con los datos de M3 todas las ventas son de marzo 2024: una sola fila.
-- ============================================================
SELECT
    YEAR(fecha_venta)                                      AS anio,
    MONTH(fecha_venta)                                     AS mes,
    SUM(cantidad * precio_unitario)                        AS total_facturado,
    COUNT(*)                                               AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) / COUNT(*)             AS ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;

-- ============================================================
-- Consulta 2 — Ranking de productos
-- Top 5 de productos por total facturado, con unidades vendidas.
-- ============================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad)                    AS unidades_vendidas,
    SUM(cantidad * precio_unitario)  AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- ============================================================
-- Consulta 3 — Clientes recurrentes
-- Clientes con más de un pedido, cantidad de pedidos y total gastado.
-- ============================================================
SELECT
    id_cliente,
    COUNT(*)                         AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)  AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- ============================================================
-- Consulta 4 — Productos por encima / por debajo del promedio
-- Paso 1 (WITH): total facturado por producto.
-- Paso 2: se compara cada total contra el promedio de esos totales
-- (promedio por producto, no promedio de las filas de ventas).
-- ============================================================
WITH ventas_por_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM ventas_por_producto)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM ventas_por_producto
ORDER BY total_facturado DESC;

-- ============================================================
-- Hallazgos
-- 1. Marzo 2024 facturó $6.444 en 10 pedidos, con un ticket promedio
--    de $644,40. Con un solo mes de datos todavía no se puede ver tendencia.
-- 2. El producto 1 (Laptop) concentra $3.600, el 56% de la facturación,
--    con solo 3 unidades vendidas. El producto 2 (Mouse) es el que más
--    unidades vende (13) y uno de los que menos factura ($364).
-- 3. Los 5 clientes compraron 2 veces cada uno: todos son recurrentes.
--    El cliente 1 es el que más gastó ($2.640) y el 4 el que menos ($510).
--    Solo 2 de los 6 productos (1 y 3) quedan por encima del promedio
--    por producto ($1.074).
-- ============================================================
