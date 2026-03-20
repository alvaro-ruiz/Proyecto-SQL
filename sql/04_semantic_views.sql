USE superstore_pipeline;

-- vw_sales_by_region: ventas y beneficio por región
CREATE OR REPLACE VIEW vw_sales_by_region AS
SELECT
    c.region,
    COUNT(DISTINCT o.order_id)          AS num_pedidos,
    COUNT(DISTINCT o.customer_id)       AS num_clientes,
    ROUND(SUM(o.sales),  2)             AS total_ventas,
    ROUND(SUM(o.profit), 2)             AS total_beneficio,
    ROUND(SUM(o.profit) / NULLIF(SUM(o.sales), 0) * 100, 2) AS margen_pct
FROM fct_orders o
JOIN dim_customers c ON o.customer_id = c.customer_id
GROUP BY c.region;


-- vw_sales_by_category: ventas y beneficio por categoría
CREATE OR REPLACE VIEW vw_sales_by_category AS
SELECT
    p.category,
    p.sub_category,
    COUNT(DISTINCT o.order_id)    AS num_pedidos,
    ROUND(SUM(o.sales),  2)       AS total_ventas,
    ROUND(SUM(o.profit), 2)       AS total_beneficio,
    ROUND(SUM(o.profit) / NULLIF(SUM(o.sales), 0) * 100, 2) AS margen_pct
FROM fct_orders o
JOIN dim_products p ON o.product_id = p.product_id
GROUP BY p.category, p.sub_category;


-- vw_monthly_revenue: evolución mensual de ventas
CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS mes,
    YEAR(o.order_date)                 AS anio,
    MONTH(o.order_date)                AS mes_num,
    COUNT(DISTINCT o.order_id)         AS num_pedidos,
    ROUND(SUM(o.sales),  2)            AS total_ventas,
    ROUND(SUM(o.profit), 2)            AS total_beneficio
FROM fct_orders o
WHERE o.order_date IS NOT NULL
GROUP BY mes, anio, mes_num
ORDER BY anio, mes_num;


-- vw_customer_summary: resumen de actividad por cliente
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    c.region,
    COUNT(DISTINCT o.order_id)   AS num_pedidos,
    ROUND(SUM(o.sales),  2)      AS total_gastado,
    ROUND(AVG(o.sales),  2)      AS ticket_medio,
    ROUND(SUM(o.profit), 2)      AS beneficio_generado,
    MIN(o.order_date)            AS primera_compra,
    MAX(o.order_date)            AS ultima_compra
FROM fct_orders o
JOIN dim_customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.segment, c.region;

-- Verificación
SELECT * FROM vw_sales_by_region    ORDER BY total_ventas DESC;
SELECT * FROM vw_sales_by_category  ORDER BY total_ventas DESC;
SELECT * FROM vw_monthly_revenue    LIMIT 12;
SELECT * FROM vw_customer_summary   ORDER BY total_gastado DESC LIMIT 10;
