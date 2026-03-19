CREATE TABLE IF NOT EXISTS superstore_pipeline;

USE superstore_pipeline;


DROP TABLE IF EXISTS stg_superstore;
CREATE TABLE stg_superstore (
    row_id          VARCHAR(10),
    order_id        VARCHAR(20),
    order_date      VARCHAR(20),
    ship_date       VARCHAR(20),
    ship_mode       VARCHAR(50),
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    segment         VARCHAR(50),
    country         VARCHAR(50),
    city            VARCHAR(100),
    state           VARCHAR(50),
    postal_code     VARCHAR(20),
    region          VARCHAR(50),
    product_id      VARCHAR(30),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_name    VARCHAR(300),
    sales           VARCHAR(20),
    _loaded_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* Insertamos los datos del csv superstore, en mi caso lo realice con la interfaz de DBeaver*/

select * from stg_superstore;