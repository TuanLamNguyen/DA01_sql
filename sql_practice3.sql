--ex1
select name
from STUDENTS
where marks>75
order by right(name,3), id asc ;

--ex2
SELECT user_id, 
       CONCAT(UPPER(LEFT(name, 1)), LOWER(SUBSTRING(name from 2 for length(name)-1))) AS name
FROM Users
ORDER BY user_id;

--ex3
SELECT manufacturer,
concat('$', round(sum(total_sales)/10^6),' ', 'million')  as sale
FROM pharmacy_sales
group by manufacturer
order by sum(total_sales) desc, manufacturer asc;

--ex4
SELECT 
extract(month from submit_date) as mth,
product_id,
round(avg(stars),2) as avg_stars
FROM reviews
group by extract(month from submit_date), product_id
order by mth,product_id

--ex5
SELECT sender_id, 
count(content) as message_count
FROM messages
WHERE extract(month from sent_date)=8 AND 
extract(year from sent_date) = 2022
group by sender_id
order by message_count DESC
limit 2

--ex6
select tweet_id
from Tweets
where length(content) >15

--ex7












