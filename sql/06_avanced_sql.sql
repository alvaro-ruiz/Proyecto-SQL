USE superstore_pipeline;

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date,'%Y-%m') AS month,
        SUM(sales) AS revenue
    FROM fct_orders
    GROUP BY month
)
SELECT * FROM monthly_sales;


START TRANSACTION;

DELETE FROM fct_orders
WHERE sales < 0;

COMMIT;


DELIMITER $$

CREATE TRIGGER prevent_negative_sales
BEFORE INSERT ON fct_orders
FOR EACH ROW
BEGIN
    IF NEW.sales < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sales cannot be negative';
    END IF;
END $$

DELIMITER ;