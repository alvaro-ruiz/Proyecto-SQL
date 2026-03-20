USE superstore_pipeline;

-- Q1. ¿Cuáles son las ventas y el margen por región?
SELECT
    region,
    total_ventas,
    total_beneficio,
    margen_pct,
    RANK() OVER (ORDER BY total_ventas DESC) AS ranking_ventas
FROM vw_sales_by_region
ORDER BY total_ventas DESC;


-- Q2. ¿Cuáles son los 10 clientes con mayor gasto total?
SELECT
    customer_id,
    customer_name,
    segment,
    region,
    total_gastado,
    num_pedidos,
    ticket_medio,
    DENSE_RANK() OVER (ORDER BY total_gastado DESC) AS ranking
FROM vw_customer_summary
ORDER BY total_gastado DESC
LIMIT 10;

-- Q3. ¿Cómo evolucionan las ventas mes a mes?
--     Incluye variación porcentual respecto al mes anterior.
SELECT
    mes,
    total_ventas,
    LAG(total_ventas) OVER (ORDER BY mes) AS ventas_mes_anterior,
    ROUND(
        (total_ventas - LAG(total_ventas) OVER (ORDER BY mes))
        / NULLIF(LAG(total_ventas) OVER (ORDER BY mes), 0) * 100
    , 2) AS variacion_pct
FROM vw_monthly_revenue
ORDER BY mes;



-- Q4. ¿Qué categoría y subcategoría genera más beneficio?
SELECT
    category,
    sub_category,
    total_ventas,
    total_beneficio,
    margen_pct,
    RANK() OVER (PARTITION BY category ORDER BY total_beneficio DESC) AS ranking_en_categoria
FROM vw_sales_by_category
ORDER BY total_beneficio DESC;


-- Q5. ¿Cuál es el tiempo medio de envío por modalidad?
--     (días entre pedido y envío)
SELECT
    ship_mode,
    COUNT(*)                                    AS num_pedidos,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 1) AS dias_envio_medio,
    MIN(DATEDIFF(ship_date, order_date))        AS dias_minimo,
    MAX(DATEDIFF(ship_date, order_date))        AS dias_maximo
FROM fct_orders
WHERE ship_date IS NOT NULL AND order_date IS NOT NULL
GROUP BY ship_mode
ORDER BY dias_envio_medio;


-- Q6. ¿Qué segmento de cliente genera más ingresos?
SELECT
    c.segment,
    COUNT(DISTINCT o.customer_id)    AS num_clientes,
    COUNT(DISTINCT o.order_id)       AS num_pedidos,
    ROUND(SUM(o.sales), 2)           AS total_ventas,
    ROUND(SUM(o.profit), 2)          AS total_beneficio,
    ROUND(AVG(o.sales), 2)           AS ticket_medio
FROM fct_orders o
JOIN dim_customers c ON o.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_ventas DESC;


-- Q7. Top 5 productos más vendidos por categoría
WITH ventas_producto AS (
    SELECT
        p.category,
        p.product_name,
        ROUND(SUM(o.sales),  2) AS total_ventas,
        ROUND(SUM(o.profit), 2) AS total_beneficio,
        DENSE_RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(o.sales) DESC
        ) AS ranking
    FROM fct_orders o
    JOIN dim_products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT *
FROM ventas_producto
WHERE ranking <= 5
ORDER BY category, ranking;


-- Q8. ¿Existen clientes que compraron en varias regiones?
--     (posibles registros duplicados o clientes móviles)
SELECT
    o.customer_id,
    c.customer_name,
    COUNT(DISTINCT c.region) AS num_regiones,
    GROUP_CONCAT(DISTINCT c.region ORDER BY c.region SEPARATOR ', ') AS regiones
FROM fct_orders o
JOIN dim_customers c ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name
HAVING num_regiones > 1
ORDER BY num_regiones DESC;


-- Q9. Ventas acumuladas por región (running total mensual)
WITH ventas_region_mes AS (
    SELECT
        c.region,
        DATE_FORMAT(o.order_date, '%Y-%m') AS mes,
        SUM(o.sales) AS ventas_mes
    FROM fct_orders o
    JOIN dim_customers c ON o.customer_id = c.customer_id
    GROUP BY c.region, mes
)
SELECT
    region,
    mes,
    ROUND(ventas_mes, 2) AS ventas_mes,
    ROUND(SUM(ventas_mes) OVER (
        PARTITION BY region
        ORDER BY mes
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS ventas_acumuladas
FROM ventas_region_mes
ORDER BY region, mes;


-- Q10. ¿Qué porcentaje de pedidos aplica descuento?
--      Distribución del descuento aplicado.
SELECT
    CASE
        WHEN discount = 0.00 THEN 'Sin descuento'
        WHEN discount = 0.05 THEN 'Descuento 5%'
        WHEN discount = 0.10 THEN 'Descuento 10%'
        ELSE 'Otro'
    END                                         AS tramo_descuento,
    COUNT(*)                                    AS num_lineas,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_total,
    ROUND(SUM(sales), 2)                        AS ventas_tramo,
    ROUND(SUM(profit), 2)                       AS beneficio_tramo
FROM fct_orders
GROUP BY tramo_descuento
ORDER BY num_lineas DESC;
