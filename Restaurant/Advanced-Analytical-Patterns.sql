select * from orders
select * from order_items
select * from locations 
select * from pos_sync_logs  


/* 1
Write a query that returns the order_id, the location_name, the subtotal, and the error_message for all orders that failed to sync.
*/
select p.order_id, p.error_message, l.location_name, o.subtotal from pos_sync_logs p
inner join orders o using(order_id)
inner join locations l on o.location_id = l.location_id 
where sync_status = 'Failed'


/* Challenge 2: The Business Performance Report
Scenario: The operations team wants to analyze their sales channels (In-Store, Online, UberEats) across all locations to see which ones are performing well and which ones might have issues. They only care about Completed orders.

Your Task: Write a query that shows:
The channel
The total revenue for that channel
The average subtotal per order for that channel (rounded to 2 decimal places)
The total number of completed orders for that channel

Bonus Filter: The team only wants to see channels that have generated a total revenue greater than $30.00.
*/
select channel, sum(subtotal) as total_revenue, round(avg(subtotal),2) average_subtotal, count(*) as completed_orders from orders where order_status = 'Completed' 
group by channel having sum(subtotal) > 40


/* Challenge 3: Identifying High-Value Casualties
Scenario: The support team is investigating customer complaints about order cancellations. The product manager wants to look into the financial impact of these cancellations, specifically focusing on locations that handle high-value transactions.

Your Task: Write a query to find the order_id and subtotal of all Cancelled orders, but only if that order belongs to a location whose average completed order subtotal is greater than $30.00.
*/
select order_id, subtotal from orders where order_status = 'Cancelled'  
and location_id in (
	select location_id from orders where order_status = 'Completed' group by location_id having avg(subtotal) > 30
	)


/*Challenge 4: The CTE Transition
Your Task: Take the exact same logic from your previous answer (finding order_id and subtotal for Cancelled orders where the location's average completed order is > 30) and rewrite it using a CTE instead of an inline subquery.
*/
WITH CTE_completed AS (
    SELECT location_id FROM orders WHERE order_status = 'Completed' GROUP BY location_id HAVING AVG(subtotal) > 30
)
SELECT o.order_id, o.subtotal FROM orders o
INNER JOIN CTE_completed c USING(location_id)
WHERE o.order_status = 'Cancelled';

/*Challenge 5: Moving to Window Functions (Topic 7)
Scenario: The accounting team needs a daily ledger report. They want to see a running list of completed orders, but they want to keep track of how the total revenue accumulates throughout the day.
Your Task: Write a query for all Completed orders that returns:
order_id
order_timestamp
subtotal
A new column called running_total that calculates the cumulative sum of the subtotal ordered by the order_timestamp ascending.
*/
select order_id, order_timestamp, subtotal, SUM(subtotal) OVER(order by order_timestamp) running_total
from orders where order_status = 'Completed'

/*Challenge 6: Partitioning the Window
Now let's take that exact same concept and add the next layer of window functions: PARTITION BY.
Scenario: The operations team wants that same running total report, but they don't want the revenue mixed together. They want the running total to calculate independently for each sales channel.
Your Task: Modify your previous query so that the running_total calculates a cumulative sum of the subtotal (ordered by order_timestamp), but it resets the calculation back to zero when it switches to a new channel.
Your output should include: order_id, channel, order_timestamp, subtotal, and the new running_total.
*/
select order_id, order_timestamp, subtotal,channel, SUM(subtotal) OVER(partition by channel  order by order_timestamp) running_total 
from orders where order_status = 'Completed'	

/*Challenge 7: Detecting Missing Sync Logs (Topic 3 & 4)
Scenario: When an order is placed, the system must create a corresponding row in the pos_sync_logs table, even if that log status is 'Failed'. If an order exists in the orders table but has absolutely no record in pos_sync_logs, it means the integration pipeline crashed completely before it could even log an error.
The engineering team needs a list of these "ghost" orders so they can re-sync them manually.
Your Task: Write a query that returns the order_id, order_timestamp, and subtotal for all Completed orders that do not exist in the pos_sync_logs table at all.
Constraint: There are at least two different ways to solve this (e.g., using a specific type of JOIN, or using a subquery operator like NOT EXISTS or NOT IN). Choose whichever method you prefer, but write the cleanest version you can.
*/
select order_id, order_timestamp, subtotal from orders where order_id not in (
	select order_id from pos_sync_logs 	
)
-- 
select order_id, order_timestamp, subtotal from orders
left join pos_sync_logs psl using(order_id) where psl.order_id is null
--
/* 7.5 
If the subquery inside a NOT IN returns even a single NULL value, the entire outer query will return zero results. This happens because of how SQL evaluates three-valued logic (something != NULL is UNKNOWN).
Because of this trap, your second approach—the LEFT JOIN with a WHERE ... IS NULL check—is considered the safer, more robust industry standard. Another excellent option is NOT EXISTS 
*/
SELECT order_id, order_timestamp, subtotal 
FROM orders o
WHERE NOT EXISTS (
    SELECT 1 
    FROM pos_sync_logs psl 
    WHERE psl.order_id = o.order_id
);

