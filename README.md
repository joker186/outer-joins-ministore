## Pregunta 1: ¿Por qué usaste LEFT JOIN para la Consulta 1 y no INNER JOIN? ¿Qué se perdería si usaras INNER JOIN?

Usé `LEFT JOIN` porque la tabla de la izquierda (`productos`) debe conservar
**todas** sus filas, incluso cuando no haya una venta asociada. El `INNER JOIN`
solo devuelve filas donde hay coincidencia en ambas tablas, por lo que
**descartaría silenciosamente** los productos que nunca se vendieron.

Concretamente, si usáramos `INNER JOIN` sobre este dataset perderíamos:

- **Producto 108** (Hub USB-C 7p) — no aparece en `ventas`.
- **Producto 109** (Parlante Bluetooth) — no aparece en `ventas`.

El `INNER JOIN` devolvería 9 filas (las ventas 1–9 con sus productos), pero
ocultaría la información crítica de que existen 2 productos sin movimiento de
ventas. El `LEFT JOIN` las muestra con `NULL` en las columnas de `ventas`, lo
que nos permite identificar y actuar sobre ellas (por ejemplo, decidir si se
eliminan del catálogo o si se necesita promocionarlos).

## Pregunta 2: ¿Por qué usaste RIGHT JOIN para la Consulta 2? ¿Qué tabla está a la izquierda y cuál a la derecha en tu consulta?

Usé `RIGHT JOIN` porque la tabla de la derecha (`ventas`) debe conservar
**todas** sus filas, incluso cuando el `producto_id` no tenga coincidencia en
el catálogo `productos`.

En mi consulta:

- **Tabla izquierda (FROM):** `productos`
- **Tabla derecha (RIGHT JOIN):** `ventas`

El `LEFT JOIN` (producto → venta) no resolvería el problema aquí, porque
existen ventas sin producto (venta 10 → producto_id 999). Si invirtiéramos
las tablas y usáramos `LEFT JOIN` con `ventas` a la izquierda, obtendríamos el
mismo resultado, pero el enunciado nos pide específicamente usar `RIGHT JOIN`
para mantener `productos` como tabla izquierda.

El `RIGHT JOIN` devuelve también las 10 ventas, pero la venta 10 aparece con
`NULL` en todas las columnas de `productos`, identificando así el registro
huérfano: **`producto_id = 999` no existe en el catálogo**, lo que indica un
posible error de carga de datos o un producto eliminado que aún se referencia
en transacciones.

## Pregunta 3: ¿Qué representan los valores NULL en cada resultado? Explicá con un ejemplo concreto de los datos.

Los valores `NULL` son la **señal de alerta** que buscamos: indican la ausencia
de coincidencia entre las tablas.

### Consulta 1 (LEFT JOIN) — `NULL` en las columnas de `ventas`

Un `NULL` en `venta_id` significa que **ese producto nunca fue vendido**. Por
ejemplo, el producto **108 (Hub USB-C 7p)** aparece en el resultado con
`NULL` en `venta_id`, `cliente_id`, `cantidad` y `fecha_venta`, porque no
existe ninguna fila en `ventas` con `producto_id = 108`. Lo mismo ocurre con el
producto **109 (Parlante Bluetooth)**.

### Consulta 2 (RIGHT JOIN) — `NULL` en las columnas de `productos`

Un `NULL` en `nombre`, `categoria` o `precio` significa que **esa venta
referencia un producto que no existe en el catálogo**. Por ejemplo, la
**venta 10** aparece con `NULL` en todas las columnas de `productos` porque
`producto_id = 999` no está presente en la tabla `productos`. Esto indica un
posible error de carga: una transacción registrada para un producto que fue
borrado, nunca existió, o se ingresó un ID incorrecto.

### Consulta 3 (FULL OUTER JOIN) — `NULL` en ambas direcciones

Aquí aparecen `NULL` tanto para productos sin ventas (108, 109) como para
ventas sin producto (venta 10), dando una vista de auditoría completa.

## Pregunta 4: ¿Cuándo usarías FULL OUTER JOIN en un caso real de negocio?

El `FULL OUTER JOIN` es la herramienta de auditoría por excelencia. Algunos casos
reales:

1. **Verificación de migraciones de datos.** Cuando migrás una base de datos
   antigua a una nueva, un `FULL OUTER JOIN` entre la tabla vieja y la nueva
   revela registros que se perdieron en el proceso (presentes en la vieja pero
   no en la nueva) o registros nuevos sin origen en la antigua.

2. **Conciliación entre sistemas.** Si el sistema de ventas y el sistema de
   inventario no están perfectamente sincronizados, un `FULL OUTER JOIN` sobre
   el producto/venta común identifica qué ventas no están en inventario (stock
   faltante) y qué productos de inventario no tienen ventas asociadas.

3. **Auditoría de calidad de datos.** Como en este ejercicio, detectar
   inconsistentes (ventas huérfanas) y incompletos (productos sin ventas) de
   un solo vistazo, antes de construir reportes que asuman datos limpios.

4. **Comparación de snapshots.** Comparar el estado del inventario entre dos
   períodos: productos que desaparecieron, productos nuevos, y productos que
   se mantienen (pero pueden haber cambiado de precio o categoría).
