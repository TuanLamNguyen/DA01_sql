--ex1
select distinct CITY from STATION
where id%2=0

--ex2
select 
(count(city) - count(distinct city)) as _dif_total_city
from STATION

--ex3
--ex4
SELECT 
round(sum(item_count*order_occurrences)::numeric / sum(order_occurrences), 1) as mean
FROM items_per_order;

--ex5
SELECT candidate_id FROM candidates
WHERE skill in ('Python', 'Tableau', 'PostgreSQL')
group by (candidate_id)
having count(skill)=3;

--ex6
SELECT user_id,
(Date(max(post_date))-date(min(post_date))) as days_between
FROM posts
where date(post_date) between '01/01/2021' and '01/01/2022'
group by (user_id)
having count(post_date)>=2
order by user_id asc;

--ex7

SELECT card_name,
(max(issued_amount)- min(issued_amount)) as difference
FROM monthly_cards_issued
group by (card_name)
order by difference DESC

--ex8
SELECT manufacturer,
count(drug) as drug_count,
sum(abs(total_sales-cogs)) as total_loss
FROM pharmacy_sales
where total_sales-cogs<0
group by (manufacturer)
order by total_loss desc ;

--ex9
select id,movie,description,rating
 from Cinema
 where description != 'boring'
 and id %2!=0
 order by rating desc;

--ex10
select teacher_id,
count(distinct subject_id) as cnt
from Teacher
group by teacher_id;

--ex11
select user_id,
count(follower_id) as followers_count
from Followers
group by user_id
order by user_id asc;

--ex12
select class
from Courses
group by (class)
having  count(student) >=5;


