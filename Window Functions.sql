WINDOW FUNCTIONS

select * from payment

Q. Find all the spending by a customer (customer_id)
select *, sum(amount) over(partition by customer_id) as total_amount_by_customer from payment

Q. Find how many times a customer made the purchase
select *, count(*) over(partition by customer_id) as total_amount_by_customer from payment

Main: Group/partition by 2 column or more column
Q. How many transcations did each customer have for each of the staff_id i.e how many sales occur for each of the staff_id for each customer.
select *, count(*) over(partition by customer_id, staff_id) from payment

Challenge 1: Write a query that returns the list of movies including: film_id, title, length, category, avg_length_of_movies_in_that_category. Order the results by film_id

select f.film_id, title, length, c.name as category, c.category_id, round(avg(length) over(partition by c.category_id),2) as avg_length_in_category 
from film f
left join film_category fc 
on f.film_id = fc.film_id
left join category c
on fc.category_id = c.category_id
order by f.film_id

Challenge 2: Write a query that returns all payment details including the number of payments that were made by this customer and that amount. Order the results by payment_id

select *, count(*) over(partition by customer_id, amount) from payment
order by payment_id

TOPIC: Over() with ORDER BY
Q. Add the amount value by date daily
select *, sum(amount) over (order by payment_date) from payment

Q. Add the amount value by date daily by customer_id
select *, sum(amount) over (partition by customer_id order by payment_date) from payment

Challenge 3: Write a query that returns the running total of how late the flights are (diff between actual_arrival and scheduled arriaval) ordered by flight_id including the departure airport.
As a second query, calculate the same running total but partition also by tge departure airport.

select flight_id, departure_airport, sum(actual_arrival - scheduled_arrival) over(order by flight_id) 
from  flights

select flight_id, departure_airport, sum(actual_arrival - scheduled_arrival) over(partition by departure_airport order by flight_id) 
from  flights

TOPIC: RANK() and DENSE_RANK
Q. Rank category-wise: rank films category-wise by length of films
select f.title, c.name, f.length, rank() over(partition by name order by length desc) 
from film f
left join film_category fc on f.film_id = fc.film_id
left join category c on c.category_id = fc.category_id 

select f.title, c.name, f.length, dense_rank() over(partition by name order by length desc) 
from film f
left join film_category fc on f.film_id = fc.film_id
left join category c on c.category_id = fc.category_id 

-- window fuction doesn't work for filter & after where, so if you want to use them as a filter; use them in sub-query
select * from (select f.title, c.name, f.length, dense_rank() over(partition by name order by length desc) as rank 
				from film f
				left join film_category fc on f.film_id = fc.film_id
				left join category c on c.category_id = fc.category_id ) a 
where rank = 1

Challenge 4: Write a query that returns the customer name, the country and how many payments they have. For that use the existing view customer_list.
Afterwards create a ranking of the top customers with most sales for each country. Filter the results to only the top 3 customers per country. 

select * from (
				select name, country, count(*),
				rank() over(partition by country order by count(*) desc) as rank
				from customer_list
				left join payment on id=customer_id
				group by name, country) a 
where rank between 1 and 3

Challenge 5: Write a query that returns the revenue of the day and the revenue of the previous day.
Aferwards calculate also the percentage growth compared to the previous day.

select 
sum(amount), 
date(payment_date) as day,
lag(sum(amount)) over(order by date(payment_date)) as previous_day,
sum(amount) - lag(sum(amount)) over(order by date(payment_date)) as difference,
round((sum(amount) - lag(sum(amount)) over(order by date(payment_date))) / lag(sum(amount)) over(order by date(payment_date))*100,2) as percentage_growth
from payment
group by date(payment_date)

