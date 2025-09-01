# RFM Analysis Project

## Overview
This repository contains a comprehensive SQL-based RFM (Recency, Frequency, Monetary) segmentation analysis of customer data. The primary focus is on the SQL queries that calculate RFM scores and categorize customers into actionable segments (e.g., Super VIP, Loyal Customers, Lost Customers). Instructions for visualizing the results in Power BI are also included.

## Project Structure
- `RFM Segment.sql`: Contains the SQL code for RFM segmentation analysis.
- `RFM_Databae`: This file contain DB setup.
- DB Setup
```sql
CREATE DATABASE IF NOT EXISTS RFM_SALES;
USE RFM_SALES;
CREATE TABLE SALES_SAMPLE_DATA (
    ORDERNUMBER INT(8),
    QUANTITYORDERED DECIMAL(8,2),
    PRICEEACH DECIMAL(8,2),
    ORDERLINENUMBER INT(3),
    SALES DECIMAL(8,2),
    ORDERDATE VARCHAR(16),
    STATUS VARCHAR(16),
    QTR_ID INT(1),
    MONTH_ID INT(2),
    YEAR_ID INT(4),
    PRODUCTLINE VARCHAR(32),
    MSRP INT(8),
    PRODUCTCODE VARCHAR(16),
    CUSTOMERNAME VARCHAR(64),
    PHONE VARCHAR(32),
    ADDRESSLINE1 VARCHAR(64),
    ADDRESSLINE2 VARCHAR(64),
    CITY VARCHAR(16),
    STATE VARCHAR(16),
    POSTALCODE VARCHAR(16),
    COUNTRY VARCHAR(24),
    TERRITORY VARCHAR(24),
    CONTACTLASTNAME VARCHAR(16),
    CONTACTFIRSTNAME VARCHAR(16),
    DEALSIZE VARCHAR(10)
);
## Dataset Exploration

```sql
SELECT * FROM SALES_SAMPLE_DATA LIMIT 5;
```
-- OUTPUT --
| ORDERNUMBER | QUANTITYORDERED | PRICEEACH | ORDERLINENUMBER | SALES   | ORDERDATE | STATUS  | QTR_ID | MONTH_ID | YEAR_ID | PRODUCTLINE | MSRP | PRODUCTCODE | CUSTOMERNAME          | PHONE       | ADDRESSLINE1            | ADDRESSLINE2 | CITY          | STATE | POSTALCODE | COUNTRY | TERRITORY | CONTACTLASTNAME | CONTACTFIRSTNAME | DEALSIZE |
|-------------|------------------|-----------|------------------|---------|-----------|---------|--------|----------|---------|-------------|------|-------------|-----------------------|-------------|-------------------------|--------------|---------------|-------|------------|---------|-----------|-----------------|------------------|----------|
| 10107       | 30.00            | 95.70     | 2                | 2871.00 | 24/2/03   | Shipped | 1      | 2        | 2003    | Motorcycles | 95   | S10_1678    | Land of Toys Inc.     | 2125557818  | 897 Long Airport Avenue |              | NYC           | NY    | 10022      | USA     | NA        | Yu              | Kwai             | Small    |
| 10121       | 34.00            | 81.35     | 5                | 2765.90 | 7/5/03    | Shipped | 2      | 5        | 2003    | Motorcycles | 95   | S10_1678    | Reims Collectables    | 26.47.1555  | 59 rue de l'Abbaye     |              | Reims         |       | 51100      | France  | EMEA       | Henriot         | Paul             | Small    |
| 10134       | 41.00            | 94.74     | 2                | 3884.34 | 1/7/03    | Shipped | 3      | 7        | 2003    | Motorcycles | 95   | S10_1678    | Lyon Souveniers       | +33 1 46 62 7555 | 27 rue du Colonel Pierre Avia |              | Paris         |       | 75508      | France  | EMEA       | Da Cunha        | Daniel           | Medium   |
| 10145       | 45.00            | 83.26     | 6                | 3746.70 | 25/8/03   | Shipped | 3      | 8        | 2003    | Motorcycles | 95   | S10_1678    | Toys4GrownUps.com     | 6265557265  | 78934 Hillside Dr.     |              | Pasadena      | CA    | 90003      | USA     | NA        | Young           | Julie            | Medium   |
| 10159       | 49.00            | 100.00    | 14               | 5205.27 | 10/10/03  | Shipped | 4      | 10       | 2003    | Motorcycles | 95   | S10_1678    | Corporate Gift Ideas Co. | 6505551386  | 7734 Strong St.        |              | San Francisco | CA    |            | USA     | NA        | Brown           | Julie            | Medium   |

```sql
SELECT COUNT(*) FROM SALES_SAMPLE_DATA;-- 2823
```
-- OUTPUT --
| COUNT(*) |
|----------|
| 2823     |

## Checking unique values
```sql
select distinct status from SALES_SAMPLE_DATA;
```
-- OUTPUT --
| status     |
|------------|
| Shipped    |
| Disputed   |
| In Process |
| Cancelled  |
| On Hold    |
| Resolved   |

```sql
select distinct year_id from SALES_SAMPLE_DATA;
```
-- OUTPUT --
| year_id |
|---------|
| 2003    |
| 2004    |
| 2005    |

```sql
select distinct PRODUCTLINE from SALES_SAMPLE_DATA;
```
-- OUTPUT --
| PRODUCTLINE      |
|------------------|
| Motorcycles      |
| Classic Cars     |
| Trucks and Buses |
| Vintage Cars     |
| Planes           |
| Ships            |
| Trains           |

```sql
select distinct COUNTRY from SALES_SAMPLE_DATA;
```
-- OUTPUT --
| COUNTRY     |
|-------------|
| USA         |
| France      |
| Norway      |
| Australia   |
| Finland     |
| Austria     |
| UK          |
| Spain       |
| Sweden      |
| Singapore   |
| Canada      |
| Japan       |
| Italy       |
| Denmark     |
| Belgium     |
| Philippines |
| Germany     |
| Switzerland |
| Ireland     |

```sql
select distinct DEALSIZE from SALES_SAMPLE_DATA;
```
-- OUTPUT --
| DEALSIZE |
|----------|
| Small    |
| Medium   |
| Large    |

```sql
select distinct TERRITORY from SALES_SAMPLE_DATA;
```
-- OUTPUT --
| TERRITORY |
|-----------|
| NA        |
| EMEA      |
| APAC      |
| Japan     |

```

