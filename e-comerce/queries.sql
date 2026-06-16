select * from customers
select * from order_items 
select * from orders
select * from products


/* 1. Total profit per category
Get total profit and total number of items sold for each product category. Order by total profit descending. */
select p.category, sum(oi.quantity), sum(oi.profit) as total_profit from order_items oi
inner join products p using(product_id)
group by p.category 
order by total_profit  desc

/*2. Monthly order count
Count how many orders were placed each month in 2023. Format the month as 'YYYY-MM'. */
select count(order_id), to_char(order_date, 'yyyy-mm') as month from orders group by to_char(order_date, 'yyyy-mm')  order by month

/*3. Customers with negative profit
Find customers who have generated negative total profit across all their orders. Show customer name and total profit. */
select c.customer_id, c.name, sum(oi.profit) as customer_profit from order_items oi
join orders o using(order_id)
join customers c using(customer_id) 
group by c.customer_id , c.name
HAVING customer_profit < 0
/*4. Average discount by segment
Calculate average discount per customer segment. Only include segments where average discount > 0. Round to 4 decimal places.*/

/*5. Orders with no items
Find any orders that have zero order_items associated. Return order_id and order_date.*/

/*6. Top product per category
For each category, find the product with the highest total profit. Show category, product name, and total profit.*/

/*7. Repeat customers only
Return the full order history (order_id, order_date, customer name) only for customers who have placed more than 1 order.*/

/*8. Profit rank per category
Rank products by profit within each category using RANK(). Show product name, category, total profit, and rank.*/

/*9. Running total of orders
Calculate a cumulative (running) order count by month in 2023. Columns: month, orders_that_month, running_total.*/

/*10. Previous order gap
For each customer with multiple orders, calculate the number of days between their current and previous order. Show customer name, order_date, prev_order_date, days_gap.*/

/*11. Index for order lookups
The query below is slow on large data:
SELECT * FROM orders WHERE customer_id = 1 ORDER BY order_date DESC;
Write the CREATE INDEX statement that would speed this up. Then use EXPLAIN to verify it would be used.*/

/*12. Rewrite subquery as JOIN
Rewrite this correlated subquery to use a JOIN instead — it's scanning the entire table on every row:
SELECT name FROM customers c
WHERE (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) > 1;*/