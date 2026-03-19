-- =============================================================================
-- DDL Script: Create Gold Tables (Star Schema)
-- =============================================================================
-- Script Purpose:
-- 	This script creates the final analytical tables in the 'gold' schema.
-- 	Designed for Business Intelligence (BI) and reporting.
-- =============================================================================

-- 1. Dimension: Customers/Accounts
DROP TABLE IF EXISTS gold.dim_accounts;
CREATE TABLE gold.dim_accounts (
    account_key SERIAL PRIMARY KEY,
    account_name VARCHAR(255),
    sector VARCHAR(255),
    year_established INT,
    annual_revenue DECIMAL(18, 2),
    parent_company VARCHAR(255),
    hq_location VARCHAR(255),
    is_saas_company BOOLEAN,
    valuation_usd DECIMAL(18, 2), -- From ERP if matched
    arr_usd DECIMAL(18, 2),       -- From ERP if matched
    employee_count INT
);

-- 2. Dimension: Products
DROP TABLE IF EXISTS gold.dim_products;
CREATE TABLE gold.dim_products (
    product_key SERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    series VARCHAR(255),
    base_price DECIMAL(10, 2)
);

-- 3. Dimension: Sales Team
DROP TABLE IF EXISTS gold.dim_sales_team;
CREATE TABLE gold.dim_sales_team (
    sales_agent_key SERIAL PRIMARY KEY,
    agent_name VARCHAR(255),
    manager_name VARCHAR(255),
    region VARCHAR(255)
);

-- 4. Fact: Sales Pipeline
DROP TABLE IF EXISTS gold.fact_sales_pipeline;
CREATE TABLE gold.fact_sales_pipeline (
    opportunity_id VARCHAR(255) PRIMARY KEY,
    account_key INT,
    product_key INT,
    sales_agent_key INT,
    deal_stage VARCHAR(50),
    engagement_date DATE,
    close_date DATE,
    close_value DECIMAL(18, 2),
    is_won BOOLEAN,
    sales_cycle_days INT
);
