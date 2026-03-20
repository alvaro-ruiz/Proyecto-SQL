USE superstore_pipeline;

-- dim_customers: dimensión de clientes
-- Deduplicada por customer_id.
DROP TABLE IF EXISTS dim_customers;

CREATE TABLE dim_customers AS
SELECT DISTINCT
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region
FROM stg_superstore
WHERE customer_id IS NOT NULL
  AND TRIM(customer_id) <> '';

-- dim_products: dimensión de productos
-- Deduplicada por product_id.
DROP TABLE IF EXISTS dim_products;

CREATE TABLE dim_products AS
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category
FROM stg_superstore
WHERE product_id IS NOT NULL
  AND TRIM(product_id) <> '';

-- fct_orders: tabla de pedidos
-- - Parseo de fechas con STR_TO_DATE
-- - sales convertida a DECIMAL
-- - Descuento basado en reglas de negocio
-- - Margen de beneficio estimado al 20 %
DROP TABLE IF EXISTS fct_orders;

CREATE TABLE fct_orders AS
SELECT
    row_id,
    order_id,
    STR_TO_DATE(order_date, '%d/%m/%Y')  AS order_date,
    STR_TO_DATE(ship_date,  '%d/%m/%Y')  AS ship_date,
    ship_mode,
    customer_id,
    product_id,
    CAST(REPLACE(sales, ',', '.') AS DECIMAL(12,2)) AS sales,
    1 AS quantity,
    CASE
        WHEN CAST(REPLACE(sales, ',', '.') AS DECIMAL(12,2)) > 500 THEN 0.10
        WHEN CAST(REPLACE(sales, ',', '.') AS DECIMAL(12,2)) > 100 THEN 0.05
        ELSE 0.00
    END AS discount,
    CAST(REPLACE(sales, ',', '.') AS DECIMAL(12,2))
        * (1 - CASE
                   WHEN CAST(REPLACE(sales, ',', '.') AS DECIMAL(12,2)) > 500 THEN 0.10
                   WHEN CAST(REPLACE(sales, ',', '.') AS DECIMAL(12,2)) > 100 THEN 0.05
                   ELSE 0.00
               END)
        * 0.20 AS profit
FROM stg_superstore
WHERE row_id IS NOT NULL;

-- Verificaciones rápidas
SELECT COUNT(*) AS filas_fct    FROM fct_orders;
SELECT COUNT(*) AS clientes_dim FROM dim_customers;
SELECT COUNT(*) AS productos_dim FROM dim_products;