## SQL Analysis
The SQL script (`RFM Segment.sql`) includes the following key components:

```sql
-- RFM Segmentation
CREATE VIEW RFM_Segmentation_data AS
WITH CLV AS (
    SELECT 
        CUSTOMERNAME,
        DATEDIFF((SELECT MAX(orderdate) FROM sales_data_rfm), MAX(orderdate)) AS recency_value,
        COUNT(DISTINCT(ORDERNUMBER)) AS frequency_value,
        ROUND(SUM(SALES), 0) AS monetary_value,
        SUM(QUANTITYORDERED) AS total_qty_ordered,
        MAX(ORDERDATE) AS customer_last_transaction_date
    FROM sales_data_rfm
    GROUP BY CUSTOMERNAME
),
RFM_Score AS (
    SELECT *,
        NTILE(10) OVER (ORDER BY recency_value DESC) AS R_Score,
        NTILE(10) OVER (ORDER BY frequency_value ASC) AS F_Score,
        NTILE(10) OVER (ORDER BY monetary_value ASC) AS M_Score
    FROM CLV AS C
),
RFM_Combination AS (
    SELECT *,
        R_Score + F_Score + M_Score AS Total_RFM_Score,
        CONCAT_WS('', R_Score, F_Score, M_Score) AS RFM_Combinations
    FROM RFM_Score AS RS
)
SELECT RC.*,
    CASE
        -- 1. Super VIP: Highest in all three
        WHEN R_Score >= 9 AND F_Score >= 9 AND M_Score >= 9 THEN 'Super VIP'
        -- 2. VIP: Very high but slightly below Super VIP
        WHEN R_Score >= 8 AND F_Score >= 8 AND M_Score >= 8 THEN 'VIP'
        -- 3. Elite Customers: High value and frequency, decent recency
        WHEN R_Score >= 7 AND F_Score >= 8 AND M_Score >= 8 THEN 'Elite Customers'
        -- 4. Big Spenders: High monetary but not as recent or frequent
        WHEN M_Score >= 9 AND R_Score BETWEEN 5 AND 7 AND F_Score BETWEEN 5 AND 7 THEN 'Big Spenders'
        -- 5. Potential VIP: Very recent + high monetary but frequency still mid
        WHEN R_Score >= 9 AND M_Score >= 8 AND F_Score BETWEEN 5 AND 7 THEN 'Potential VIP'
        -- 6. Loyal Customers: Visit frequently, moderate spending, decent recency
        WHEN F_Score >= 8 AND R_Score BETWEEN 6 AND 8 AND M_Score BETWEEN 6 AND 8 THEN 'Loyal Customers'
        -- 7. Promising: Good recency but low-mid frequency and monetary
        WHEN R_Score >= 8 AND F_Score <= 5 AND M_Score <= 5 THEN 'Promising'
        -- 8. Needs Attention: Average across all metrics
        WHEN R_Score BETWEEN 5 AND 7 AND F_Score BETWEEN 5 AND 7 AND M_Score BETWEEN 5 AND 7 THEN 'Needs Attention'
        -- 9. At Risk: Used to be good, low recency now
        WHEN R_Score <= 4 AND F_Score >= 6 AND M_Score >= 6 THEN 'At Risk'
        -- 10. Hibernating: Very low recency + frequency, moderate spend
        WHEN R_Score <= 3 AND F_Score <= 3 AND M_Score BETWEEN 4 AND 7 THEN 'Hibernating'
        -- 11. Lost Customers: Lowest in all three
        WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2 THEN 'Lost Customers'
        -- 12. Others: Anything that doesn't fit above
        ELSE 'General Customers'
    END AS Customer_Segment
FROM RFM_Combination RC;

-- Aggregate metrics per segment
SELECT 
    Customer_segment,
    SUM(monetary_value) AS Total_Spending,
    ROUND(AVG(monetary_value), 2) AS Avg_Spending,
    SUM(frequency_value) AS Total_Order,
    SUM(total_qty_ordered) AS Total_qty_ordered
FROM RFM_Segmentation_data
GROUP BY Customer_Segment;

-- View all segmented data
SELECT * FROM RFM_Segmentation_data;

-- Distribution of customers by RFM scores
SELECT 
    CUSTOMER_SEGMENT, count(*) as Number_of_Customers
FROM RFM_Segmentation_data 
GROUP BY 1
ORDER BY 2 DESC;
```
-- OUTPUT --
| CUSTOMER_SEGMENT          | Number_of_Customers |
|---------------------------|---------------------|
| General Customer          | 50                  |
| Needs Attention           |  9                  |
| VIP                       |  9                  |
| Lost Customers            |  5                  |
| Hibernating               |  5                  |
| At Risk                   |  3                  |
|Elite Customers            |  3                  |
|Super VIP                  |  3                  |
|Promising                  |  2                  |
|Big Spenders               |  2                  |
|Loyal Customers            |  1                  |
---
### Key Features:
- **Recency Value**: Days since the last purchase.
- **Frequency Value**: Number of distinct orders.
- **Monetary Value**: Total sales amount.
- **Segmentation**: 12 customer segments based on RFM score thresholds.
- **Aggregates**: Total and average spending, order counts, and quantity ordered per segment.

## Power BI Visualization
To complement the SQL analysis with visuals:
1. **Data Import**: Connect Power BI to your SQL database and import the `RFM_Segmentation_data` view.
2. **Dashboard Setup** :
   ![Dashboard View](RFM_Analysis.png)
   - `.pbix` file [RFM_Analysis.pbix](Images/RFM_Analysis.pbix) available for download

## Usage
1. Clone this repository.
2. Set up a SQL database with a `sales_data_rfm` table containing `CUSTOMERNAME`, `ORDERNUMBER`, `ORDERDATE`, `SALES`, and `QUANTITYORDERED`.
3. Export Datas from Sales Sample Data.csv file
4. Execute the SQL script to create the `RFM_Segmentation_data` view.
5. Use Power BI to import and visualize the data as described.

## Contributing
Enhance the SQL queries or Power BI visuals by forking this repository and submitting pull requests.

## License
This project is open-source under the MIT License.
