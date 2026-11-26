-- Motor utilizado: SQL Server (T-SQL)
-- Pre-entrega 5: Consultas con JOINs para el proyecto — RetailPro
-- Base: Ventas_Tech_DB (creada en M3): categorias, clientes, productos, ventas.

USE Ventas_Tech_DB;
GO

-- ============================================================
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: una fila por venta con cliente, ciudad, producto y categoría,
-- como fuente principal para Power BI. Ciudad sirve para agrupar y
-- categoría para filtrar.
-- ============================================================
SELECT
    v.id_venta,
    v.fecha_venta,
    c.nombre                          AS cliente,
    c.ciudad,
    p.nombre_producto                 AS producto,
    cat.nombre_categoria              AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario    AS total_venta
FROM ventas v
INNER JOIN clientes   c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  p   ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;
-- Hallazgo: Computación concentra $4.950 de los $6.444 facturados (77%),
-- casi todo por la Laptop Pro 15. Por ciudad lideran Buenos Aires ($2.640) y Tucumán ($2.100).

-- ============================================================
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.
-- ============================================================
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
-- Hallazgo: 0 clientes sin compras; los 5 registrados compraron al menos una vez.
-- Para CRM no hay clientes inactivos que recuperar: el foco puede ir a fidelizar y captar nuevos.

-- ============================================================
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo sin movimiento para el área de producto.
-- ============================================================
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v        ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL;
-- Hallazgo: 0 productos sin ventas; los 6 del catálogo tuvieron movimiento en marzo.
-- Para producto no hay stock parado, aunque Audio y Almacenamiento facturan poco ($360 y $390).

-- ============================================================
-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: comparar la facturación de dos períodos de marzo 2024.
-- La columna canal no existe en la tabla: se crea como texto fijo en cada SELECT.
-- ============================================================
SELECT
    canal,
    COUNT(*)   AS cantidad_ventas,
    SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Semana 1 (1 al 10 mar)' AS canal
    FROM ventas
    WHERE fecha_venta < '2024-03-11'
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Semana 2 (11 al 15 mar)' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-11'
) AS consolidado
GROUP BY canal
ORDER BY canal;
-- Hallazgo: con 5 ventas cada período, la primera semana facturó $3.620 y la segunda $2.824
-- (22% menos). La diferencia viene de la venta de 2 Laptops del 5 de marzo.
