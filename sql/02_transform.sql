USE superstore_pipeline;

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
WHERE customer_id IS NOT NULL;

DROP TABLE IF EXISTS dim_products;

CREATE TABLE dim_products AS
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category
FROM stg_superstore
WHERE product_id IS NOT NULL;


DROP TABLE IF EXISTS fct_orders;

CREATE TABLE fct_orders AS
SELECT
    row_id,
    order_id,
    STR_TO_DATE(order_date, '%d/%m/%Y') AS order_date,
    STR_TO_DATE(ship_date, '%d/%m/%Y') AS ship_date,
    ship_mode,
    customer_id,
    product_id,
    sales,
    1 AS quantity,
    CASE 
        WHEN sales > 500 THEN 0.10
        WHEN sales > 100 THEN 0.05
        ELSE 0
    END AS discount,
    sales * (
        1 - CASE 
                WHEN sales > 500 THEN 0.10
                WHEN sales > 100 THEN 0.05
                ELSE 0
            END
    ) * 0.2 AS profit
FROM stg_superstore;

select * from dim_customers;
select * from dim_products;
select * from fct_orders;
