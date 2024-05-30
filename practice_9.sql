select * from public.sales_dataset_rfm_prj;

-- Thay thế giá trị trống bằng NULL cho các cột văn bản
UPDATE SALES_DATASET_RFM_PRJ
SET ordernumber = NULLIF(TRIM(ordernumber), ''),
    customername = NULLIF(TRIM(customername), ''),
    phone = NULLIF(TRIM(phone), ''),
    addressline1 = NULLIF(TRIM(addressline1), ''),
    addressline2 = NULLIF(TRIM(addressline2), ''),
    city = NULLIF(TRIM(city), ''),
    state = NULLIF(TRIM(state), ''),
    postalcode = NULLIF(TRIM(postalcode), ''),
    country = NULLIF(TRIM(country), ''),
    territory = NULLIF(TRIM(territory), ''),
    contactfullname = NULLIF(TRIM(contactfullname), ''),
    dealsize = NULLIF(TRIM(dealsize), '');

-- Chuyển đổi kiểu dữ liệu phù hợp cho các trường
ALTER TABLE SALES_DATASET_RFM_PRJ 
  ALTER COLUMN quantityordered TYPE INTEGER USING NULLIF(TRIM(quantityordered), '')::INTEGER,
  ALTER COLUMN priceeach TYPE NUMERIC USING NULLIF(TRIM(priceeach), '')::NUMERIC,
  ALTER COLUMN orderlinenumber TYPE INTEGER USING NULLIF(TRIM(orderlinenumber), '')::INTEGER,
  ALTER COLUMN sales TYPE NUMERIC USING NULLIF(TRIM(sales), '')::NUMERIC,
  ALTER COLUMN orderdate TYPE DATE USING NULLIF(TRIM(orderdate), '')::DATE,
  ALTER COLUMN msrp TYPE INTEGER USING NULLIF(TRIM(msrp), '')::INTEGER;

--thêm các cột mới để lưu trữ tên và họ đã tách từ cột contactfullname.
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN contactlastname VARCHAR,
ADD COLUMN contactfirstname VARCHAR;

--cập nhật các cột tên bằng cách tách giá trị từ contactfullname và chuẩn hóa
UPDATE SALES_DATASET_RFM_PRJ
SET contactlastname = INITCAP(SPLIT_PART(contactfullname, '-', 1)),
    contactfirstname = INITCAP(SPLIT_PART(contactfullname, '-', 2));

--Thêm các cột mới để lưu trữ quý, tháng và năm từ orderdate.
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN qtr_id INTEGER,
ADD COLUMN month_id INTEGER,
ADD COLUMN year_id INTEGER;

--Cập nhật các cột mới với các giá trị tương ứng từ orderdate.
UPDATE SALES_DATASET_RFM_PRJ
SET qtr_id = EXTRACT(QUARTER FROM orderdate),
    month_id = EXTRACT(MONTH FROM orderdate),
    year_id = EXTRACT(YEAR FROM orderdate);

-- Tính toán các giá trị Q1 (25th percentile), Q3 (75th percentile) và IQR
WITH stats AS (
  SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantityordered) AS q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantityordered) AS q3
  FROM SALES_DATASET_RFM_PRJ
),
iqr_calc AS (
  SELECT 
    q1,
    q3,
    (q3 - q1) * 1.5 AS iqr
  FROM stats
)
-- Tìm các outliers
SELECT * 
FROM SALES_DATASET_RFM_PRJ, iqr_calc
WHERE quantityordered < (q1 - iqr) OR quantityordered > (q3 + iqr);


--Xử lý các outlier: Có thể lựa chọn hai cách để xử lý các bản ghi có giá trị outlier trong quantityordered.

--cách 1: Xóa các bản ghi có outlier:
/*DELETE FROM SALES_DATASET_RFM_PRJ
WHERE quantityordered < (SELECT q1 - (iqr * 1.5) FROM iqr_calc)
   OR quantityordered > (SELECT q3 + (iqr * 1.5) FROM iqr_calc);
*/

--cách 2 : Thay thế các giá trị outlier bằng giá trị trung bình hoặc giá trị khác phù hợp:

UPDATE SALES_DATASET_RFM_PRJ
SET quantityordered = (SELECT AVG(quantityordered) FROM SALES_DATASET_RFM_PRJ)
WHERE quantityordered < (SELECT q1 - (iqr * 1.5) FROM iqr_calc)
   OR quantityordered > (SELECT q3 + (iqr * 1.5) FROM iqr_calc);

-- các giá trị tính toán từ truy vấn trên là:
-- q1 = 27
-- q3 = 43
-- iqr = 24 ... Sử dụng các giá trị này trong câu lệnh UPDATE
UPDATE SALES_DATASET_RFM_PRJ
SET quantityordered = (
  SELECT AVG(quantityordered::INTEGER)::INTEGER 
  FROM SALES_DATASET_RFM_PRJ
)
WHERE quantityordered::INTEGER < (27 - 24) 
   OR quantityordered::INTEGER > (43 + 24);


--Lưu vào bảng mới SALES_DATASET_RFM_PRJ_CLEAN
CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS
SELECT * FROM SALES_DATASET_RFM_PRJ;

--kiểm tra bảng mới
SELECT * FROM SALES_DATASET_RFM_PRJ_CLEAN;






