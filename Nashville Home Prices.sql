-- To test the data that is loaded into the database and table
SELECT *
FROM molten-thought-441320-u6.Example.nashvillehousing
LIMIT 10


-- to find the ranges in SaleDate and present this in various date formats
SELECT 
    MIN(SaleDate) AS sale_date_min, 
    MAX(SaleDate) AS sale_date_max, 
    CAST(ROUND((DATE_DIFF(MAX(SaleDate), MIN(SaleDate), month) / 12),0) AS INT) AS sale_date_range_year,
    DATE_DIFF(MAX(SaleDate), MIN(SaleDate), month) AS sale_date_range_month,
    DATE_DIFF(MAX(SaleDate), MIN(SaleDate), day) AS sale_date_range_day
FROM molten-thought-441320-u6.Example.nashvillehousing


-- to transform the SaleDate field to separate day and timestamp data fields for further analysis
SELECT SaleDate, CAST(SaleDate AS DATE) AS sale_date_day, CAST(SaleDate AS TIMESTAMP) AS sale_date_timestamp
FROM molten-thought-441320-u6.Example.nashvillehousing


-- to SELECT the `UniqueID ` field
SELECT `UniqueID `
FROM molten-thought-441320-u6.Example.nashvillehousing
LIMIT 10


-- to break out property address into individual columns (e.g., street, city) for further analysis
SELECT 
    PropertyAddress,
    SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress,',') -1) AS property_street, 
    SUBSTRING(PropertyAddress, INSTR(PropertyAddress,',') +1, LENGTH(PropertyAddress)) AS property_city
FROM molten-thought-441320-u6.Example.nashvillehousing


-- to break out owner address into individual columns (e.g., street, city, state) for further analysis
SELECT 
    OwnerAddress,
    SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') -1) AS owner_street, 
    SUBSTRING(REPLACE(OwnerAddress, SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') +1), ""), 1, INSTR(REPLACE(OwnerAddress, SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') +1), ""),',') -1) AS owner_city,
   RIGHT(OwnerAddress, 2) AS owner_state
FROM molten-thought-441320-u6.Example.nashvillehousing


-- to populate the property address WHERE is null
SELECT a.*, 
    IFNULL(a.PropertyAddress, b.PropertyAddress) AS property_address_updated,
FROM molten-thought-441320-u6.Example.nashvillehousing a
LEFT JOIN molten-thought-441320-u6.Example.nashvillehousing b
ON a.ParcelID = b.ParcelID AND a.`UniqueID ` <> b.`UniqueID `


-- to filter out duplicates using a CTE
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY `UniqueID `) AS row_num
    FROM molten-thought-441320-u6.Example.nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num = 1
ORDER BY PropertyAddress


-- to create the data WHERE the property address is normalized, the addresses are cleaned up, and the duplicates are filtered out in one query
CREATE TABLE molten-thought-441320-u6.Example.nashvillehousingupdated AS 
WITH CleanedAddresses AS (
    -- Clean up PropertyAddress and populate missing values
    SELECT
        a.*,
        COALESCE(a.PropertyAddress, b.PropertyAddress) AS property_address_updated
    FROM molten-thought-441320-u6.Example.nashvillehousing a
    LEFT JOIN molten-thought-441320-u6.Example.nashvillehousing b
    ON a.ParcelID = b.ParcelID AND a.`UniqueID ` <> b.`UniqueID `
),
ParsedAddresses AS (
    SELECT 
    *,
    SUBSTRING(property_address_updated, 1, INSTR(property_address_updated,',') -1) AS property_street,
    SUBSTRING(property_address_updated, INSTR(property_address_updated,',') +1, LENGTH(property_address_updated)) AS property_city,
    SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') -1) AS owner_street, 
    SUBSTRING(REPLACE(OwnerAddress, SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') +1), ""), 1, INSTR(REPLACE(OwnerAddress, SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress,',') +1), ""),',') -1) AS owner_city,
    RIGHT(OwnerAddress, 2) AS owner_state,
    FROM CleanedAddresses
),
RowNumCTE AS (
    -- Remove duplicates
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY ParcelID ORDER BY SalePrice DESC, SaleDate DESC, `UniqueID ` ASC) AS row_num
    FROM ParsedAddresses
)
-- Final result: SELECT unique rows
SELECT
    *,
    CAST(SaleDate AS DATE) AS sale_date_day, CAST(SaleDate AS TIMESTAMP) AS sale_date_timestamp
FROM RowNumCTE
WHERE row_num = 1


-- To drop table if needed
DROP TABLE molten-thought-441320-u6.Example.nashvillehousingupdated


-- To find the correlation between the various factors and price
SELECT
    ROUND(CORR(BuildingValue, SalePrice), 2) AS building_value_to_price_correlation,
    ROUND(CORR(LandValue, SalePrice), 2) AS land_value_to_price_correlation,
    ROUND(CORR(Bedrooms, SalePrice), 2) AS bedrooms_to_price_correlation,
    ROUND(CORR(FullBath, SalePrice), 2) AS bathrooms_to_price_correlation,
    ROUND(CORR(YearBuilt, SalePrice), 2) AS year_to_price_correlation
FROM
    molten-thought-441320-u6.Example.nashvillehousingupdated


-- To calculate the descriptive statistics for price
SELECT
    CAST(AVG(SalePrice) AS INT) AS avg_sale_price,
    APPROX_QUANTILES(SalePrice, 2)[OFFSET(1)] AS median_sale_price, 
    MIN(SalePrice) AS min_sale_price, 
    MAX(SalePrice) AS max_sale_price
FROM
    molten-thought-441320-u6.Example.nashvillehousingupdated


-- To calculate the descriptive statistics for price in 2016
SELECT
    CAST(AVG(SalePrice) AS INT) AS avg_sale_price,
    APPROX_QUANTILES(SalePrice, 2)[OFFSET(1)] AS median_sale_price, 
    MIN(SalePrice) AS min_sale_price, 
    MAX(SalePrice) AS max_sale_price
FROM
    molten-thought-441320-u6.Example.nashvillehousingupdated
WHERE EXTRACT(YEAR FROM SaleDate) = 2016


-- To create a report of the average home sales, bathrooms, bedrooms by month in 2016
SELECT
    EXTRACT(MONTH FROM SaleDate) AS month,
    CAST(ROUND(AVG(SalePrice),0) AS INT) as sale_price_avg,
    ROUND(AVG(Bedrooms), 1) AS bedrooms_price_avg,
    ROUND(AVG(FullBath), 1) AS full_baths_price_avg,
    ROUND(AVG(HalfBath), 1) AS half_baths_price_avg,
FROM
    molten-thought-441320-u6.Example.nashvillehousingupdated
WHERE EXTRACT(YEAR FROM SaleDate) = 2016
GROUP BY month
ORDER BY month ASC


-- To create a report of the average home sales, bathrooms, bedrooms by year
SELECT
    EXTRACT(YEAR FROM SaleDate) AS year,
    CAST(ROUND(AVG(SalePrice),0) AS INT) AS sale_price_avg,
    APPROX_QUANTILES(SalePrice, 2)[OFFSET(1)] AS median_sale_price,
    ROUND(AVG(Bedrooms), 1) AS bedrooms_price_avg,
    ROUND(AVG(FullBath), 1) AS full_baths_price_avg,
    ROUND(AVG(HalfBath), 1) AS half_baths_price_avg,
FROM
    molten-thought-441320-u6.Example.nashvillehousingupdated
WHERE EXTRACT(YEAR FROM SaleDate) <> 2019
GROUP BY year
ORDER BY year ASC