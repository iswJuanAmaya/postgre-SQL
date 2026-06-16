-- =============================================
-- PRACTICE SCHEMA: ecommerce_db
-- =============================================

DROP SCHEMA IF EXISTS ecommerce CASCADE;
CREATE SCHEMA ecommerce;
SET search_path TO ecommerce;

-- TABLES
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    city        TEXT NOT NULL,
    segment     TEXT NOT NULL  -- 'consumer', 'corporate', 'home_office'
);

CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    name         TEXT NOT NULL,
    category     TEXT NOT NULL,
    sub_category TEXT NOT NULL,
    unit_price   NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date  DATE NOT NULL,
    ship_mode   TEXT NOT NULL  -- 'standard', 'second_class', 'first_class', 'same_day'
);

CREATE TABLE order_items (
    item_id     SERIAL PRIMARY KEY,
    order_id    INT REFERENCES orders(order_id),
    product_id  INT REFERENCES products(product_id),
    quantity    INT NOT NULL,
    discount    NUMERIC(4,2) NOT NULL DEFAULT 0,
    profit      NUMERIC(10,2) NOT NULL
);

-- DATA
INSERT INTO customers (name, city, segment) VALUES
('Alice Ramos',      'New York',    'consumer'),
('Bob Chen',         'Los Angeles', 'corporate'),
('Carlos Mendez',    'Chicago',     'consumer'),
('Diana Flores',     'Houston',     'home_office'),
('Elena Kim',        'Phoenix',     'corporate'),
('Frank Torres',     'New York',    'consumer'),
('Grace Liu',        'Los Angeles', 'corporate'),
('Henry Park',       'Chicago',     'home_office'),
('Isabel Santos',    'Houston',     'consumer'),
('Jorge Gutierrez',  'Phoenix',     'corporate'),
('Karen White',      'New York',    'consumer'),
('Luis Martinez',    'Los Angeles', 'home_office'),
('Maria Garcia',     'Chicago',     'consumer'),
('Nina Brown',       'Houston',     'corporate'),
('Oscar Wilson',     'Phoenix',     'consumer');

INSERT INTO products (name, category, sub_category, unit_price) VALUES
('Staple Envelope',         'Office Supplies', 'Envelopes',   19.98),
('Easy-staple Paper',       'Office Supplies', 'Paper',       9.99),
('Avery Binders',           'Office Supplies', 'Binders',     34.50),
('Canon Copier',            'Technology',      'Machines',    649.99),
('HP Laptop',               'Technology',      'Computers',   1199.99),
('Logitech Mouse',          'Technology',      'Accessories', 29.99),
('Samsung Monitor',         'Technology',      'Monitors',    399.99),
('Executive Chair',         'Furniture',       'Chairs',      479.99),
('Corner Desk',             'Furniture',       'Tables',      749.99),
('Bookcase',                'Furniture',       'Bookcases',   299.99),
('Wireless Keyboard',       'Technology',      'Accessories', 49.99),
('Label Tape',              'Office Supplies', 'Labels',      7.50),
('Stapler',                 'Office Supplies', 'Fasteners',   14.99),
('Standing Desk',           'Furniture',       'Tables',      899.99),
('External SSD',            'Technology',      'Storage',     119.99);

INSERT INTO orders (customer_id, order_date, ship_mode) VALUES
(1,  '2023-01-05', 'standard'),
(2,  '2023-01-12', 'first_class'),
(3,  '2023-01-18', 'standard'),
(4,  '2023-02-02', 'second_class'),
(5,  '2023-02-14', 'same_day'),
(6,  '2023-02-20', 'standard'),
(7,  '2023-03-01', 'first_class'),
(8,  '2023-03-15', 'standard'),
(9,  '2023-03-22', 'second_class'),
(10, '2023-04-04', 'same_day'),
(1,  '2023-04-18', 'standard'),
(2,  '2023-04-25', 'first_class'),
(11, '2023-05-03', 'standard'),
(12, '2023-05-11', 'second_class'),
(13, '2023-05-19', 'first_class'),
(14, '2023-06-02', 'standard'),
(15, '2023-06-14', 'same_day'),
(3,  '2023-06-21', 'standard'),
(5,  '2023-07-07', 'first_class'),
(7,  '2023-07-15', 'second_class'),
(9,  '2023-07-28', 'standard'),
(11, '2023-08-05', 'same_day'),
(13, '2023-08-17', 'standard'),
(1,  '2023-09-02', 'first_class'),
(4,  '2023-09-14', 'standard'),
(6,  '2023-10-01', 'second_class'),
(8,  '2023-10-19', 'first_class'),
(10, '2023-11-03', 'standard'),
(12, '2023-11-22', 'same_day'),
(14, '2023-12-08', 'standard');

INSERT INTO order_items (order_id, product_id, quantity, discount, profit) VALUES
(1,  1,  3, 0.00,  12.50),
(1,  2,  5, 0.10,  8.20),
(2,  5,  1, 0.00,  220.00),
(2,  6,  2, 0.05,  18.00),
(3,  3,  2, 0.00,  25.00),
(4,  8,  1, 0.10,  85.00),
(5,  4,  1, 0.00,  95.00),
(5,  11, 3, 0.00,  30.00),
(6,  12, 10,0.00,  15.00),
(6,  13, 2, 0.00,  10.00),
(7,  5,  2, 0.15, -45.00),
(7,  7,  1, 0.00,  60.00),
(8,  9,  1, 0.10,  110.00),
(9,  10, 2, 0.00,  70.00),
(10, 14, 1, 0.00,  130.00),
(11, 1,  6, 0.00,  22.00),
(11, 2,  4, 0.05,  12.00),
(12, 6,  5, 0.00,  40.00),
(13, 3,  1, 0.00,  14.00),
(14, 8,  2, 0.20, -30.00),
(15, 15, 3, 0.00,  85.00),
(16, 4,  1, 0.05,  80.00),
(17, 5,  1, 0.00,  210.00),
(18, 9,  1, 0.10,  95.00),
(19, 11, 4, 0.00,  55.00),
(20, 7,  2, 0.00,  100.00),
(21, 13, 5, 0.00,  18.00),
(22, 15, 2, 0.00,  60.00),
(23, 3,  3, 0.10,  28.00),
(24, 10, 1, 0.00,  40.00),
(25, 14, 2, 0.15, -20.00),
(26, 12, 8, 0.00,  20.00),
(27, 5,  1, 0.00,  195.00),
(28, 8,  1, 0.10,  75.00),
(29, 6,  3, 0.00,  35.00),
(30, 2,  10,0.05,  30.00);