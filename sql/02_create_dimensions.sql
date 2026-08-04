-- ==========================================================
-- ChriLy Data Warehouse
-- Create Dimension Tables
-- ==========================================================

CREATE SCHEMA IF NOT EXISTS chrily;

-- ==========================================================
-- Customer Dimension
-- ==========================================================

CREATE TABLE IF NOT EXISTS chrily.dim_customer (

    customer_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id VARCHAR(50) NOT NULL UNIQUE,

    customer_unique_id VARCHAR(50) NOT NULL,

    customer_city VARCHAR(100) NOT NULL,

    customer_state VARCHAR(50) NOT NULL

);

-- ==========================================================
-- Seller Dimension
-- ==========================================================

CREATE TABLE IF NOT EXISTS chrily.dim_seller (

    seller_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    seller_id VARCHAR(50) NOT NULL UNIQUE,

    seller_city VARCHAR(100) NOT NULL,

    seller_state VARCHAR(50) NOT NULL

);

-- ==========================================================
-- Product Dimension
-- ==========================================================

CREATE TABLE IF NOT EXISTS chrily.dim_product (

    product_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    product_id VARCHAR(50) NOT NULL UNIQUE,

    product_category_name VARCHAR(100),

    product_name_lenght INTEGER,

    product_description_lenght INTEGER,

    product_photos_qty INTEGER,

    product_weight_g NUMERIC(10,2),

    product_length_cm NUMERIC(10,2),

    product_height_cm NUMERIC(10,2),

    product_width_cm NUMERIC(10,2),

    product_volume_cm3 NUMERIC(12,2)

);

-- ==========================================================
-- Date Dimension
-- ==========================================================

CREATE TABLE IF NOT EXISTS chrily.dim_date (

    date_key INTEGER PRIMARY KEY,

    full_date DATE UNIQUE,

    year INTEGER,

    quarter INTEGER,

    month INTEGER,

    month_name VARCHAR(20),

    day INTEGER,

    weekday VARCHAR(20),

    week INTEGER,

    is_weekend BOOLEAN

);