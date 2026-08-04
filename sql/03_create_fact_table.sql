-- ==========================================================
-- ChriLy Data Warehouse
-- Fact Table
-- Grain:
-- One row = One Order Item
-- ==========================================================

CREATE TABLE IF NOT EXISTS chrily.fact_orders (

    fact_order_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    ----------------------------------------------------------
    -- Business Keys
    ----------------------------------------------------------

    order_id VARCHAR(50) NOT NULL,

    order_item_id INTEGER NOT NULL,

    ----------------------------------------------------------
    -- Dimension Keys
    ----------------------------------------------------------

    customer_key INTEGER NOT NULL,

    seller_key INTEGER NOT NULL,

    product_key INTEGER NOT NULL,

    date_key INTEGER NOT NULL,

    ----------------------------------------------------------
    -- Measures
    ----------------------------------------------------------

    price NUMERIC(12,2) NOT NULL,

    freight_value NUMERIC(12,2) NOT NULL,

    payment_value_allocated NUMERIC(12,2),

    shipping_time_days INTEGER,

    delivery_time_days INTEGER,

    delivery_delay_days INTEGER,

    ----------------------------------------------------------
    -- Payment Attributes
    ----------------------------------------------------------

    payment_type VARCHAR(30),

    payment_installments INTEGER,

    payment_installments_bucket VARCHAR(30),

    cod_flag BOOLEAN,

    ----------------------------------------------------------
    -- Review Attributes
    ----------------------------------------------------------

    review_score INTEGER,

    review_sentiment VARCHAR(20),

    would_recommend BOOLEAN,

    ----------------------------------------------------------
    -- Order Attributes
    ----------------------------------------------------------

    delivery_status VARCHAR(20),

    holiday VARCHAR(100),

    is_holiday BOOLEAN,

    is_ramadan BOOLEAN,

    is_weekend BOOLEAN,

    ----------------------------------------------------------
    -- Foreign Keys
    ----------------------------------------------------------

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_key)
        REFERENCES chrily.dim_customer(customer_key),

    CONSTRAINT fk_seller
        FOREIGN KEY (seller_key)
        REFERENCES chrily.dim_seller(seller_key),

    CONSTRAINT fk_product
        FOREIGN KEY (product_key)
        REFERENCES chrily.dim_product(product_key),

    CONSTRAINT fk_date
        FOREIGN KEY (date_key)
        REFERENCES chrily.dim_date(date_key)

);