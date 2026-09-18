-- ══════════════════════════════════════════
-- MiniStore — Soluciones con Outer JOINs
-- Autor: Felipe Cardona
-- Fecha: 18/9/2026
-- ══════════════════════════════════════════

-- ── CONSULTA 1: LEFT JOIN ─────────────────
-- Pregunta de negocio: ¿Qué productos del catálogo nunca fueron vendidos?
-- Mostrá todos los productos y sus ventas asociadas.
-- Los productos sin ventas aparecerán con NULL en las columnas de ventas.

SELECT 
    p.producto_id,
    p.nombre,
    v.venta_id,
    v.fecha_venta,
    v.cantidad
FROM productos p
LEFT JOIN ventas v 
    ON p.producto_id = v.producto_id
    WHERE v.venta_id IS NULL;

-- ── CONSULTA 2: RIGHT JOIN ────────────────
-- Pregunta de negocio: ¿Existen ventas registradas con productos
-- que no figuran en nuestro catálogo? (posible error de carga de datos)
-- Los registros huérfanos aparecerán con NULL en las columnas de productos.

SELECT 
    v.venta_id,
    v.producto_id,
    v.fecha_venta,
    v.cantidad,
    p.nombre,
    p.categoria
FROM productos p
RIGHT JOIN ventas v 
    ON p.producto_id = v.producto_id;

-- ── CONSULTA 3: FULL OUTER JOIN ───────────
-- Pregunta de negocio: Vista completa de auditoría que muestre
-- todos los productos y todas las ventas sin perder ninguna fila,
-- identificando tanto productos sin ventas como ventas sin producto.

SELECT 
    p.producto_id AS prod_id_catalogo,
    p.nombre,
    v.venta_id,
    v.producto_id AS prod_id_venta,
    v.cantidad
FROM productos p
FULL OUTER JOIN ventas v 
    ON p.producto_id = v.producto_id;
