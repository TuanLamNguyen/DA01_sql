 --1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng
WITH monthly_data AS (
    SELECT
        DATE_TRUNC(created_at, MONTH) AS month,
        user_id,
        status
    FROM
        `bigquery-public-data.thelook_ecommerce.order_items`
    WHERE
        created_at BETWEEN '2019-01-01' AND '2022-04-30'
)
SELECT
    month,
    COUNT(DISTINCT user_id) AS unique_buyers,
    COUNT(CASE WHEN status = 'Shipped' THEN 1 END) AS completed_orders
FROM
    monthly_data
GROUP BY
    month
ORDER BY
    month;
--insight là số lượng người mua hàng và đặt đơn hàng tăng dần đều theo thời gian tuy nhiên tỷ lệ đặt thành công(đã giao hàng và không trả hàng) chỉ chiếm 50%




--2 tính AOV và tính insight
-- SQL query to calculate AOV and distinct users per month
WITH monthly_data AS (
    SELECT
        FORMAT_TIMESTAMP('%Y-%m', created_at) AS month_year,
        user_id,
        sale_price
    FROM
        `bigquery-public-data.thelook_ecommerce.order_items`
    WHERE
        created_at BETWEEN '2019-01-01' AND '2022-04-30'
)
SELECT
    month_year,
    COUNT(DISTINCT user_id) AS distinct_users,
    SUM(sale_price) / COUNT(*) AS average_order_value
FROM
    monthly_data
GROUP BY
    month_year
ORDER BY
    month_year;
-- người dùng mới ngày càng tăng và số lượng mua hàng trung bình hàng tháng giao động từ mức 50-60%






--3 . Nhóm khách hàng theo độ tuổi
-- Step 1: tìm tên tuổi nhỏ nhất và lớn nhất
WITH customer_ages AS (
    SELECT
        first_name,
        last_name,
        gender,
        age
    FROM
        `bigquery-public-data.thelook_ecommerce.users`
    WHERE
        created_at BETWEEN '2019-01-01' AND '2022-04-30'
),
min_max_ages AS (
    SELECT
        gender,
        MIN(age) AS min_age,
        MAX(age) AS max_age
    FROM
        customer_ages
    GROUP BY
        gender
),
youngest_customers AS (
    SELECT
        ca.first_name,
        ca.last_name,
        ca.gender,
        ca.age,
        'youngest' AS tag
    FROM
        customer_ages ca
    JOIN
        min_max_ages mma
    ON
        ca.gender = mma.gender AND ca.age = mma.min_age
),
oldest_customers AS (
    SELECT
        ca.first_name,
        ca.last_name,
        ca.gender,
        ca.age,
        'oldest' AS tag
    FROM
        customer_ages ca
    JOIN
        min_max_ages mma
    ON
        ca.gender = mma.gender AND ca.age = mma.max_age
),
youngest_oldest_customers AS (
    SELECT * FROM youngest_customers
    UNION ALL
    SELECT * FROM oldest_customers
)
-- Step 2: tính số lượng giới tính ở từng độ tuổi
SELECT
    tag,
    gender,
    COUNT(*) AS customer_count
FROM
    youngest_oldest_customers
GROUP BY
    tag,
    gender
ORDER BY
    tag,
    gender;

-- nhỏ nhất là 12 tuổi với nam là 535 , nữ là 533
-- lớn nhất là 70 tuổi vơi nam là 488 , nữ là 501





--4.Top 5 sản phẩm mỗi tháng.Thống kê top 5 sản phẩm có lợi nhuận cao nhất từng tháng (xếp hạng cho từng sản phẩm).

-- Step 1: tính doanh số và lợi nhuận từng tháng
WITH monthly_sales AS (
    SELECT
        FORMAT_TIMESTAMP('%Y-%m', oi.created_at) AS month_year,
        oi.product_id,
        SUM(oi.sale_price) AS sales,
        SUM(oi.sale_price - p.cost) AS profit,
        ANY_VALUE(p.name) AS product_name
    FROM
        `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    JOIN
        `bigquery-public-data.thelook_ecommerce.products` AS p
    ON
        oi.product_id = p.id
    WHERE
        oi.created_at BETWEEN '2019-01-01' AND '2022-04-30'
    GROUP BY
        month_year,
        oi.product_id
),
ranked_products AS (
    SELECT
        month_year,
        product_id,
        product_name,
        sales,
        profit,
        DENSE_RANK() OVER (PARTITION BY month_year ORDER BY profit DESC) AS rank_per_month
    FROM
        monthly_sales
)
-- Step 2: top 5 sản phẩm lợi nhuận cao nhất từng tháng
SELECT
    month_year,
    product_id,
    product_name,
    sales,
    profit,
    rank_per_month
FROM
    ranked_products
WHERE
    rank_per_month <= 5
ORDER BY
    month_year,
    rank_per_month;




--5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
-- Step 1: tính doanh thu mỗi ngày cho giả sử ngày hôm nay là 2022-04-15
WITH category_revenue AS (
    SELECT
        p.category AS product_category,
        SUM(oi.sale_price) AS revenue
    FROM
        `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    JOIN
        `bigquery-public-data.thelook_ecommerce.products` AS p
    ON
        oi.product_id = p.id
    WHERE
        DATE(oi.created_at) <= '2022-04-15' -- Lấy đến ngày hiện tại
    GROUP BY
        product_category
),
-- Step 2: rải doanh thu sp cho 3 tháng
category_revenue_last_3_months AS (
    SELECT
        p.category AS product_category,
        DATE_TRUNC(oi.created_at, MONTH) AS month,
        SUM(oi.sale_price) AS revenue
    FROM
        `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    JOIN
        `bigquery-public-data.thelook_ecommerce.products` AS p
    ON
        oi.product_id = p.id
    WHERE
        oi.created_at >= '2022-01-15' AND oi.created_at < '2022-04-15' -- Lấy dữ liệu trong 3 tháng qua
    GROUP BY
        product_category,
        month
)
-- Step 3: xuất ra 
SELECT
    FORMAT_DATE('%Y-%m-%d', DATE('2022-04-15')) AS date,
    product_category,
    revenue
FROM
    category_revenue
UNION ALL
SELECT
    FORMAT_DATE('%Y-%m-%d', month) AS date,
    product_category,
    revenue
FROM
    category_revenue_last_3_months
ORDER BY
    date,
    product_category;

  

