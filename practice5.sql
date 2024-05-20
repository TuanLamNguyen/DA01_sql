--ex1
select COUNTRY.Continent, floor(avg(CITY.Population))
from CITY inner join COUNTRY on CITY.CountryCode = COUNTRY.Code
group by COUNTRY.Continent;

--ex2
SELECT ROUND(1.0*SUM(CASE 
        WHEN b.signup_action='Confirmed' THEN 1
        ELSE 0
        END)/COUNT(b.email_id),2) AS confirm_rate
FROM emails AS a
LEFT JOIN texts AS b
ON a.email_id=b.email_id;

--ex3
SELECT 
    a.age_bucket,
    ROUND(
    SUM(CASE WHEN b.activity_type = 'send' THEN b.time_spent ELSE 0 END) * 100.0 / 
    SUM(CASE WHEN b.activity_type IN ('send', 'open') THEN b.time_spent ELSE 0 END), 2) 
    AS send_perc,
    ROUND(
    SUM(CASE WHEN b.activity_type = 'open' THEN b.time_spent ELSE 0 END) * 100.0 / 
    SUM(CASE WHEN b.activity_type IN ('send', 'open') THEN b.time_spent ELSE 0 END), 2) 
    AS open_perc
FROM age_breakdown a
JOIN activities b ON A.user_id = b.user_id
WHERE b.activity_type IN ('send', 'open')
GROUP BY a.age_bucket;

--ex4
SELECT customer_id 
FROM customer_contracts as c 
inner join products as p on c.product_id = p.product_id 
GROUP BY c.customer_id
having count(distinct p.product_category) =3 
order by customer_id;

--ex5
SELECT
a.employee_id, a.name,
COUNT(b.reports_to) AS reports_count,
ROUND(AVG(b.age * 1.0), 0) AS average_age
FROM employees as a
INNER JOIN employees as b ON a.employee_id = b.reports_to
WHERE b.reports_to IS NOT NULL
GROUP BY a.employee_id,a.name
ORDER BY a.employee_id;

--ex6
SELECT a.product_name, 
SUM(b.unit) AS unit 
FROM Products AS a 
INNER JOIN Orders AS b ON a.product_id = b.product_id 
WHERE b.order_date BETWEEN '2020-02-01' AND '2020-02-29' 
GROUP BY a.product_name
HAVING SUM(b.unit) >= 100;

--ex7
SELECT a.page_id
FROM pages as a
LEFT JOIN page_likes as b ON a.page_id = b.page_id
WHERE b.page_id is null
ORDER BY page_id ASC;
























