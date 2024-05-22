--ex1
WITH count_of_dup_jobs 
  as ( SELECT company_id 
  FROM job_listings 
  GROUP BY company_id 
  HAVING COUNT(title) > 1 )

SELECT COUNT(*) FROM count_of_dup_jobs

--ex2
WITH spending AS(
SELECT
  category,
  product,
  SUM(spend) AS total_spend,
  RANK() OVER(PARTITION BY category ORDER BY SUM(spend) DESC) ranking
  
FROM product_spend
WHERE EXTRACT(YEAR FROM transaction_date) = 2022
GROUP BY category, product)

SELECT
  category,
  product,
  total_spend
FROM spending
WHERE ranking <= 2

--ex3
SELECT COUNT(policy_holder_id) as member_count
FROM 
  (SELECT policy_holder_id, COUNT(case_id)
  FROM callers
  GROUP BY policy_holder_id
  HAVING COUNT(case_id)>= 3)  
  as call_count ;

--ex4
SELECT page_id 
  FROM pages 
  WHERE page_id NOT IN (SELECT page_id from page_likes);

--ex5
WITH 
june_activity AS (
  SELECT event_date, user_id
  FROM user_actions
  WHERE EXTRACT(MONTH FROM event_date) = '6'), 
july_activity AS (
  SELECT event_date, user_id
  FROM user_actions
  WHERE EXTRACT(MONTH FROM event_date) = '7'),
active_users AS (
  SELECT DISTINCT july.user_id
  FROM june_activity AS june
  INNER JOIN july_activity AS july
  ON june.user_id = july.user_id)

SELECT 
  EXTRACT(MONTH FROM '07/01/2022'::DATE) AS "month", 
  COUNT(user_id) AS "monthly_active_users"
FROM active_users

--ex6

WITH temp AS
(SELECT * , DATE_FORMAT(trans_date,"%Y-%m") AS month
FROM Transactions)

SELECT temp.month, temp.country, COUNT(*) AS trans_count,
SUM(CASE WHEN temp.state = "approved" THEN 1 ELSE 0 END) AS approved_count,
SUM(temp.amount) AS trans_total_amount,
SUM(CASE WHEN temp.state = "approved" THEN amount ELSE 0 END ) as approved_total_amount
FROM temp
GROUP BY temp.month, temp.country;

--ex7

WITH FirstYearSales AS (
    SELECT s.product_id, MIN(s.year) AS first_year
    FROM Sales as s
    GROUP BY s.product_id)
  
SELECT fys.product_id, fys.first_year, s.quantity, s.price
FROM FirstYearSales as fys
JOIN Sales as s ON fys.product_id = s.product_id AND fys.first_year = s.year
ORDER BY fys.product_id;

--ex8

SELECT c.customer_id FROM Customer c
GROUP BY c.customer_id
HAVING count(DISTINCT product_key) = (SELECT count(*) FROM Product);

--ex9
select employee_id 
  from Employees 
  where salary <30000
  and manager_id not in (select employee_id from Employees)
order by employee_id;

--ex10
select count(dup) as "duplicate_companies"
from (select count(job_id) as "dup" from job_listings
group by company_id, title, description) as "titdes_dup"
where titdes_dup.dup > 1

--ex11
(with cte as
(select mr.user_id, name 
  from Users u, MovieRating mr
where u.user_id = mr.user_id)
select name as results from cte
group by user_id
order by count(*) desc, name asc
limit 1)
  
Union all
  
(with cte as
(select m.title, mr.rating 
  from Movies m, MovieRating mr
where m.movie_id = mr.movie_id
and month(created_at) = 2
and year(created_at)=2020)
select title as results from cte
group by title
order by avg(rating) desc, title asc
limit 1)

--ex12

WITH CTE AS(
SELECT requester_id , accepter_id
FROM RequestAccepted
UNION ALL
SELECT accepter_id , requester_id
FROM RequestAccepted)
  
SELECT requester_id id, count(accepter_id) num
FROM CTE
group by 1
ORDER BY 2 DESC
LIMIT 1;

