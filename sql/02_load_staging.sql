USE superstore_pipeline;

-- OPCIÓN A: LOAD DATA INFILE (ajustar la ruta al CSV)
-- Requiere permiso FILE y que el archivo esté en secure_file_priv

/*LOAD DATA INFILE 'sql-superstore-pipeline/data/superstore.csv'
INTO TABLE stg_superstore
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(row_id, order_id, order_date, ship_date, ship_mode,
 customer_id, customer_name, segment, country, city,
 state, postal_code, region, product_id, category,
 sub_category, product_name, sales);*/


-- OPCIÓN B: Importación manual
-- Usar el asistente de importación de DBeaver o MySQL Workbench:
--   1. Clic derecho sobre stg_superstore → Import Data
--   2. Seleccionar superstore.csv
--   3. Separador: coma, encoding: UTF-8
--   4. Omitir primera fila (encabezados)

-- Verificación post-carga
SELECT COUNT(*)         AS total_filas    FROM stg_superstore;
SELECT COUNT(DISTINCT order_id) AS pedidos_unicos FROM stg_superstore;
SELECT MIN(order_date)  AS fecha_min,
       MAX(order_date)  AS fecha_max
FROM stg_superstore;
