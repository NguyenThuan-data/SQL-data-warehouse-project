/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
*/

--- Database can be create through user interface of PGadmin
-- Check if the 'DataWarehouse' database existed
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_database
        WHERE datname = 'datawarehouse'
    ) THEN
        RAISE WARNING 'The database "datawarehouse" already exists. Please choose another name.';
    END IF;
END
$$;

--Create Schemas
create schema bronze;

create schema silver;

create schema gold;

