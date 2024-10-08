-- Unusual styles and SKUs like Shipping and Tags are found in the data
SELECT * FROM dbo.international_sales
ORDER BY Style;

-- These likely represent operational costs, so we store them in a separate table for later use.
-- The "Month" column duplicates "Date," so we remove it.
-- SKU and Style are identical for these records, so we keep only one.
-- Stock and Size don't apply, so we exclude them.
-- GROSS_AMT represents total cost, so PCS and RATE are unnecessary.

SELECT DATE AS Date, CUSTOMER as Customer, Style as Category, GROSS_AMT as Costs
INTO operational
FROM dbo.international_sales
WHERE Style in ('SHIPPING', 'SHIPPING CHARGES', 'TAG PRINTING', 'TAGS', 'TAGS(LABOUR)')
ORDER BY Date ASC;

-- Remove these records from international_sales
DELETE FROM dbo.international_sales
WHERE Style IN ('SHIPPING', 'SHIPPING CHARGES', 'TAG PRINTING', 'TAGS', 'TAGS(LABOUR)');