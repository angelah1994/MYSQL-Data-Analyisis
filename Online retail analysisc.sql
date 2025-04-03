-- list top selling products
SELECT TOP 5
    Description,
    SUM(Quantity) AS TotalQuantitySold
FROM OnlineRetail..retails
GROUP BY Description
ORDER BY TotalQuantitySold DESC

-- Top selling products
WITH ProductSales AS (
    SELECT 
        Description,
        SUM(Quantity) AS TotalQuantity,
        RANK() OVER (ORDER BY SUM(Quantity) DESC) AS Rank
    FROM OnlineRetail..retails
    GROUP BY Description
)
SELECT * FROM ProductSales
WHERE Rank <= 10;


-- Total Revenue by country
SELECT Country,
sum(Quantity * UnitPrice) As TotalRevenue
FROM OnlineRetail..retails
Group By  Country
Order by 2 DESC


-- WHERE customerID IS NULL

-- Remove values where values are null
DELETE FROM OnlineRetail..retails
WHERE customerID IS NULL

--  Customer Purchase Frequency
SELECT customerID, count(InvoiceNO) AS frequencyOfPurchase
FROM OnlineRetail..retails
GROUP BY customerID
order BY 2 DESC

-- Monthly Revenue Analysis

SELECT 
    FORMAT(InvoiceDate, 'yyyy-MM') AS Salesmonth, 
    SUM(Quantity * UnitPrice) AS MonthlyRevenue
FROM 
    OnlineRetail..retails
GROUP BY 
    FORMAT(InvoiceDate, 'yyyy-MM')
ORDER BY 
    Salesmonth;

-- Average Order Value (AOV) per Customer
SELECT CustomerID,
	AVG(Quantity * UnitPrice) AS AOV
FROM 
    OnlineRetail..retails
GROUP By
	CustomerID
ORDER BY 2 DESC

-- Top 10 Highest Revenue Generating Products
SELECT TOP 10
    Description,
    SUM(Quantity * UnitPrice) AS RevenueGenerated
FROM OnlineRetail..retails
GROUP BY Description
ORDER BY RevenueGenerated DESC

-- Sales Count per Country
SELECT 
    Country,
    COUNT(InvoiceNo) AS TotalSalesCount
FROM OnlineRetail..retails
GROUP BY Country
ORDER BY TotalSalesCount DESC;


-- Peak Sales Time of the Day
SELECT 
    DATEPART(HOUR, InvoiceDate) AS HourOfDay,
    COUNT(*) AS NumberOfSales
FROM 
    OnlineRetail..retails
GROUP BY 
    DATEPART(HOUR, InvoiceDate)
ORDER BY 
    NumberOfSales DESC;

-- Total revenue generated per day
WITH DailySales AS (
SELECT CAST(InvoiceDate AS DATE) AS SalesDate,
SUM(Quantity * UnitPrice) AS totalRevenue

FROM OnlineRetail..retails
GROUP BY CAST(InvoiceDate AS DATE)
)
SELECT * FROM DailySales
order by 2


-- Monthly Sales Growth
WITH MonthlySales AS (
    SELECT 
        FORMAT(InvoiceDate, 'YYYY-MM') AS SalesMonth,
        SUM(Quantity * UnitPrice) AS TotalRevenue
    FROM OnlineRetail..retails
    GROUP BY FORMAT(InvoiceDate, 'YYYY-MM')
)
SELECT 
    SalesMonth,
    TotalRevenue,
    LAG(TotalRevenue, 1) OVER (ORDER BY SalesMonth) AS PreviousMonthRevenue,
    ROUND(((TotalRevenue - LAG(TotalRevenue, 1) OVER (ORDER BY SalesMonth)) / LAG(TotalRevenue, 1) OVER (ORDER BY SalesMonth)) * 100, 2) AS GrowthRate
FROM MonthlySales;



-- Product Return Analysis
WITH Returns AS (
    SELECT 
        Description,
        ABS(SUM(Quantity)) AS TotalReturns
    FROM OnlineRetail..retails
    WHERE Quantity < 0
    GROUP BY Description
    
)
SELECT * FROM Returns
ORDER BY TotalReturns DESC;

-- Find customers who made purchases across multiple months.

WITH CustomerActivity AS (
    SELECT 
        CustomerID,
        COUNT(DISTINCT FORMAT(InvoiceDate, 'YYYY-MM')) AS ActiveMonths
    FROM OnlineRetail..retails
    GROUP BY CustomerID
)
SELECT * FROM CustomerActivity 
WHERE ActiveMonths > 1
order by ActiveMonths DESC;


-- Seasonal Sales

