-- RFM Segmentation
-- create view RFM_Segmentation_data as
With CLV as
(select 
CUSTOMERNAME,
datediff((select max(orderdate) from sales_data_rfm), max(orderdate)) recency_value,
count(distinct(ORDERNUMBER)) frequency_value,
Round(Sum(SALES),0) monetary_value,
sum(QUANTITYORDERED) total_qty_ordered,
max(ORDERDATE) customer_last_transaction_date

from sales_data_rfm
group by CUSTOMERNAME),

RFM_Score AS 
(select *,
ntile(10) over(order by recency_value desc) R_Score,
ntile(10) over(order by frequency_value asc) F_Score,
ntile(10) over(order by monetary_value asc) M_Score 
      from CLV AS C),
 
 RFM_Combination AS
(Select 
*,
R_Score+F_Score+M_Score as Total_RFM_Score,
concat_ws('', R_score,F_score,M_score) as RFM_Combinations
from RFM_Score AS RS)

select RC.*,
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


FROM RFM_COMBINATION RC;

SELECT 
    CUSTOMER_SEGMENT, count(*) as Number_of_Customers
FROM RFM_Segmentation_data 
GROUP BY 1
ORDER BY 2 DESC;

Select 
 Customer_segment,
 sum(monetary_value) Total_Spending,
 Round(avg(monetary_value),2) Avg_Spending,
 Sum(frequency_value) Total_Order,
 Sum(total_qty_ordered) Total_qty_ordered
 From RFM_Segmentation_data
 group by Customer_Segment
  ;

Select * From RFM_Segmentation_data;
SELECT R_Score, F_Score, M_Score, COUNT(*) AS customer_count
FROM rfm_segmentation_data
GROUP BY R_Score, F_Score, M_Score
ORDER BY R_Score DESC, F_Score DESC, M_Score DESC;



         
