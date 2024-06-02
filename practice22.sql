-- tạo dateset theo yêu cầu

WITH monthly_sales_orders AS (
   SELECT
        FORMAT_TIMESTAMP('%Y-%m', oi.created_at) AS Month,
        EXTRACT(YEAR FROM oi.created_at) AS Year,
        p.category AS Product_category,
        SUM(oi.sale_price) AS TPV,
        COUNT(DISTINCT oi.order_id) AS TPO
    FROM
        `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    JOIN
        `bigquery-public-data.thelook_ecommerce.products` AS p
    ON
        oi.product_id = p.id
    WHERE
        oi.created_at BETWEEN '2019-01-01' AND '2022-04-30'
    GROUP BY
        Month, Year, Product_category
),
-- Step 2: tính toán total cost and total profit cho mỗi tháng
monthly_cost_profit AS (
    SELECT
        FORMAT_TIMESTAMP('%Y-%m', oi.created_at) AS Month,
        p.category AS Product_category,
        SUM(p.cost) AS Total_cost,
        SUM(oi.sale_price - p.cost) AS Total_profit
    FROM
        `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    JOIN
        `bigquery-public-data.thelook_ecommerce.products` AS p
    ON
        oi.product_id = p.id
    WHERE
        oi.created_at BETWEEN '2019-01-01' AND '2022-04-30'
    GROUP BY
        Month, Product_category
),
-- Step 3: kết hợp và tính toán các trường
combined_data AS (
    SELECT
        ms.Month,
        ms.Year,
        ms.Product_category,
        ms.TPV,
        ms.TPO,
        mc.Total_cost,
        mc.Total_profit,
        ROUND((ms.TPV - LAG(ms.TPV) OVER (PARTITION BY ms.Product_category ORDER BY ms.Month)) / LAG(ms.TPV) OVER (PARTITION BY ms.Product_category ORDER BY ms.Month) * 100, 2) AS Revenue_growth,
        ROUND((ms.TPO - LAG(ms.TPO) OVER (PARTITION BY ms.Product_category ORDER BY ms.Month)) / LAG(ms.TPO) OVER (PARTITION BY ms.Product_category ORDER BY ms.Month) * 100, 2) AS Order_growth,
        ROUND(mc.Total_profit / mc.Total_cost, 2) AS Profit_to_cost_ratio
    FROM
        monthly_sales_orders AS ms
    JOIN
        monthly_cost_profit AS mc
    ON
        ms.Month = mc.Month AND ms.Product_category = mc.Product_category
)
-- Step 4: xuất output
SELECT
    ROW_NUMBER() OVER (ORDER BY Month, Product_category) AS STT,
    Month,
    Year,
    Product_category,
    TPV,
    TPO,
    IFNULL(Revenue_growth, 0) AS Revenue_growth, -- Handle NULL for first month
    IFNULL(Order_growth, 0) AS Order_growth, -- Handle NULL for first month
    Total_cost,
    Total_profit,
    Profit_to_cost_ratio
FROM
    combined_data
ORDER BY
    Month, Product_category;








-- vẽ cohort chart
--tạo bảng data

WITH online_retail_index AS (
    SELECT 
        oi.user_id AS customerid,
        oi.sale_price AS amount,
        FORMAT_TIMESTAMP('%Y-%m', first_purchase_date) AS cohort_date,
        oi.created_at AS invoicedate,
        (EXTRACT(YEAR FROM oi.created_at) - EXTRACT(YEAR FROM first_purchase_date)) * 12
            + (EXTRACT(MONTH FROM oi.created_at) - EXTRACT(MONTH FROM first_purchase_date)) + 1 AS index
    FROM (
        SELECT 
            user_id,
            sale_price,
            MIN(created_at) OVER (PARTITION BY user_id) AS first_purchase_date,
            created_at
        FROM 
            `bigquery-public-data.thelook_ecommerce.order_items`
    ) oi
)
-- Step 2: 
SELECT 
    cohort_date,
    index,
    COUNT(DISTINCT customerid) AS cnt,
    SUM(amount) AS revenue
FROM 
    online_retail_index
WHERE
    index BETWEEN 1 AND 4
GROUP BY 
    cohort_date, 
    index
ORDER BY 
    cohort_date, 
    index;

https://docs.google.com/spreadsheets/d/1oXYhWG7p31VeKYr5rusuTBEID83HYF2yjQvBZzY7aUs/edit#gid=1650600632

-- insight 
-- tỷ lệ người dùng mới tăng dần theo thời gian
-- tỷ lệ rời bỏ rất cao
-- tỷ lệ retention quá thấp
--  => sản phẩm có vấn đề, cần liên lạc bộ phận marketing hoặc là do nhóm ngành ( sản phẩm cao cấp hoặc xa xỉ, thời hạn sử dụng lâu như xe hơi , giường,....)




