-- Review the data in local_sales_raw.
SELECT * FROM dbo.local_sales_raw;

-- First, remove the canceled orders since they don't contribute to actual sales.
-- Next, remove the Status and Courier_Status columns as we don't know the exact timing of these statuses.
-- Rename the relevant columns for clarity.
-- Accomplish this by creating a new table, then drop the original table.
SELECT *
INTO local_sales
From
	(
	SELECT 
		Order_ID, 
		ASIN, 
		Date, 
		Style, 
		SKU, 
		Category,
		Size, 
		Qty AS Quantity, 
		CAST(Amount AS FLOAT)/CAST(Qty AS FLOAT) AS Price, 
		Amount AS Total, 
		Fulfilment + ' ' + ship_service_level AS Service, 
		ship_city AS City, 
		ship_state AS State, 
		LEFT(ship_postal_code, LEN(ship_postal_code) - 2) AS Zipcode,
		B2B
	FROM dbo.local_sales_raw
	WHERE Qty >= 1
	) 
	AS local_sales

-- Data cleaning is complete.
SELECT * FROM dbo.local_sales;

--Finally, drop the old local_sales_raw table.
DROP TABLE dbo.local_sales_raw;