-- ============================================================================
-- SCHEMA SETUP: Restaurant & Order Analytics Mock Database
-- Target Engine: PostgreSQL / Standard Relational SQL
-- ============================================================================

-- Drop tables if they already exist to ensure clean, repeatable environments
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS locations;

-- 1. Create Locations Table
CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- 2. Create Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    location_id INT NOT NULL,
    channel VARCHAR(30) NOT NULL,       -- e.g., 'Online', 'Dine-In', 'Drive-Thru'
    subtotal DECIMAL(10, 2) NOT NULL,
    order_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_location 
        FOREIGN KEY (location_id) 
        REFERENCES locations(location_id) 
        ON DELETE CASCADE
);

-- 3. Create Order Items Table
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_item_order 
        FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE CASCADE
);

-- ============================================================================
-- SEED DATA: Populate with edge cases (including Null Traps & Varied Subtotals)
-- ============================================================================

-- Seed Locations
INSERT INTO locations (location_id, location_name, city) VALUES
(101, 'Downtown Bistro', 'Chicago'),
(102, 'Metro Station Express', 'Chicago'),
(103, 'Suburban Hub', 'Naperville'),
(104, 'The Offline Cafe', 'Evanston'); -- This location will have NO Online channel records

-- Seed Orders (Ensuring explicit variance for ranking and aggregation queries)
INSERT INTO orders (order_id, location_id, channel, subtotal) VALUES
(1001, 101, 'Online',     45.50),
(1002, 101, 'Dine-In',    120.00), -- High ticket
(1003, 102, 'Online',     15.25),
(1004, 102, 'Drive-Thru', 22.80),
(1005, 103, 'Online',     300.00), -- Absolute Peak Sales order
(1006, 103, 'Online',     120.00), -- Tied for Second Highest subtotal!
(1007, 101, 'Online',     85.00),
(1008, 104, 'Dine-In',    40.00);  -- Has no Online sales to test the NOT EXISTS logic

-- Seed Order Items (To test baseline filtering and sorting queries)
INSERT INTO order_items (item_id, order_id, item_name, price) VALUES
(1, 1001, 'Truffle Burger', 18.50),
(2, 1001, 'Craft Beer',      7.00),
(3, 1002, 'Ribeye Steak',    45.00),
(4, 1002, 'Premium Wine',    75.00),
(5, 1003, 'Classic Cheeseburger', 11.25),
(6, 1005, 'Catering Platter A',  150.00),
(7, 1005, 'Catering Platter B',  150.00);