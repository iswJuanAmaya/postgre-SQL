select * from orders
select * from order_items
select * from locations 
select * from pos_sync_logs  

1
select p.order_id, p.error_message, l.location_name, o.subtotal from pos_sync_logs p
inner join orders o using(order_id)
inner join locations l on o.location_id = l.location_id 
where sync_status = 'Failed'

2
select channel, sum(subtotal) as total_revenue, round(avg(subtotal),2) average_subtotal, count(*) as completed_orders from orders where order_status = 'Completed' 
group by channel having sum(subtotal) > 40

3
select order_id, subtotal from orders where order_status = 'Cancelled'  
and location_id in (
	select location_id from orders where order_status = 'Completed' group by location_id having avg(subtotal) > 30
	)

4
WITH CTE_completed AS (
    SELECT location_id FROM orders WHERE order_status = 'Completed' GROUP BY location_id HAVING AVG(subtotal) > 30
)
SELECT o.order_id, o.subtotal FROM orders o
INNER JOIN CTE_completed c USING(location_id)
WHERE o.order_status = 'Cancelled';

5
select order_id, order_timestamp, subtotal,channel, SUM(subtotal) OVER(
partition by channel  order by order_timestamp) running_total 
from orders where order_status = 'Completed'	

6 
select order_id, order_timestamp, subtotal from orders where order_id not in (
	select order_id from pos_sync_logs 	
)

7
select order_id, order_timestamp, subtotal from orders
left join pos_sync_logs psl using(order_id) where psl.order_id is null
7.5
SELECT order_id, order_timestamp, subtotal 
FROM orders o
WHERE NOT EXISTS (
    SELECT 1 
    FROM pos_sync_logs psl 
    WHERE psl.order_id = o.order_id
);

8
with cte_sum_calculated as(
		select order_id, sum(price*quantity) as calculated_sum from order_items group by order_id 
	)
select order_id, subtotal, calculated_sum  from orders o
inner join cte_sum_calculated csc using(order_id)
where subtotal != calculated_sum

9
select l.location_name,
	sum(case order_status when 'Cancelled' then subtotal else 0 end) "Cancelled",
	sum(case order_status when 'Refunded' then subtotal else 0 end) "Refunded"
from orders 
inner join locations l using(location_id)
where order_status in ('Cancelled', 'Refunded') and city = 'Chicago' 
group by location_name
9.5
SELECT l.location_name,
       SUM(CASE order_status WHEN 'Cancelled' THEN subtotal ELSE 0 END) AS "Cancelled",
       SUM(CASE order_status WHEN 'Refunded' THEN subtotal ELSE 0 END) AS "Refunded"
FROM locations l
LEFT JOIN orders o USING(location_id) -- Using LEFT JOIN ensures we don't drop locations with no orders
WHERE l.city = 'Chicago' 
GROUP BY l.location_name;

10
select * from orders where order_status = 'Completed' and channel = 'Online' and order_timestamp >= CURRENT_DATE - interval '1 DAY' and subtotal between 20 and 30 

11
select * from pos_sync_logs where LOWER(error_message) like '%api%'

12
select sum(subtotal), max(subtotal), min(subtotal) from orders

13
select order_id from pos_sync_logs group by order_id having count(order_id)>1

14 
A
WITH cte_o_i AS (
    SELECT order_id, SUM(price * quantity) AS sum_per_order 
    FROM order_items 
    GROUP BY order_id
)
SELECT AVG(o.subtotal - cte.sum_per_order) AS average_discrepancy
FROM orders o
INNER JOIN cte_o_i cte USING(order_id)
WHERE o.order_status = 'Completed' 
  AND o.channel = 'Online' 
  AND o.location_id = 101
B
select pos_system, count(*) from pos_sync_logs psl
inner join orders o using(order_id)
inner join locations l using(location_id)
where sync_status = 'Failed' group by l.pos_system order by count(*) desc 

15
a
select sync_timestamp, order_id, row_number() OVER(PARTITION BY order_id order by sync_timestamp desc) from pos_sync_logs  
b
select order_id, location_id, subtotal, rank() over(
		partition by location_id order by subtotal desc
) 
from orders
c
select order_id, order_timestamp, LAG(order_timestamp) over(order by order_timestamp asc) as previous_order_time from orders

16
select item_name, price from order_items where price>15 order by price desc 
select distinct item_name from order_items order by item_name asc

select location_name from locations where location_id not in(
	select location_id from orders where channel = 'Online'
)


select location_id, count(*) from orders group by location_id having count(*)>50

17
a
select max(subtotal) from orders
b1
select order_id, subtotal from orders order by subtotal desc limit 1 offset 1
b2
with cte as (
	select order_id, subtotal, dense_rank() over(order by subtotal desc) as top from orders
)
select order_id, subtotal from cte where top = 2

18
select o.location_id, l.location_name, sum(o.subtotal)
from orders  o
left join locations l using(location_id)
group by location_id, l.location_name

19
SELECT o.location_id, 
       l.location_name, 
       SUM(o.subtotal) AS location_total,
       round((SUM(o.subtotal) / SUM(SUM(o.subtotal)) OVER ()) * 100,2)::varchar || '%' AS location_sales_percent
FROM orders o
LEFT JOIN locations l USING(location_id)
GROUP BY o.location_id, l.location_name;




























