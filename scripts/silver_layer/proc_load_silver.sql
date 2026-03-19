-- =============================================================================
-- Stored Procedure: Load Silver Layer (Bronze -> Silver)
-- =============================================================================
-- Script Purpose:
-- 	This stored procedure cleanses and standardizes data from the 'bronze' schema
-- 	and loads it into the 'silver' schema.
-- =============================================================================

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
BEGIN
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '=============================================';

    -- 1. Cleansing CRM Accounts
    RAISE NOTICE '>> Cleansing: silver.crm_accounts';
    TRUNCATE TABLE silver.crm_accounts;
    INSERT INTO silver.crm_accounts (
        account, sector, year_estab, revenue, employees, office_loca, subsidiary_parent
    )
    SELECT 
        DISTINCT account,
        CASE 
            WHEN TRIM(LOWER(sector)) = 'technolgy' THEN 'Technology'
            WHEN sector IS NULL OR sector = '' THEN 'Other'
            ELSE INITCAP(TRIM(sector))
        END,
        year_estab,
        revenue,
        employees,
        TRIM(office_loca),
        TRIM(subsidiary_parent)
    FROM bronze.crm_accounts;

    -- 2. Cleansing CRM Products
    RAISE NOTICE '>> Cleansing: silver.crm_products';
    TRUNCATE TABLE silver.crm_products;
    INSERT INTO silver.crm_products (product, series, sales_price)
    SELECT 
        DISTINCT product,
        INITCAP(TRIM(series)),
        COALESCE(sales_price, 0)
    FROM bronze.crm_products;

    -- 3. Cleansing CRM Sales Team
    RAISE NOTICE '>> Cleansing: silver.crm_sales_team';
    TRUNCATE TABLE silver.crm_sales_team;
    INSERT INTO silver.crm_sales_team (sales_ager, manager, regional_o)
    SELECT 
        DISTINCT sales_ager,
        TRIM(manager),
        TRIM(regional_o)
    FROM bronze.crm_sales_team;

    -- 4. Cleansing CRM Sales Pipeline
    RAISE NOTICE '>> Cleansing: silver.crm_sales_pipe';
    TRUNCATE TABLE silver.crm_sales_pipe;
    INSERT INTO silver.crm_sales_pipe (
        opportunity_id, sales_ager, product, account, deal_stage, engage_da, close_date, close_valu
    )
    SELECT 
        opportunity_id,
        sales_ager,
        product,
        account,
        INITCAP(TRIM(deal_stage)),
        engage_da,
        close_date,
        COALESCE(close_valu, 0)
    FROM bronze.crm_sales_pipe;

    -- 5. Cleansing ERP Company Financials (SaaS Core Data)
    RAISE NOTICE '>> Cleansing: silver.erp_company_financials';
    TRUNCATE TABLE silver.erp_company_financials;
    INSERT INTO silver.erp_company_financials (
        company_name, founded_year, hq_location, industry, 
        total_funding_usd, arr_usd, valuation_usd, employees, top_investor, g2_rating
    )
    SELECT 
        DISTINCT company_name,
        founded_year,
        TRIM(hq_location),
        INITCAP(TRIM(industry)),
        silver.fn_parse_human_readable(total_funding),
        silver.fn_parse_human_readable(arr),
        silver.fn_parse_human_readable(valuation),
        silver.fn_parse_human_readable(employees)::INT,
        TRIM(top_investor),
        g2_rating
    FROM bronze.erp_company_financials;

    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Loading Silver Layer Completed';
    RAISE NOTICE '=============================================';
END;
$$;
