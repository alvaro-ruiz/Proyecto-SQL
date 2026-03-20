USE superstore_pipeline;

-- QC-1. Nulos en campos clave de staging
SELECT
    SUM(CASE WHEN row_id       IS NULL OR TRIM(row_id)       = '' THEN 1 ELSE 0 END) AS nulos_row_id,
    SUM(CASE WHEN order_id     IS NULL OR TRIM(order_id)     = '' THEN 1 ELSE 0 END) AS nulos_order_id,
    SUM(CASE WHEN customer_id  IS NULL OR TRIM(customer_id)  = '' THEN 1 ELSE 0 END) AS nulos_customer_id,
    SUM(CASE WHEN product_id   IS NULL OR TRIM(product_id)   = '' THEN 1 ELSE 0 END) AS nulos_product_id,
    SUM(CASE WHEN sales        IS NULL OR TRIM(sales)        = '' THEN 1 ELSE 0 END) AS nulos_sales
FROM stg_superstore;

-- QC-2. Duplicados en row_id (debe ser clave única)
SELECT
    row_id,
    COUNT(*) AS veces
FROM stg_superstore
GROUP BY row_id
HAVING veces > 1
LIMIT 20;

-- QC-3. Ventas negativas o cero en fct_orders
SELECT COUNT(*) AS ventas_invalidas
FROM fct_orders
WHERE sales <= 0;

-- QC-4. Fechas de envío anteriores al pedido
SELECT COUNT(*) AS fechas_invertidas
FROM fct_orders
WHERE ship_date < order_date;

-- QC-5. Pedidos en fct sin cliente en dim_customers (huérfanos)
SELECT COUNT(*) AS pedidos_sin_cliente
FROM fct_orders o
LEFT JOIN dim_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- QC-6. Pedidos en fct sin producto en dim_products (huérfanos)
SELECT COUNT(*) AS pedidos_sin_producto
FROM fct_orders o
LEFT JOIN dim_products p ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

-- QC-7. Formato de fechas en staging (no parseables)
SELECT COUNT(*) AS fechas_no_parseables
FROM stg_superstore
WHERE STR_TO_DATE(order_date, '%d/%m/%Y') IS NULL
   OR STR_TO_DATE(ship_date,  '%d/%m/%Y') IS NULL;

-- QC-8. Resumen global de la carga
SELECT
    (SELECT COUNT(*) FROM stg_superstore)  AS filas_staging,
    (SELECT COUNT(*) FROM fct_orders)      AS filas_fct,
    (SELECT COUNT(*) FROM dim_customers)   AS clientes_dim,
    (SELECT COUNT(*) FROM dim_products)    AS productos_dim,
    (SELECT COUNT(DISTINCT order_id) FROM fct_orders) AS pedidos_unicos;
