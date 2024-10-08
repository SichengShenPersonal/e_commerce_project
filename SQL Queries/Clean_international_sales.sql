-- There are many empty values in the Size, Stock, and even SKU columns.
SELECT * FROM dbo.international_sales;

-- First, fill in the Size column as much as possible. The last few letters of the SKU often indicate the size.
UPDATE dbo.international_sales
SET Size = 
    CASE
		WHEN SKU LIKE '%6XL' THEN '6XL'
		WHEN SKU LIKE '%5XL' THEN '5XL'
		WHEN SKU LIKE '%4XL' THEN '4XL'
        WHEN SKU LIKE '%XXXL' THEN '3XL'  
        WHEN SKU LIKE '%XXL' THEN 'XXL'  
        WHEN SKU LIKE '%XL' THEN 'XL'     
        WHEN SKU LIKE '%L' THEN 'L'       
		WHEN SKU LIKE '%M' THEN 'M'       
		WHEN SKU LIKE '%S' THEN 'S'
		WHEN SKU LIKE '%XS' THEN 'XS'
		WHEN SIZE = 'XXXL' THEN '3XL'
        ELSE Size
    END;

SELECT * FROM dbo.international_sales where size is null;

-- A few Size values are still null. Some SKU values end with a period (e.g., %S., %XL.), so we need to remove the period.
UPDATE dbo.international_sales
SET SKU = LEFT(SKU, LEN(SKU) - 1)
WHERE SKU LIKE '%.';

-- SC and Free are also valid sizes. After removing the period, apply the size updates again.
UPDATE dbo.international_sales
SET Size = 
    CASE
		WHEN SKU LIKE '%FREE' THEN 'L'       
		WHEN SKU LIKE '%SC' THEN 'SC'
		WHEN SKU LIKE '%6XL' THEN '6XL'
		WHEN SKU LIKE '%5XL' THEN '5XL'
		WHEN SKU LIKE '%4XL' THEN '4XL'
        WHEN SKU LIKE '%XXXL' THEN '3XL'  
        WHEN SKU LIKE '%XXL' THEN 'XXL'  
        WHEN SKU LIKE '%XL' THEN 'XL'     
        WHEN SKU LIKE '%L' THEN 'L'       
		WHEN SKU LIKE '%M' THEN 'M'       
		WHEN SKU LIKE '%S' THEN 'S'
		WHEN SKU LIKE '%XS' THEN 'XS'
		WHEN SIZE = 'XXXL' THEN '3XL'
        ELSE Size
    END;

-- Now, handle the Stock column. 
-- I tried to find insights by joining international_sales with the products table to understand the timing of stock values.
SELECT * 
FROM dbo.international_sales i 
left join dbo.products p
on i.SKU = p.SKU;

-- Unfortunately, The stock in international_sales has no clear relationship with the stock in products.
-- Therefore we can make no sense of what time this stock is presented in, so we'll drop the Stock column from both tables.
ALTER TABLE international_sales
DROP COLUMN Stock;

ALTER TABLE products
DROP COLUMN Stock;

-- With the null values handled, we¡¯ll finalize the table by dropping unnecessary columns and adjusting others.
-- The Months column duplicates information in DATE, so we¡¯ll remove it. 
-- The RATE (original price) will be rounded to 2 decimals, and we¡¯ll calculate the actual price using GROSS_AMT/PCS.
-- Rename the columns for clarity and readability.

EXEC sp_rename 'dbo.international_sales.DATE', 'Date', 'COLUMN';
ALTER TABLE dbo.international_sales DROP COLUMN Months;
EXEC sp_rename 'dbo.international_sales.CUSTOMER', 'Customer', 'COLUMN';
EXEC sp_rename 'dbo.international_sales.RATE', 'Original_price', 'COLUMN';

UPDATE dbo.international_sales
SET Original_price = ROUND(Original_price, 2);

ALTER TABLE dbo.international_sales
ADD Actual_price float;

UPDATE dbo.international_sales
SET Actual_price = CAST(Gross_AMT AS FLOAT)/CAST(PCS AS FLOAT)
WHERE PCS >= 1;

UPDATE dbo.international_sales
SET Actual_price = ROUND(Actual_price, 2);

EXEC sp_rename 'dbo.international_sales.PCS', 'Quantity', 'COLUMN';
EXEC sp_rename 'dbo.international_sales.Gross_AMT', 'Total', 'COLUMN';

-- Data cleaning for international_sales is complete.
SELECT * FROM dbo.international_sales

