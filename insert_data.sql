USE customer_retention_portfolio;

-- Step 1: Insert data into tables

INSERT INTO customers VALUES
(1, 'Aina', 'Kuala Lumpur', '2025-10-01'),
(2, 'Hakim', 'Shah Alam', '2025-10-03'),
(3, 'Mei Ling', 'Penang', '2025-10-05'),
(4, 'Ravi', 'Johor Bahru', '2025-10-08'),
(5, 'Sarah', 'Kota Bharu', '2025-10-12'),
(6, 'Daniel', 'Kuala Lumpur', '2025-10-15'),
(7, 'Nurul', 'Terengganu', '2025-10-18'),
(8, 'Jason', 'Melaka', '2025-10-20'),
(9, 'Farah', 'Ipoh', '2025-10-23'),
(10, 'Adam', 'Kuantan', '2025-10-25'),
(11, 'Liyana', 'Seremban', '2025-11-01'),
(12, 'Arif', 'Kuala Terengganu', '2025-11-05');

INSERT INTO products VALUES
(101, 'Wireless Mouse', 'Electronics', 45.00),
(102, 'Keyboard', 'Electronics', 80.00),
(103, 'Laptop Stand', 'Accessories', 65.00),
(104, 'Notebook', 'Stationery', 12.00),
(105, 'Water Bottle', 'Lifestyle', 35.00),
(106, 'USB-C Cable', 'Electronics', 25.00),
(107, 'Desk Lamp', 'Home Office', 90.00),
(108, 'Backpack', 'Lifestyle', 120.00);

INSERT INTO orders VALUES
(1001, 1, '2026-01-05', 'Completed'),
(1002, 2, '2026-01-07', 'Completed'),
(1003, 3, '2026-01-10', 'Completed'),
(1004, 4, '2026-01-15', 'Completed'),
(1005, 5, '2026-01-18', 'Completed'),
(1006, 1, '2026-02-03', 'Completed'),
(1007, 3, '2026-02-05', 'Completed'),
(1008, 4, '2026-02-10', 'Completed'),
(1009, 6, '2026-02-15', 'Completed'),
(1010, 7, '2026-02-20', 'Completed'),
(1011, 1, '2026-03-01', 'Completed'),
(1012, 3, '2026-03-05', 'Completed'),
(1013, 6, '2026-03-12', 'Completed'),
(1014, 8, '2026-03-15', 'Completed'),
(1015, 9, '2026-03-20', 'Completed'),
(1016, 1, '2026-04-02', 'Completed'),
(1017, 4, '2026-04-05', 'Completed'),
(1018, 6, '2026-04-08', 'Completed'),
(1019, 7, '2026-04-15', 'Completed'),
(1020, 10, '2026-04-20', 'Completed'),
(1021, 11, '2026-04-22', 'Cancelled');

INSERT INTO order_items VALUES
(1, 1001, 101, 2, 45.00),
(2, 1001, 104, 3, 12.00),
(3, 1002, 102, 1, 80.00),
(4, 1003, 103, 1, 65.00),
(5, 1003, 105, 2, 35.00),
(6, 1004, 108, 1, 120.00),
(7, 1005, 104, 5, 12.00),
(8, 1006, 107, 1, 90.00),
(9, 1006, 106, 2, 25.00),
(10, 1007, 101, 1, 45.00),
(11, 1007, 105, 1, 35.00),
(12, 1008, 103, 2, 65.00),
(13, 1009, 108, 1, 120.00),
(14, 1009, 104, 2, 12.00),
(15, 1010, 105, 2, 35.00),
(16, 1011, 102, 1, 80.00),
(17, 1011, 106, 3, 25.00),
(18, 1012, 107, 1, 90.00),
(19, 1013, 101, 2, 45.00),
(20, 1014, 108, 1, 120.00),
(21, 1015, 104, 3, 12.00),
(22, 1015, 106, 1, 25.00),
(23, 1016, 103, 1, 65.00),
(24, 1016, 105, 1, 35.00),
(25, 1017, 107, 1, 90.00),
(26, 1017, 102, 1, 80.00),
(27, 1018, 108, 1, 120.00),
(28, 1018, 106, 2, 25.00),
(29, 1019, 101, 1, 45.00),
(30, 1019, 104, 4, 12.00),
(31, 1020, 105, 3, 35.00),
(32, 1021, 108, 1, 120.00);

-- Step 2: Validate the data

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

-- Step 3: Check row counts
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;






