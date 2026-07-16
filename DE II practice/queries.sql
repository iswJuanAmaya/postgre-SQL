select * from employees
select * from sales
select * from departments

/* 1. Total salary by department
Show department name and total salary sum.
Order by total salary descending. */
select d.department_name, sum(e.salary) total_salary
from departments d
join employees e using(department_id)
group by department_name
order by total_salary desc

/* 2. Department salary percent
Add to #1 a column "salary_percent" calculated as:
(dept total salary / company total salary) * 100
Round to 2 decimal places. */
with cte as(
select sum(salary) as company_salary from employees
)
select d.department_name, sum(e.salary) total_salary, 
round((sum(e.salary)/(select company_salary from cte))*100, 2) as salary_percent
from departments d
join employees e using(department_id)
group by department_name
order by total_salary desc

/* 3. Headcount and avg salary by department
Show department name, number of employees, and average salary.
Only include departments with more than 2 employees. */
select d.department_name, count(e.employee_id) as numb_empleoyees, avg(e.salary) as average_salary from departments d 
join employees e using(department_id)
group by d.department_name 
having count(e.employee_id)>2

/* 4. Employee with the highest salary
Return name, department, and salary of the employee with the highest salary.
Do not use LIMIT. */
--4.1 Limit & offset
select e.name, d.department_name, e.salary from employees e 
join departments d  using(department_id)
order by salary desc
limit 1 
offset 2
--4.2 RANK
with cte as (
	select e.name, d.department_name, e.salary, dense_rank() over(order by salary desc) as top_salary from employees e 
	join departments d  using(department_id)
)
select * from cte where top_salary = 1
--4.3 MAX
select e.name, d.department_name, e.salary from employees e 
join departments d  using(department_id)
where salary = (select max(salary) from employees)
--4.4 Subquery with Row_number
select * from (
	select e.name, d.department_name, e.salary, row_number() over(order by salary desc) from employees e 
	join departments d  using(department_id)
	order by salary desc
	)
where row_number = 1

/* 5. Employee with the second highest salary
Return name, department, and salary of the employee(s) with the second highest salary.
Handle ties correctly. */
with cte as (
	select e.name, d.department_name, e.salary, dense_rank() over(order by salary desc) as top_salary from employees e 
	join departments d  using(department_id)
)
select * from cte where top_salary = 2

/* 6. Salary rank within department
For each employee show name, department, salary, and their salary rank within their department.
1 = highest paid in that department. */
select e.name, d.department_name, e.salary, dense_rank() over(partition by d.department_name order by salary desc) as top_salary from employees e 
join departments d  using(department_id)

/* 7. Salary vs department average
Show each employee's name, salary, their department's average salary, and the difference between their salary and that average.
Round to 2 decimals. */
with cte as(
	select department_id, avg(salary) from employees e group by department_id
)
select e.name, e.salary, round(cte.avg, 2) as average_per_department, round(e.salary-cte.avg,2) as diff
from employees e 
join cte using(department_id)
--7.2
SELECT e.name,
       e.salary,
       ROUND(AVG(e.salary) OVER (PARTITION BY e.department_id), 2) AS dept_avg,
       ROUND(e.salary - AVG(e.salary) OVER (PARTITION BY e.department_id), 2) AS diff
FROM employees e
JOIN departments d USING(department_id);

/* 8. Running total of sales by rep
For each sales rep show each sale date, amount, and a running total of their sales ordered by date. */
select employee_id, sale_date, amount, sum(amount) over(partition by employee_id order by sale_date) from sales
order by employee_id 

/* 9. Employees without sales
Find employees who have never made a sale.
Return employee name and department. */
select e.name, d.department_name from employees e 
join departments d using(department_id) 
left join sales s using(employee_id) where s.employee_id is null

/* 10. Each employee with their manager's name
Show employee name, their job title, and their manager's name.
Employees without a manager should still appear (show NULL for manager). */
select e.name, e.job_title, e.manager_id, f.name as manager_name from employees e
left join employees f on e.manager_id = f.employee_id 

/* 11. Top sales rep per region
For each region find the sales rep with the highest total sales amount.
Show region, employee name, and their total. */
with cte as (
	select region, employee_id, sum(amount) total, rank() over(partition by region order by sum(amount) desc) 
	from sales
	group by region, employee_id
	order by region, total desc
	)
select * from cte where rank= 1

/* 12. Sales by product — pivot
Show total sales amount per employee, with one column per product:
Software | Hardware | Services
Only include employees who have sales. */
select
	e.name,
	sum(case s.product when 'Software' then s.amount else 0 end) "Software",
	sum(case s.product when 'Hardware' then s.amount else 0 end) "Hardware",
	sum(case s.product when 'Services' then s.amount else 0 end) "Services"
from sales s
join employees e using(employee_id)
group by name

/* 13. Monthly sales pivot (Q1 2023)
Show total sales per region for Jan, Feb, Mar 2023 as separate columns:
region | jan | feb | mar */
select 
	region, 
	sum(case when to_char(sale_date, 'yyyy-mm') = '2023-01' then amount else 0 end) "Jan",
	sum(case when to_char(sale_date, 'yyyy-mm') = '2023-02' then amount else 0 end) "Feb",
	sum(case when to_char(sale_date, 'yyyy-mm') = '2023-03' then amount else 0 end) "Mar"
from sales
group by region

/* 14. Duplicate detection
Find employees where the same name appears more than once in the employees table.
Return the name and how many times it appears. */
select name, count(name) from employees group by name having count(name) >1

/* 15. Employees hired in the last 2 years with no sales
Find employees hired after 2022-01-01 who have never made a sale.
Show name, hire_date, and department. */
select e.name, e.hire_date, d.department_name 
from employees e 
join departments d using(department_id)
left join sales s using(employee_id) 
where e.hire_date > '2022-01-01'::date and s.employee_id is null
order by name


