# Cárnicos POS

Prototipo de punto de venta para una carnicería. El login está separado del módulo interno.

## Uso

1. Abre `index.html` en el navegador.
2. Ingresa con `admin` / `admin123`.
3. Agrega productos al carrito y finaliza una venta.

El prototipo guarda inventario en `localStorage`. La autenticación es demostrativa y no debe usarse en producción.

## Archivos

- `index.html`: interfaz independiente de acceso.
- `app.html`: catálogo, inventario, carrito y ventas.
- `schema.sql`: base MySQL, función escalar, validaciones y auditoría.

## MySQL

Ejecuta `schema.sql` completo en MySQL Workbench. Crea `carnicos_pos`, sus tablas, `fn_sale_total` y cuatro triggers: validación antes de insertar/actualizar y auditoría después de actualizar/eliminar productos.
