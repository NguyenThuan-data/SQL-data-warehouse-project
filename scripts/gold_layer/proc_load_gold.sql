-- =============================================================================
-- Stored Procedure: Load Gold Layer (Silver -> Gold)
-- =============================================================================
-- Script Purpose:
-- 	This stored procedure populates the Star Schema in the 'gold' schema
-- 	by joining and enriching data from the 'silver' layer.
-- =============================================================================

CREATE OR REPLACE PROCEDURE gold.load_gold()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Loading Gold Layer (Star Schema)';
    RAISE NOTICE '=============================================';

    -- 1. Populate Dimension: dim_accounts
    -- (Enriching CRM accounts with SaaS financials from ERP)
    RAISE NOTICE '>> Populating: gold.dim_accounts';
    TRUNCATE TABLE gold.dim_accounts RESTART IDENTITY CASCADE;
    INSERT INTO gold.dim_accounts (
        account_name, sector, year_established, annual_revenue, 
        parent_company, hq_location, is_saas_company, valuation_usd, arr_usd, employee_count
    )
    SELECT 
        src.account,
        src.sector,
        src.year_estab,
        src.revenue,
        src.subsidiary_parent,
        COALESCE(erp.hq_location, src.office_loca),
        erp.company_name IS NOT NULL,
        erp.valuation_usd,
        erp.arr_usd,
        COALESCE(erp.employees, src.employees)
    FROM silver.crm_accounts src
    LEFT JOIN silver.erp_company_financials erp 
        ON LOWER(src.account) = LOWER(erp.company_name);

    -- 2. Populate Dimension: dim_products
    RAISE NOTICE '>> Populating: gold.dim_products';
    TRUNCATE TABLE gold.dim_products RESTART IDENTITY CASCADE;
    INSERT INTO gold.dim_products (product_name, series, base_price)
    SELECT product, series, sales_price
    FROM silver.crm_products;

    -- 3. Populate Dimension: dim_sales_team
    RAISE NOTICE '>> Populating: gold.dim_sales_team';
    TRUNCATE TABLE gold.dim_sales_team RESTART IDENTITY CASCADE;
    INSERT INTO gold.dim_sales_team (agent_name, manager_name, region)
    SELECT sales_ager, manager, regional_o
    FROM silver.crm_sales_team;

    -- 4. Populate Fact: fact_sales_pipeline
    RAISE NOTICE '>> Populating: gold.fact_sales_pipeline';
    TRUNCATE TABLE gold.fact_sales_pipeline CASCADE;
    INSERT INTO gold.fact_sales_pipeline (
        opportunity_id, account_key, product_key, sales_agent_key, 
        deal_stage, engagement_date, close_date, close_value, is_won, sales_cycle_days
    )
    SELECT 
        f.opportunity_id,
        a.account_key,
        p.product_key,
        t.sales_agent_key,
        f.deal_stage,
        f.engage_da,
        f.close_date,
        f.close_valu,
        f.deal_stage = 'Won',
        EXTRACT(DAY FROM (f.close_date::timestamp - f.engage_da::timestamp))
    FROM silver.crm_sales_pipe f
    JOIN gold.dim_accounts a ON f.account = a.account_name
    JOIN gold.dim_products p ON f.product = p.product_name
    JOIN gold.dim_sales_team t ON f.sales_ager = t.agent_name;

    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Loading Gold Layer Completed';
    RAISE NOTICE '=============================================';
END;
$$;
