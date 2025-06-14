create database pizzahut;

use pizzahut;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

select * from orders;

select * from order_details;

select * from pizza_types;

select * from pizzas;

-- Basic:
-- 1.Retrieve the total number of orders placed.
select count(order_id) as no_of_orders from orders;

-- 2.Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price)) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- 3.Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
WHERE
    pizzas.price = (SELECT 
            MAX(pizzas.price)
        FROM
            pizzas);

-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS count_of_size
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY size DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) as quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Intermediate:


-- 1.Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category , sum(order_details.quantity) as total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category;


-- 2.Determine the distribution of orders by hour of the day.

select hour(time) as per_hour , count(order_id) from orders
group by per_hour;

-- 3.Join relevant tables to find the category-wise distribution of pizzas.

select category as per_category , count(name) from pizza_types
group by per_category;
-- 4.Group the orders by date and calculate the average number of pizzas(not the no of orders)ordered per day.

select orders.date from orders;
select round(avg(total_quantity),0) from
(select orders.date, sum(order_details.quantity) as total_quantity
from order_details join orders 
on order_details.order_id = orders.order_id group by orders.date) as avg_no_of_pizzas_per_day;


-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, 
sum(order_details.quantity * pizzas.price) as revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Advanced:

-- 1.Calculate the percentage contribution of each pizza type to total revenue.


SELECT 
    pizza_types.category,
    (SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2)
        FROM
            order_details
                JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC
;


-- 3.Analyze the cumulative revenue generated over time.

select sales.date , revenue,
sum(revenue) over(order by sales.date) as cum_revenue 
from (
select orders.date , 
sum(order_details.quantity * pizzas.price) as revenue
from orders join order_details 
on orders.order_id = order_details.order_id 
join pizzas on order_details.pizza_id = pizzas.pizza_id
group by orders.date) as sales
;


