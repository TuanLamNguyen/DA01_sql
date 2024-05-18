--ex1
SELECT 
sum(case 
when device_type ='laptop' then 1
else 0
end) as laptop_views,
sum(case 
when device_type ='laptop' then 0
else 01
end) as mobile_views
FROM viewership;

--ex2
select x,y,z,
case
when x+y>z and y+z>x and z+x>y then 'Yes' 
else 'No' 
end as triangle 
from triangle;

--ex3
select 
round(100.0*
SUM(
CASE 
when call_category is NULL OR call_category ='n/a' THEN 1 ELSE 0 
END)/ COUNT(case_id),1)
as uncategorised_call_pct
FROM callers;

--ex4
select name
from Customer
where coalesce(referee_id,'1') != 2;

--ex5
select 
survived,
sum(case when pclass = 1 THEN 1 ELSE 0 END ) as pclass_1,
sum(case when pclass = 2 THEN 1 ELSE 0 END ) as pclass_2,
sum(case when pclass = 3 THEN 1 ELSE 0 END ) as pclass_3
from titanic
group by survived;
