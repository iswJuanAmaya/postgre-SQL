DROP SCHEMA IF EXISTS interview CASCADE;
CREATE SCHEMA interview;
SET search_path TO interview;

CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    department_name TEXT NOT NULL,
    location        TEXT NOT NULL
);

CREATE TABLE employees (
    employee_id   SERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    department_id INT REFERENCES departments(department_id),
    job_title     TEXT NOT NULL,
    salary        NUMERIC(10,2) NOT NULL,
    hire_date     DATE NOT NULL,
    manager_id    INT REFERENCES employees(employee_id)
);

CREATE TABLE sales (
    sale_id     SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    sale_date   DATE NOT NULL,
    amount      NUMERIC(10,2) NOT NULL,
    region      TEXT NOT NULL,
    product     TEXT NOT NULL
);

INSERT INTO departments VALUES
(1, 'Engineering',  'New York'),
(2, 'Sales',        'Chicago'),
(3, 'Marketing',    'Los Angeles'),
(4, 'HR',           'New York'),
(5, 'Finance',      'Chicago');

INSERT INTO employees VALUES
(1,  'Alice Morgan',   1, 'Senior Engineer',    95000, '2019-03-15', NULL),
(2,  'Bob Chen',       1, 'Junior Engineer',    62000, '2021-06-01', 1),
(3,  'Carlos Rivera',  1, 'Engineer',           78000, '2020-01-10', 1),
(4,  'Diana Flores',   2, 'Sales Manager',      85000, '2018-07-22', NULL),
(5,  'Elena Kim',      2, 'Sales Rep',          54000, '2022-02-14', 4),
(6,  'Frank Torres',   2, 'Sales Rep',          57000, '2021-11-03', 4),
(7,  'Grace Liu',      3, 'Marketing Lead',     80000, '2019-09-30', NULL),
(8,  'Henry Park',     3, 'Marketing Analyst',  61000, '2022-04-18', 7),
(9,  'Isabel Santos',  4, 'HR Manager',         75000, '2017-05-11', NULL),
(10, 'Jorge Gutierrez',4, 'HR Specialist',      52000, '2023-01-09', 9),
(11, 'Karen White',    5, 'Finance Manager',    90000, '2018-03-01', NULL),
(12, 'Luis Martinez',  5, 'Financial Analyst',  67000, '2020-08-25', 11),
(13, 'Maria Garcia',   2, 'Sales Rep',          54000, '2022-09-01', 4),
(14, 'Nina Brown',     1, 'Engineer',           78000, '2020-03-15', 1),
(15, 'Oscar Wilson',   3, 'Marketing Analyst',  58000, '2021-07-20', 7);

INSERT INTO sales VALUES
(1,  4,  '2023-01-15', 12000, 'North', 'Software'),
(2,  5,  '2023-01-22', 8500,  'South', 'Hardware'),
(3,  6,  '2023-02-10', 9200,  'East',  'Software'),
(4,  4,  '2023-02-18', 15000, 'North', 'Services'),
(5,  5,  '2023-03-05', 7800,  'West',  'Hardware'),
(6,  6,  '2023-03-12', 11000, 'East',  'Software'),
(7,  13, '2023-03-20', 9500,  'South', 'Services'),
(8,  4,  '2023-04-02', 18000, 'North', 'Software'),
(9,  5,  '2023-04-15', 6200,  'West',  'Hardware'),
(10, 6,  '2023-05-01', 13500, 'East',  'Services'),
(11, 13, '2023-05-18', 8900,  'South', 'Software'),
(12, 4,  '2023-06-10', 21000, 'North', 'Software'),
(13, 5,  '2023-06-25', 9100,  'West',  'Services'),
(14, 6,  '2023-07-08', 7600,  'East',  'Hardware'),
(15, 13, '2023-07-22', 11200, 'South', 'Software'),
(16, 4,  '2023-08-14', 16500, 'North', 'Services'),
(17, 5,  '2023-09-03', 8300,  'South', 'Hardware'),
(18, 6,  '2023-09-19', 14000, 'East',  'Software'),
(19, 13, '2023-10-05', 10500, 'West',  'Services'),
(20, 4,  '2023-11-12', 19000, 'North', 'Software'),
(21, 5,  '2023-11-28', 7400,  'South', 'Hardware'),
(22, 6,  '2023-12-10', 12800, 'East',  'Services'),
(23, 13, '2023-12-20', 9800,  'West',  'Software');