WITH SeasonalSales AS (
    SELECT 
        CASE 
            WHEN MONTH(InvoiceDate) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(InvoiceDate) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(InvoiceDate) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(InvoiceDate) IN (9, 10, 11) THEN 'Autumn'
        END AS Season,
        SUM(Quantity * UnitPrice) AS TotalRevenue
    FROM 
        OnlineRetail..retails
    GROUP BY 
        CASE 
            WHEN MONTH(InvoiceDate) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(InvoiceDate) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(InvoiceDate) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(InvoiceDate) IN (9, 10, 11) THEN 'Autumn'
        END
)
SELECT 
    *
FROM 
    SeasonalSales;


-- Calculate total spending per customer, categorize them as "High", "Medium", or "Low"
-- Step 1: Create a temporary table for storing customer spending
-- Step 1: Drop and create a temporary table for customer spending
DROP TABLE IF EXISTS #CustomerSpending;

CREATE TABLE #CustomerSpending (
    CustomerID NVARCHAR(50),  -- Adjust data type based on your table
    Country NVARCHAR(100),    -- Adjust data type based on your table
    TotalSpent FLOAT
);

INSERT INTO #CustomerSpending
SELECT 
    CustomerID,
    Country,
    SUM(Quantity * UnitPrice) AS TotalSpent
FROM 
    OnlineRetail..retails
GROUP BY 
    CustomerID, 
    Country;

-- Step 2: Use CTE to categorize spenders based on total spending
WITH CategorizedSpenders AS (
    SELECT 
        CustomerID,
        Country,
        TotalSpent,
        CASE 
            WHEN TotalSpent > 1000 THEN 'High'
            WHEN TotalSpent BETWEEN 500 AND 1000 THEN 'Medium'
            ELSE 'Low'
        END AS SpendingCategory,
        RANK() OVER (ORDER BY TotalSpent DESC) AS CustomerRank
    FROM 
        #CustomerSpending
)
SELECT 
    cs.CustomerID,
    cs.Country,
    cs.TotalSpent,
    cs.SpendingCategory,
    cs.CustomerRank,
    COUNT(*) OVER (PARTITION BY cs.Country) AS CustomersPerCountry
FROM 
    CategorizedSpenders cs
ORDER BY 
    cs.TotalSpent DESC;

-- Clean up (optional): Drop the temporary table when done
DROP TABLE #CustomerSpending;



--Analyze revenue growth by product category (e.g., home decor) and find the month with the highest growth.

-- Step 1: Create a temporary table for product categories


-- Step 1: Create a temporary table for product categories
DROP TABLE IF EXISTS #ProductCategories;

CREATE TABLE #ProductCategories (
    Description NVARCHAR(255),
    Category NVARCHAR(50)
);

INSERT INTO #ProductCategories
SELECT 
    Description,
    CASE 
        WHEN Description LIKE '%HOLDER%' THEN 'Home Decor'
        WHEN Description LIKE '%DOLL%' THEN 'Toys'
        WHEN Description LIKE '%CUP%' THEN 'Kitchen'
        ELSE 'Miscellaneous'
    END AS Category
FROM 
    OnlineRetail..retails;

-- Step 2: CTE to calculate monthly revenue by category and growth
WITH MonthlyRevenue AS (
    SELECT 
        FORMAT(InvoiceDate, 'yyyy-MM') AS [Month],
        pc.Category,
        SUM(Quantity * UnitPrice) AS Revenue
    FROM 
        OnlineRetail..retails t
    JOIN 
        #ProductCategories pc ON t.Description = pc.Description
    GROUP BY 
        FORMAT(InvoiceDate, 'yyyy-MM'), 
        pc.Category
),
MonthlyGrowth AS (
    SELECT 
        [Month],
        Category,
        Revenue,
        LAG(Revenue) OVER (PARTITION BY Category ORDER BY [Month]) AS PrevRevenue,
        ROUND(((Revenue - LAG(Revenue) OVER (PARTITION BY Category ORDER BY [Month])) / 
              NULLIF(LAG(Revenue) OVER (PARTITION BY Category ORDER BY [Month]), 0)) * 100, 2) AS GrowthRate
    FROM 
        MonthlyRevenue
)
SELECT 
    [Month],
    Category,
    Revenue,
    GrowthRate
FROM 
    MonthlyGrowth
ORDER BY 
    Category, 
    [Month];

DROP TABLE #ProductCategories;

-- Products sold in each country

WITH ProductSales AS (
    SELECT 
        Country,
        Description,
        SUM(Quantity) AS TotalSold,
        RANK() OVER (PARTITION BY Country ORDER BY SUM(Quantity) DESC) AS ProductRank
    FROM OnlineRetail..retails
    GROUP BY Country, Description
)
SELECT 
    Country,
    Description,
    TotalSold
FROM ProductSales
WHERE ProductRank = 1;

SELECT * FROM OnlineRetail..retails




