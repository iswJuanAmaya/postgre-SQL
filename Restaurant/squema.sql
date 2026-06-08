-- 1. Create Tables
CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    location_name VARCHAR(100),
    city VARCHAR(50),
    pos_system VARCHAR(50) -- e.g., 'Toast', 'Aloha'
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    location_id INT,
    order_timestamp TIMESTAMP,
    order_status VARCHAR(20), -- 'Completed', 'Cancelled', 'Refunded'
    channel VARCHAR(20), -- 'In-Store', 'Online', 'UberEats'
    subtotal DECIMAL(10,2),
    tax DECIMAL(10,2),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    item_name VARCHAR(100),
    category VARCHAR(50), -- 'Beverage', 'Food', 'Dessert'
    price DECIMAL(10,2),
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE pos_sync_logs (
    log_id INT PRIMARY KEY,
    order_id INT,
    sync_status VARCHAR(20), -- 'Success', 'Failed'
    error_message VARCHAR(255),
    sync_timestamp TIMESTAMP
);

-- 2. Insert Mock Data
INSERT INTO locations VALUES 
(101, 'Downtown Bistro', 'Chicago', 'Toast'),
(102, 'Metro Diner', 'Chicago', 'Aloha'),
(103, 'Suburban Cafe', 'Evanston', 'Toast');

INSERT INTO orders VALUES 
(1001, 101, '2026-05-15 12:30:00', 'Completed', 'In-Store', 45.00, 4.50),
(1002, 101, '2026-05-15 13:15:00', 'Completed', 'Online', 22.50, 2.25),
(1003, 102, '2026-05-15 18:00:00', 'Completed', 'UberEats', 60.00, 6.00),
(1004, 102, '2026-05-15 18:45:00', 'Cancelled', 'In-Store', 15.00, 1.50),
(1005, 103, '2026-05-16 09:00:00', 'Completed', 'Online', 12.00, 1.20),
(1006, 101, '2026-05-16 11:00:00', 'Completed', 'In-Store', 35.00, 3.50),
(1007, 102, '2026-05-16 12:00:00', 'Refunded', 'Online', 50.00, 5.00);

INSERT INTO order_items VALUES 
(1, 1001, 'Bacon Cheeseburger', 'Food', 15.00, 2),
(2, 1001, 'Craft Beer', 'Beverage', 7.50, 2),
(3, 1002, 'Margherita Pizza', 'Food', 18.00, 1),
(4, 1002, 'Diet Soda', 'Beverage', 4.50, 1),
(5, 1003, 'Ribeye Steak', 'Food', 40.00, 1),
(6, 1003, 'Red Wine', 'Beverage', 10.00, 2),
(7, 1004, 'Chicken Tenders', 'Food', 11.00, 1),
(8, 1004, 'Fries', 'Food', 4.00, 1),
(9, 1005, 'Avocado Toast', 'Food', 9.00, 1),
(10, 1005, 'Latte', 'Beverage', 3.00, 1),
(11, 1006, 'Salmon Salad', 'Food', 20.00, 1),
(12, 1006, 'Iced Tea', 'Beverage', 5.00, 3),
(13, 1007, 'Sushi Combo', 'Food', 50.00, 1);

INSERT INTO pos_sync_logs VALUES 
(501, 1001, 'Success', NULL, '2026-05-15 12:31:00'),
(502, 1002, 'Failed', 'API Timeout - Connex Integration failure', '2026-05-15 13:16:00'),
(503, 1003, 'Success', NULL, '2026-05-15 18:02:00'),
(504, 1004, 'Success', NULL, '2026-05-15 18:46:00'),
(505, 1005, 'Failed', 'Payload validation error: missing JSON tag', '2026-05-16 09:02:00'),
(506, 1006, 'Success', NULL, '2026-05-16 11:01:00');