/*Challenge 8: Deep Dive into Order Items (Topic 4 & 5)
Let's test your ability to handle granular data discrepancies across multiple relationships.
Scenario: The support team is tracking down a rounding bug between the total recorded on the order header and the actual sum of the item prices multiplied by their quantities inside the order.
Your Task: Write a query that calculates the actual calculated cost for each order based on the items, and compares it to the header total.
The output must show:
The order_id
The subtotal (from the orders table)
A calculated column named calculated_total (which is the sum of price * quantity for all items in that order from the order_items table).
Filter: Only show rows where the subtotal does not match the calculated_total.
*/
with cte_sum_calculated as(
		select order_id, sum(price*quantity) as calculated_sum from order_items group by order_id 
	)
select order_id, subtotal, calculated_sum  from orders o
inner join cte_sum_calculated csc using(order_id)
where subtotal != calculated_sum

/* Challenge 9: The Final Boss (Combining CTEs, Joins, and Case Statuses)
Let's do one final, comprehensive question that mimics a real-world scenario you'd handle at CSs.
Scenario: The finance department needs a "Loss Report" for the locations in Chicago. They want to see how much money was lost due to bad orders, but they need to categorize the losses.
Your Task: Write a query that returns the location_name and two calculated financial columns:
cancelled_loss: The total sum of subtotal for orders that have an order_status of 'Cancelled'.
refunded_loss: The total sum of subtotal for orders that have an order_status of 'Refunded'.
Constraints:
Only include locations in the city of Chicago.
If a location has $0.00 in losses for a category, it should display 0.00 (Hint: CASE WHEN statements inside your aggregation functions will be your best friend here).
*/
select l.location_name,
	sum(case order_status when 'Cancelled' then subtotal else 0 end) "Cancelled",
	sum(case order_status when 'Refunded' then subtotal else 0 end) "Refunded"
from orders 
inner join locations l using(location_id)
where order_status in ('Cancelled', 'Refunded') and city = 'Chicago' 
group by location_name
-- 9.5 LLM correction
SELECT l.location_name,
       SUM(CASE order_status WHEN 'Cancelled' THEN subtotal ELSE 0 END) AS "Cancelled",
       SUM(CASE order_status WHEN 'Refunded' THEN subtotal ELSE 0 END) AS "Refunded"
FROM locations l
LEFT JOIN orders o USING(location_id) -- Using LEFT JOIN ensures we don't drop locations with no orders
WHERE l.city = 'Chicago' 
GROUP BY l.location_name;

/* Exercise 10: The Basic Filter Clean-up (Easy)
Scenario: A restaurant owner states they can't find an order from yesterday. They know the customer ordered an online item, spent somewhere between $20.00 and $30.00, and the status is still marked as completed.
Your Task: Write a query to find all columns from the orders table where the channel is 'Online', the order_status is 'Completed', and the subtotal is between $20.00 and $30.00 inclusive. 
Do not use > or < operators; use the specific keyword meant for ranges.
*/
select * from orders where order_status = 'Completed' and channel = 'Online' and order_timestamp >= CURRENT_DATE - interval '1 DAY' and subtotal between 20 and 30 

/*Exercise 11: Text Matching & Case Manipulation (Easy-Mid)
Scenario: A software bug capitalized some error messages weirdly, and you need to find logs related to "API" connection drops.
Your Task: Write a query against pos_sync_logs that returns all columns where the error_message contains the word "api" regardless of whether it is uppercase or lowercase (e.g., it should catch "API Timeout" or "api failure").
*/
select * from pos_sync_logs where LOWER(error_message) like '%api%'

/*Exercise 3: Aggregation Without Grouping (Easy)
Scenario: The manager wants a quick high-level health check on the 'Downtown Bistro' (which has a location_id of 101).
Your Task: Write a query that returns the Total Revenue, the Highest Subtotal single order, and the Lowest Subtotal single order for location_id = 101. Do not use a GROUP BY clause.
*/
select sum(subtotal), max(subtotal), min(subtotal) from orders

/*Exercise 4: Identifying Duplicates (Mid)
Scenario: In data pipelines, duplicate log entries can happen if a webhook fires twice. You suspect the pos_sync_logs table has double entries.
Your Task: Write a query that scans pos_sync_logs and lists any order_id that appears more than once in the log table.
*/
select order_id from pos_sync_logs group by order_id having count(order_id)>1

