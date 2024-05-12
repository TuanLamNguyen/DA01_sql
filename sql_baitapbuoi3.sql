--EX1
select name from city 
where CountryCode='USA' and population >120000;

--EX2 
select * from CITY
where COUNTRYCODE='JPN';

--EX3
select city, state from station;

--EX4
select distinct CITY from station
where city like 'I%' or city like 'E%' or city like 'A%' or city like 'U%' or city like 'O%';

--EX5
select distinct CITY from station
where city like '%i' or city like '%e' or city like '%a' or city like '%u' or city like '%o';

--EX6
select distinct CITY from station
where not ( city like 'I%' or city like 'E%' or city like 'A%' or city like 'U%' or city like 'O%');

--EX7
select name from Employee
order by name asc;

--EX8
select name from Employee
where salary>2000 and months<10
order by employee_id asc;

--EX9
select product_id from Products
where low_fats ='Y' and recyclable= 'y';

--EX10
--cach 1
select name from Customer
where referee_id != 2 or referee_id is null;
--cách 2
select name from customer where referee_id != 2 is not false;

--EX11
select name, population,area from World
where area >= 3000000 or population>=25000000;

--EX12
select distinct author_id as id from Views
where author_id=viewer_id and viewer_id >=1
order by author_id asc;

--EX13
SELECT part,assembly_step FROM parts_assembly
where finish_date is NULL;

















