/*
=============================================================================
DDL Script: Create Bronze Tables
=============================================================================
Script Purpose:
	This script creates tables in the 'bronze' schema, dropping existing tables 
	if they already exist.
	Run this script to re-define the DDL structure of 'bronze' tables.
=============================================================================
*/

DROP TABLE IF EXISTS bronze.crm_accounts;
CREATE TABLE bronze.crm_accounts (
    account VARCHAR(255) PRIMARY KEY, 
    sector VARCHAR(255), 
    year_estab INT,
    revenue DECIMAL(18, 2),
    employees INT,
    office_loca VARCHAR(255),
    subsidiary_parent VARCHAR(255)
);

--------------------------------------------
DROP TABLE IF EXISTS bronze.crm_products;
CREATE TABLE bronze.crm_products (
    product VARCHAR(255) PRIMARY KEY,
    series VARCHAR(255), 
    sales_price DECIMAL(10, 2)
);


-----------------------
DROP TABLE IF EXISTS bronze.crm_sales_team;
CREATE TABLE bronze.crm_sales_team (
    sales_ager VARCHAR(255) PRIMARY KEY, 
    manager VARCHAR(255),
    regional_o VARCHAR(255)
);


----------------
DROP TABLE IF EXISTS bronze.crm_sales_pipe;
CREATE TABLE bronze.crm_sales_pipe (
    opportunity_id VARCHAR(255) PRIMARY KEY, 
    sales_ager VARCHAR(255), 
    product VARCHAR(255), 
    account VARCHAR(255), 
    deal_stage VARCHAR(50), 
    engage_da DATE, 
    close_date DATE, 
    close_valu DECIMAL(18, 2)
);

------------
DROP TABLE IF EXISTS bronze.erp_company_financials;
CREATE TABLE bronze.erp_company_financials (
    company_name VARCHAR(255) PRIMARY KEY,
    founded_year INT, 
    hq_location VARCHAR(255), 
    industry VARCHAR(255), 
    total_funding VARCHAR(50), 
    arr VARCHAR(50), 
    valuation VARCHAR(50),
    employees VARCHAR(50), 
    top_investor VARCHAR(255), 
    product_info VARCHAR(255), 
    g2_rating DECIMAL(2, 1) 
);


