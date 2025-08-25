/*
=============================================================================
Stored ProcedureL Load Bronze Layer (Source -> Bronze)
=============================================================================
Script Purpose:
	This stored procedure loads data into the 'bronze' schema from external CSV files.
	It performs the following actions;
	- Truncates the bronze tables before loading data.
	- Uses the 'Copy' command to load data from csv files to bronze layer tables.

Parameters:
	None. This stored procedure does not accrpt any parameters or return any values.

Useage Example:
	CALL bronze.load_bronze;
=============================================================================
*/
CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
	batch_start_time TIMESTAMPTZ;
	batch_end_time TIMESTAMPTZ;
BEGIN
	batch_start_time := now();
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '=============================================';

    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Loading CRM tables';
    RAISE NOTICE '=============================================';
-------------------------------
    start_time := now();
    RAISE NOTICE '>> Truncating table: bronze.crm_accounts';
    TRUNCATE TABLE bronze.crm_accounts;

    RAISE NOTICE '>> Inserting data into: bronze.crm_accounts';
    COPY bronze.crm_accounts
    FROM 'C:\Users\Admin1\Database Project\DataWarehouse and Analytics Project\datasets\source crm\accounts.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := now();
    RAISE NOTICE '>> Load Duration: %', end_time - start_time;
	RAISE NOTICE '----------------------------';
--------------------------------
    start_time := now();
    RAISE NOTICE '>> Truncating table: bronze.crm_products';
    TRUNCATE TABLE bronze.crm_products;

    RAISE NOTICE '>> Inserting data into: bronze.crm_products';
    COPY bronze.crm_products
    FROM 'C:\Users\Admin1\Database Project\DataWarehouse and Analytics Project\datasets\source crm\products.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := now();
    RAISE NOTICE '>> Load Duration: %', end_time - start_time;
	RAISE NOTICE '----------------------------';
--------------------------------
    start_time := now();
    RAISE NOTICE '>> Truncating table: bronze.crm_sales_pipe';
    TRUNCATE TABLE bronze.crm_sales_pipe;

    RAISE NOTICE '>> Inserting data into: bronze.crm_sales_pipe';
    COPY bronze.crm_sales_pipe
    FROM 'C:\Users\Admin1\Database Project\DataWarehouse and Analytics Project\datasets\source crm\sales_pipeline.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := now();
    RAISE NOTICE '>> Load Duration: %', end_time - start_time;
	RAISE NOTICE '----------------------------';
--------------------------------
    start_time := now();
    RAISE NOTICE '>> Truncating table: bronze.crm_sales_team';
    TRUNCATE TABLE bronze.crm_sales_team;

    RAISE NOTICE '>> Inserting data into: bronze.crm_sales_team';
    COPY bronze.crm_sales_team
    FROM 'C:\Users\Admin1\Database Project\DataWarehouse and Analytics Project\datasets\source crm\sales_teams.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := now();
    RAISE NOTICE '>> Load Duration: %', end_time - start_time;
	RAISE NOTICE '----------------------------';
---------------------------------
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Loading ERP tables';
    RAISE NOTICE '=============================================';

    start_time := now();
    RAISE NOTICE '>> Truncating table: bronze.erp_company_financials';
    TRUNCATE TABLE bronze.erp_company_financials;

    RAISE NOTICE '>> Inserting data into: bronze.erp_company_financials';
    COPY bronze.erp_company_financials
    FROM 'C:\Users\Admin1\Database Project\DataWarehouse and Analytics Project\datasets\source erp\top_100_saas_companies_2025.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := now();
    RAISE NOTICE '>> Load Duration: %', end_time - start_time;
	RAISE NOTICE '----------------------------';

	batch_end_time := now();
	RAISE NOTICE '=============================================';
    RAISE NOTICE 'loading Bronze Layer is Completed';
    RAISE NOTICE 'Total Duration: %', batch_end_time - batch_start_time;
    RAISE NOTICE '=============================================';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '=============================================';
        RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'ERROR MESSAGE: %', SQLERRM;
        RAISE NOTICE '=============================================';
END;
$$;
