USE superstore_pipeline;

-- Ventas por region
select * from vw_sales_by_region;

-- Top clientes
SELECT
    customer_id,
    SUM(sales) AS total_spent
FROM fct_orders
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Ventas mensuales
SELECT
    DATE_FORMAT(order_date,'%Y-%m') AS month,
    SUM(sales) AS revenue
FROM fct_orders
GROUP BY month
ORDER BY month;

-- Ranking clientes 
SELECT
    customer_id,
    SUM(sales) AS total_sales,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS ranking
FROM fct_orders
GROUP BY customer_id;

-- Profit por categorias
SELECT
    p.category,
    SUM(o.profit) AS total_profit
FROM fct_orders o
JOIN dim_products p ON o.product_id = p.product_id
GROUP BY p.category;

-- Descuento medio
SELECT AVG(discount) FROM fct_orders;