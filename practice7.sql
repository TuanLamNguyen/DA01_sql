--ex1
with cte as 
  (
SELECT EXTRACT(year from transaction_date) as year, product_id,  sum(spend) as curr_year_spend,
        lag(sum(spend), 1) OVER(PARTITION BY product_id ORDER BY EXTRACT(year from transaction_date)) as prev_year_spend
FROM user_transactions
GROUP BY product_id, EXTRACT(year from transaction_date)
order by product_id,EXTRACT(year from transaction_date)
)
select *, ROUND((100.0 * (curr_year_spend - prev_year_spend) / prev_year_spend),2) as yoy_rate
from cte;

--ex2

SELECT card_name, issued_amount
FROM
(
SELECT issue_month, card_name, issued_amount,
RANK() OVER(PARTITION BY card_name ORDER BY issue_year, issue_month) AS issue_rank
FROM monthly_cards_issued
) AS cards_first_distribution
WHERE issue_rank = 1
ORDER BY issued_amount DESC

--ex3
Select user_id,   spend, transaction_date
from 
(
SELECT *,  row_number() over (partition by user_id order by transaction_date) AS Ranking
FROM transactions
) AS RANKED
WHERE Ranking = 3

--ex4
WITH cte AS 
  (
  SELECT transaction_date, user_id,
  COUNT(product_id) OVER (PARTITION BY user_id, transaction_date) AS purchase_count,
  ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date DESC) AS row_rank
  FROM user_transactions
  ORDER BY user_id, transaction_date)

SELECT transaction_date, user_id, purchase_count
FROM cte
WHERE row_rank = 1
ORDER BY transaction_date, user_id;

--ex5

SELECT  user_id , tweet_date
  , ROUND(AVG(tweet_count) OVER(PARTITION BY user_id ORDER BY tweet_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
FROM tweets

--ex6
  
WITH t1 AS
  (
  SELECT   *,
  LEAD(transaction_timestamp) OVER(PARTITION BY merchant_id,credit_card_id ORDER BY transaction_timestamp) AS l_time
FROM transactions)

SELECT COUNT(credit_card_id)
FROM t1
WHERE EXTRACT(MINUTE FROM (l_time - transaction_timestamp)) < 10

--ex7

WITH CTE AS
(
SELECT CATEGORY,PRODUCT,SUM(SPEND) AS TOTAL_SPEND,RANK() OVER(PARTITION BY CATEGORY ORDER BY SUM(SPEND) DESC) AS RNK
FROM product_spend
WHERE EXTRACT(YEAR FROM TRANSACTION_DATE)=2022
GROUP BY  CATEGORY,PRODUCT)
  
SELECT  CATEGORY,PRODUCT,TOTAL_SPEND
FROM CTE WHERE RNK<=2

--ex8

WITH CTE as 
  (
SELECT a.artist_name, COUNT(a.artist_name), dense_rank()OVER(order by COUNT(a.artist_name) desc) as artist_rank
FROM artists as a
JOIN songs as s on a.artist_id = s.artist_id
JOIN global_song_rank as g on s.song_id = g.song_id
WHERE g.rank <= 10
GROUP BY a.artist_name
order by artist_rank)

SELECT artist_name, artist_rank
from CTE
where artist_rank < 6


