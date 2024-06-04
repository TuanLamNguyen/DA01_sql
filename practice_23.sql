
-- 1. Doanh thu theo từng ProductLine, Year và DealSize
SELECT 
  productline,
  year_id,
  dealsize,
  SUM(sales) AS revenue
FROM 
  sales_dataset_rfm_prj_clean1
GROUP BY 
  productline, year_id, dealsize
ORDER BY 
  productline, year_id, dealsize;


--2. Đâu là tháng có bán tốt nhất mỗi năm?
WITH monthly_sales AS (
  SELECT 
    month_id,
    year_id,
    SUM(sales) AS revenue,
    COUNT(ordernumber) AS order_count
  FROM 
    sales_dataset_rfm_prj_clean1
  GROUP BY 
    month_id, year_id
)
SELECT 
  year_id,
  month_id,
  revenue,
  order_count
FROM 
  monthly_sales
WHERE 
  (year_id, revenue) IN (
    SELECT 
      year_id, 
      MAX(revenue) 
    FROM 
      monthly_sales
    GROUP BY 
      year_id
  )
ORDER BY 
  year_id, month_id;

-- tháng 11 là tháng bán tốt nhất ở năm 2003 và 2004
-- tháng 5 là tháng bán tốt nhất ở năm 2005



--3. Product line nào được bán nhiều ở tháng 11?
SELECT 
  productline,
  month_id,
  SUM(sales) AS revenue,
  COUNT(ordernumber) AS order_count
FROM 
  sales_dataset_rfm_prj_clean1
WHERE 
  month_id = 11
GROUP BY 
  productline, month_id
ORDER BY 
  revenue DESC;

-- sản phẩm được bán tốt nhất tháng 11 là classic cars - vintage cars và motor



-- 4. Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? Xếp hạng các doanh thu đó theo từng năm.

WITH yearly_sales_uk AS (
  SELECT 
    year_id,
    productline,
    SUM(sales) AS revenue
  FROM 
    sales_dataset_rfm_prj_clean1
  WHERE 
    country = 'UK'
  GROUP BY 
    year_id, productline
),
ranked_sales AS (
  SELECT 
    year_id,
    productline,
    revenue,
    RANK() OVER (PARTITION BY year_id ORDER BY revenue DESC) AS rank
  FROM 
    yearly_sales_uk
)
SELECT 
  year_id,
  productline,
  revenue,
  rank
FROM 
  ranked_sales
WHERE 
  rank = 1
ORDER BY 
  year_id, rank;


-- doanh thu tốt nhất là 2003-2004 classic cars với doanh số là 66705, năm 2005 là motor với doanh số là 40802



--5. Ai là khách hàng tốt nhất, phân tích dựa vào RFM (Recency, Frequency, Monetary)
-- Tính Recency, Frequency và Monetary
WITH rfm AS (
  SELECT 
    customername,
    MAX(orderdate) AS last_order_date,
    COUNT(ordernumber) AS frequency,
    SUM(sales) AS monetary,
    RANK() OVER (ORDER BY MAX(orderdate) DESC) AS recency_rank,
    RANK() OVER (ORDER BY COUNT(ordernumber) DESC) AS frequency_rank,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS monetary_rank
  FROM 
    sales_dataset_rfm_prj_clean1
  GROUP BY 
    customername
),
rfm_ranked AS (
  SELECT 
    customername,
    last_order_date,
    frequency,
    monetary,
    recency_rank,
    frequency_rank,
    monetary_rank,
    (recency_rank + frequency_rank + monetary_rank) AS rfm_score
  FROM 
    rfm
)
SELECT 
  customername,
  last_order_date,
  frequency,
  monetary,
  recency_rank,
  frequency_rank,
  monetary_rank,
  rfm_score
FROM 
  rfm_ranked
ORDER BY 
  rfm_score ASC
LIMIT 1;  -- Khách hàng có rfm_score thấp nhất là khách hàng tốt nhất


-- khách "Euro Shopping Channel" là khách có 259 lần thường xuyên mua lại và tổng giá trị là 912294.1100000002

