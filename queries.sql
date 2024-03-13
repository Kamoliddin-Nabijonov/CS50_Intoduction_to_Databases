-- Test Data STORE:
INSERT INTO store (store_name, description, address, phone_number, website_url, opening_hours, store_type)
VALUES
    ('Apple Fifth Avenue', 'Iconic flagship store in the heart of Manhattan', '767 5th Ave, New York, NY 10153', '(212) 336-1440', 'https://www.apple.com/retail/fifthavenue/', 'Mon-Sun: 10am to 8pm', 'Apple Store'),
    ('Apple Union Square', 'Vibrant store in downtown San Francisco', '300 Post St, San Francisco, CA 94108', '(415) 392-0202', 'https://www.apple.com/retail/unionsquare/', 'Mon-Sat: 10am to 7pm, Sun: 11am to 6pm', 'Apple Store'),
    ('Simply Mac', 'Your local Apple expert', '123 Main St, Anytown, USA 12345', '(555) 123-4567', 'https://www.simplymac.com', 'Mon-Fri: 9am to 6pm, Sat: 10am to 5pm', 'Apple Authorized Reseller'),
    ('Best Buy', 'Major electronics retailer with Apple products', '456 Elm St, Someplace, CA 90210', '(555) 987-6543', 'https://www.bestbuy.com', 'Mon-Sat: 10am to 9pm, Sun: 11am to 7pm', 'Apple Authorized Reseller'),
    ('Apple Online Store', 'Official online store for Apple products', 'N/A', '1-800-MY-APPLE', 'https://www.apple.com', '24/7', 'Online');

-- Test Data PRODUCT:
INSERT INTO product (serial_no, product_name, product_category, release_date, description, price)
VALUES
  ('ABC1234567890123456', 'iPhone 14 Pro', 'iPhone', '2022-09-16', 'A high-quality Apple iPhone', 999.00),
  ('DEF9876543210123456', 'iPhone 13', 'iPhone', '2021-09-24', 'A high-quality Apple iPhone', 699.00),
  ('GHI7654321012345678', 'iPad Pro 12.9-inch', 'iPad', '2022-10-26', 'A high-quality Apple iPad', 1099.00),
  ('JKL5432101234567890', 'iPad mini', 'iPad', '2021-09-24', 'A high-quality Apple iPad', 499.00),
  ('MNO3210123456789012', 'MacBook Air', 'Mac', '2022-06-06', 'A high-quality Apple Mac', 1199.00),
  ('PQR1012345678901234', 'iMac 24-inch', 'Mac', '2021-04-20', 'A high-quality Apple Mac', 1299.00);

-- Test Data EMPLOYEE:
INSERT INTO employee (store_id, first_name, last_name, email, phone, job_title, speciality)
VALUES
  (1, 'Emily', 'Johnson', 'emily.johnson@apple.com', '(415) 555-1212', 'Genius', 'Mac'),
  (2, 'John', 'Smith', 'john.smith@apple.com', '(212) 555-3434', 'Sales Specialist', 'iPhone'),
  (3, 'Sarah', 'Williams', 'sarah.williams@apple.com', '(415) 555-8989', 'Technical Expert', 'iPad'),
  (4, 'Michael', 'Brown', 'michael.brown@bestbuy.com', '(555) 555-6767', 'Sales Associate', 'Mac'),
  (5, 'Olivia', 'Jones', 'olivia.jones@apple.com', '(212) 555-2323', 'Store Leader', 'iPhone');

-- Test Data CUSTOMER:
INSERT INTO customer (first_name, last_name, email, phone, apple_id, shipping_address)
VALUES
  ('John', 'Smith', 'john.smith@gmail.com', '(555) 123-4567', 'jsmith123', '123 Main St, Anytown, CA 12345'),
  ('Emily', 'Johnson', 'emily85@yahoo.com', '(212) 987-6543', 'emilyj', '456 Elm St, Someplace, NY 90210'),
  ('Michael', 'Davis', 'michael.davis@outlook.com', '(408) 555-3210', 'mdavis91', NULL);

-- Add inventory items:
CALL add_inventory_item('Apple Fifth Avenue', 'ABC1234567890123456');
CALL add_inventory_item('Apple Union Square', 'DEF9876543210123456');
CALL add_inventory_item('Simply Mac', 'GHI7654321012345678');
CALL add_inventory_item('Best Buy', 'JKL5432101234567890');
CALL add_inventory_item('Apple Online Store', 'MNO3210123456789012');
CALL add_inventory_item('Apple Online Store', 'PQR1012345678901234');

-- Test order functionality
CALL create_order('ABC1234567890123456', 1, 1);
CALL process_order('ABC1234567890123456', 1, 1, 2, 1020.00);
CALL create_order('DEF9876543210123456', 2, 2);
CALL cancel_order('DEF9876543210123456', 2, 2);

-- Validate the result of above procedures using denormalized views
SELECT * FROM products_in_stock;
SELECT * FROM orders_listing;

-- Test repair functionality
CALL request_repair('ABC1234567890123456', 1, 1);
CALL process_repair('ABC1234567890123456', 1, 1, 3, 200.50, 'Display exchange');
CALL complete_repair('ABC1234567890123456', 1, 1, 'Display exchanged and charging port cleaner to enable charging');

-- Validate the result of above procedures using denormalized view
SELECT * FROM repair_listing;
