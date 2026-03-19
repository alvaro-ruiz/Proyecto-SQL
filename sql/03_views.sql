USE superstore_pipeline;

CREATE OR REPLACE VIEW vw_sales_by_region AS
SELECT
    c.region,
    SUM(o.sales) AS total_sales,
    SUM(o.profit) AS total_profit
FROM fct_orders o
JOIN dim_customers c
ON o.customer_id = c.customer_id
GROUP BY c.region;

CREATE OR REPLACE VIEW vw_sales_by_category AS
SELECT
    p.category,
    SUM(o.sales) AS total_sales,
    SUM(o.profit) AS total_profit
FROM fct_orders o
JOIN dim_products p
ON o.product_id = p.product_id
GROUP BY p.category;

select * from vw_sales_by_region;
select * from vw_sales_by_category;
