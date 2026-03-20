USE superstore_pipeline;

-- SECCIÓN 1: TRANSACCIÓN EXPLÍCITA
-- Elimina registros con ventas negativas de forma segura.

START TRANSACTION;

DELETE FROM fct_orders
WHERE sales < 0;

-- Comprobar que no eliminamos más del 1 % de los datos
SET @eliminados = ROW_COUNT();
SET @total      = (SELECT COUNT(*) FROM fct_orders);

-- Si más del 1 % fue eliminado, revertir
SET @limite = FLOOR(@total * 0.01);

SELECT
    @eliminados AS filas_eliminadas,
    @total      AS filas_restantes,
    @limite     AS umbral_maximo,
    CASE WHEN @eliminados > @limite THEN '⚠ REVISAR — ROLLBACK recomendado'
         ELSE '✓ OK — COMMIT seguro'
    END AS estado;

-- Si el estado es OK:
COMMIT;
-- Si hubiera anomalías ejecutar en su lugar: ROLLBACK;


-- SECCIÓN 2: TRIGGER — impedir ventas negativas en INSERT
DROP TRIGGER IF EXISTS prevent_negative_sales;

CREATE TRIGGER prevent_negative_sales
BEFORE INSERT ON fct_orders
FOR EACH ROW
BEGIN
    IF NEW.sales < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: sales no puede ser negativo.';
    END IF;
END;



-- Prueba del trigger (debe devolver error):
-- INSERT INTO fct_orders (row_id, order_id, sales) VALUES ('TEST', 'ORD-TEST', -10);


-- ──────────────────────────────────────────────────────────
-- SECCIÓN 3: STORED PROCEDURE — informe de ventas por región
-- Uso: CALL sp_ventas_region('West');
--      CALL sp_ventas_region(NULL);  -- todas las regiones
-- ──────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS sp_ventas_region;

DELIMITER $$

CREATE PROCEDURE sp_ventas_region(IN p_region VARCHAR(50))
BEGIN
    SELECT
        c.region,
        COUNT(DISTINCT o.order_id)   AS num_pedidos,
        ROUND(SUM(o.sales),  2)      AS total_ventas,
        ROUND(SUM(o.profit), 2)      AS total_beneficio,
        ROUND(AVG(o.sales),  2)      AS ticket_medio
    FROM fct_orders o
    JOIN dim_customers c ON o.customer_id = c.customer_id
    WHERE (p_region IS NULL OR c.region = p_region)
    GROUP BY c.region
    ORDER BY total_ventas DESC;
END $$

DELIMITER ;

-- Pruebas:
CALL sp_ventas_region(NULL);
CALL sp_ventas_region('West');


-- ──────────────────────────────────────────────────────────
-- SECCIÓN 4: CTEs ANIDADAS — análisis de cohortes anuales
-- Clientes agrupados por año de primera compra y su LTV.
-- ──────────────────────────────────────────────────────────
WITH primera_compra AS (
    SELECT
        customer_id,
        YEAR(MIN(order_date)) AS anio_cohorte
    FROM fct_orders
    GROUP BY customer_id
),
ventas_cliente AS (
    SELECT
        o.customer_id,
        ROUND(SUM(o.sales), 2)  AS ltv,
        COUNT(DISTINCT o.order_id) AS num_pedidos
    FROM fct_orders o
    GROUP BY o.customer_id
),
cohorte_resumen AS (
    SELECT
        pc.anio_cohorte,
        COUNT(DISTINCT pc.customer_id)  AS clientes_cohorte,
        ROUND(AVG(vc.ltv), 2)           AS ltv_medio,
        ROUND(SUM(vc.ltv), 2)           AS ltv_total,
        ROUND(AVG(vc.num_pedidos), 1)   AS pedidos_medios
    FROM primera_compra pc
    JOIN ventas_cliente vc ON pc.customer_id = vc.customer_id
    GROUP BY pc.anio_cohorte
)
SELECT
    anio_cohorte,
    clientes_cohorte,
    ltv_medio,
    ltv_total,
    pedidos_medios,
    ROUND(ltv_total / SUM(ltv_total) OVER () * 100, 2) AS pct_ingresos_total
FROM cohorte_resumen
ORDER BY anio_cohorte;


-- ──────────────────────────────────────────────────────────
-- SECCIÓN 5: WINDOW FUNCTIONS — percentil de clientes
-- Clasificación de clientes en cuartiles de gasto.
-- ──────────────────────────────────────────────────────────
SELECT
    customer_id,
    ROUND(total_gastado, 2) AS total_gastado,
    NTILE(4) OVER (ORDER BY total_gastado DESC) AS cuartil,
    CASE NTILE(4) OVER (ORDER BY total_gastado DESC)
        WHEN 1 THEN 'VIP'
        WHEN 2 THEN 'Alto valor'
        WHEN 3 THEN 'Medio'
        WHEN 4 THEN 'Bajo valor'
    END AS segmento_valor
FROM vw_customer_summary
ORDER BY total_gastado DESC;