/* 14 Ticket A: The Disappearing Tips Investigation
From Support Ticket: "Hey team, our accounting department at the 'Metro Diner' (location_id 102) is running their end-of-week reconciliation. They notice that the total money coming out of our registers doesn't match the database headers. We think our online delivery orders are missing their delivery fees or tips. Can you check all completed online orders for this location and tell us what the average discrepancy is between what the customer paid on the receipt header vs what the item lines actually cost? We just need a single average number showing the difference."*/ 

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
/* Ticket B: The Systemic Integration Failure Report
From Engineering Slack Channel: "Hey, we are seeing a massive spike in synchronization timeouts today. We know it's impacting multiple stores, but we need to know if it's tied to a specific POS vendor software (like Toast or Aloha) so we can open a ticket with their engineering team. Can you pull a report showing us which POS systems are experiencing sync failures, along with the total count of failures for each system, ordered from highest failures to lowest?"*/
select pos_system, count(*) from pos_sync_logs psl
inner join orders o using(order_id)
inner join locations l using(location_id)
where sync_status = 'Failed' group by l.pos_system order by count(*) desc 


-- 15 Window Functions Practice Lab

/* Exercise 1: Finding the Most Recent Entry
Scenario: When troubleshooting log tables, you often only care about the absolute last thing that happened.
Your Task: Write a query that scans the pos_sync_logs table and assigns a sequential row number to each log entry separated by order_id, ordered by the sync_timestamp descending.
*/
select sync_timestamp, order_id, row_number() OVER(PARTITION BY order_id order by sync_timestamp desc) from pos_sync_logs  
/*Exercise 2: Identifying the Highest Spenders (RANK / DENSE_RANK)
Scenario: Management wants to see a leaderboard of orders to find their VIP transactions.
Your Task: Write a query against the orders table that returns the order_id, location_id, and subtotal. Add a column called sales_rank that ranks the orders from highest subtotal to lowest subtotal, resetting the rank for each individual location_id.
*/
select order_id, location_id, subtotal, rank() over(
		partition by location_id order by subtotal desc
) 
from orders
/* Exercise 3: Tracking Time In-Between Events (LAG)
Scenario: In integration support, you need to know if a server is getting hammered by rapid requests.
Your Task: Write a query against orders that shows the order_id, order_timestamp, and a third column called previous_order_time which pulls the timestamp of the previous order that came into the system (ordered by order_timestamp ascending).
*/
select order_id, order_timestamp, LAG(order_timestamp) over(order by order_timestamp asc) as previous_order_time from orders

-- 16 Speed Round

/* Scenario: A restaurant manager wants to look at their high-ticket items.
Your Task: Write a query that returns the item_name and price from the order_items table for all items that cost more than $15.00, sorted by price from highest to lowest.
*/
select item_name, price from order_items where price>15 order by price desc 

/* Question 2
Scenario: The marketing team wants to see a list of unique menu items sold, but they want them combined into a single, clean list without duplicates.
Your Task: Write a query that returns a list of all unique item_name values present in the order_items table, sorted alphabetically.
*/
select distinct item_name from order_items order by item_name asc

/* Question 3
Scenario: The support team needs to identify locations that aren't processing any digital orders to see if their internet connection is down.
Your Task: Write a query that shows the location_name of any restaurant that has never processed an order through the 'Online' channel.
*/
select location_name from locations where location_id not in(
	select location_id from orders where channel = 'Online'
)

/* Question 4
Scenario: The VP of Sales wants to reward high-performing stores.
Your Task: Write a query that returns the location_id and the total count of completed orders for that location, but only display locations that have processed more than 50 completed orders in total.
*/
select location_id, count(*) from orders group by location_id having count(*)>50

-- 17 Interview
/* Interview Prompt: Find the highest single order subtotal in the entire company.*/
select max(subtotal) from orders

/* Interview Prompt: Find the specific order that had the highest subtotal. */
select order_id, subtotal from orders order by subtotal desc limit 1 offset 1

/* Interview Prompt: Find the order with the second highest subtotal.*/
with cte as (
	select order_id, subtotal, dense_rank() over(order by subtotal desc) as top from orders
)
select order_id, subtotal from cte where top = 2

/* Interview Prompt: Find the total sum of all order subtotals by restaurant location. Show the location name and the total subtotal sum.*/
select o.location_id, l.location_name, sum(o.subtotal)
from orders  o
left join locations l using(location_id)
group by location_id, l.location_name

/*Interview Prompt: Add a column called location_sales_percent. It should be calculated as [Location Sales Total] / [Grand Total Sales of All Locations Combined] * 100.*/
SELECT o.location_id, 
       l.location_name, 
       SUM(o.subtotal) AS location_total,
       round((SUM(o.subtotal) / SUM(SUM(o.subtotal)) OVER ()) * 100,2)::varchar || '%' AS location_sales_percent
FROM orders o
LEFT JOIN locations l USING(location_id)
GROUP BY o.location_id, l.location_name;
