-- TABLES AND ENUM DEFINITIONS:
CREATE TYPE store_type AS ENUM (
    'Apple Store',
    'Apple Authorized Reseller',
    'Online'
);

CREATE TABLE store (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    description TEXT,
    address VARCHAR(200) NOT NULL,
    phone_number VARCHAR(100) NOT NULL,
    website_url VARCHAR(100) NOT NULL,
    opening_hours VARCHAR(100) NOT NULL,
    store_type store_type NOT NULL,
    inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

CREATE TYPE product_category AS ENUM (
    'iPhone',
    'iPad',
    'Mac'
);

CREATE TABLE product (
    serial_no VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    product_category product_category NOT NULL,
    release_date DATE NOT NULL,
    description TEXT,
    price NUMERIC(8,2) NOT NULL,
    inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

CREATE TYPE product_inventory_status AS ENUM (
    'available',
    'unavailable'
);

CREATE TABLE inventory (
  inventory_id SERIAL PRIMARY KEY,
  store_id BIGINT NOT NULL,
  serial_no VARCHAR(20) NOT NULL,
  status product_inventory_status NOT NULL DEFAULT 'available',
  inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE RESTRICT,
  FOREIGN KEY (serial_no) REFERENCES product(serial_no) ON DELETE RESTRICT,
  CONSTRAINT unique_inventory_product UNIQUE (store_id, serial_no)
);

CREATE TABLE employee (
  employee_id SERIAL PRIMARY KEY,
  store_id BIGINT NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(64) NOT NULL,
  phone VARCHAR(100) NOT NULL,
  job_title VARCHAR(100) NOT NULL,
  speciality product_category NOT NULL,
  inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE RESTRICT
);

CREATE TABLE customer (
  customer_id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(64) NOT NULL,
  phone VARCHAR(100) NOT NULL,
  apple_id VARCHAR(64) NOT NULL,
  shipping_address VARCHAR(200),
  inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TYPE order_status AS ENUM (
    'created',
    'completed',
    'canceled'
);

CREATE TABLE "order" (
  order_id SERIAL PRIMARY KEY,
  serial_no VARCHAR(20) NOT NULL,
  customer_id BIGINT NOT NULL,
  store_id BIGINT NOT NULL,
  employee_id BIGINT,
  total_invoice NUMERIC(8,2),
  order_status order_status NOT NULL DEFAULT 'created',
  inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  FOREIGN KEY (serial_no) REFERENCES product(serial_no) ON DELETE RESTRICT,
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE RESTRICT,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE RESTRICT,
  FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE RESTRICT,
  CONSTRAINT unique_order UNIQUE (serial_no, customer_id, store_id)
);

CREATE TYPE repair_status AS ENUM (
    'initiated',
    'in progress',
    'completed'
);

CREATE TABLE repair (
  repair_id SERIAL PRIMARY KEY,
  serial_no VARCHAR(20) NOT NULL,
  customer_id BIGINT NOT NULL,
  store_id BIGINT NOT NULL,
  employee_id BIGINT,
  total_invoice NUMERIC(8,2),
  repair_status repair_status NOT NULL DEFAULT 'initiated',
  repair_details TEXT,
  inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  FOREIGN KEY (serial_no) REFERENCES product(serial_no) ON DELETE RESTRICT,
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE RESTRICT,
  FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE RESTRICT,
  FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE RESTRICT
);


-- VIEW DEFINITIONS:
CREATE VIEW products_in_stock AS
SELECT
    i.inventory_id,
    s.store_id,
    s.store_name,
    s.description as store_description,
    s.address as store_address,
    s.phone_number as store_phone_number,
    s.website_url as store_website_url,
    s.opening_hours as store_opening_hours,
    s.store_type,
    p.serial_no as product_serial_no,
    p.product_name,
    p.product_category,
    p.release_date as product_release_date,
    p.description as product_description,
    p.price,
    p.inserted_at as product_added_at,
    p.updated_at as product_last_updated_at,
    i.status as inventory_status,
    i.inserted_at as added_to_inventory_at,
    i.updated_at as inventory_last_updated_at
FROM inventory i
INNER JOIN store s ON i.store_id = s.store_id
INNER JOIN product p ON i.serial_no = p.serial_no
WHERE i.status = 'available'
ORDER BY added_to_inventory_at DESC;

CREATE OR REPLACE VIEW orders_listing AS
SELECT o.order_id,
       p.serial_no as product_serial_no,
       p.product_name,
       p.product_category,
       p.release_date as product_release_date,
       p.description as product_description,
       p.price as product_price,
       c.customer_id,
       c.first_name as customer_first_name,
       c.last_name as customer_last_name,
       c.email as customer_email,
       c.phone as customer_phone,
       c.apple_id as customer_apple_id,
       c.shipping_address as customer_shipping_address,
       s.store_id,
       s.store_name,
       s.description as store_description,
       s.address as store_address,
       s.phone_number as store_phone_number,
       s.website_url as store_website_url,
       s.opening_hours as store_opening_hours,
       s.store_type as store_store_type,
       e.employee_id,
       e.first_name as employee_first_name,
       e.last_name as employee_last_name,
       e.email as employee_email,
       e.phone as employee_phone,
       e.job_title as employee_job_title,
       e.speciality as employee_speciality,
       o.total_invoice as order_total_invoice,
       o.order_status,
       o.inserted_at as order_created_at,
       o.updated_at as order_updated_at
FROM "order" o
         LEFT JOIN product p ON p.serial_no = o.serial_no
         LEFT JOIN customer c ON c.customer_id = o.customer_id
         LEFT JOIN store s ON s.store_id = o.store_id
         LEFT JOIN employee e ON e.employee_id = o.employee_id
ORDER BY order_created_at DESC;

CREATE OR REPLACE VIEW repair_listing AS
SELECT r.repair_id,
       p.serial_no as product_serial_no,
       p.product_name,
       p.product_category,
       p.release_date as product_release_date,
       p.description as product_description,
       p.price as product_price,
       c.customer_id,
       c.first_name as customer_first_name,
       c.last_name as customer_last_name,
       c.email as customer_email,
       c.phone as customer_phone,
       c.apple_id as customer_apple_id,
       c.shipping_address as customer_shipping_address,
       s.store_id,
       s.store_name,
       s.description as store_description,
       s.address as store_address,
       s.phone_number as store_phone_number,
       s.website_url as store_website_url,
       s.opening_hours as store_opening_hours,
       s.store_type as store_store_type,
       e.employee_id,
       e.first_name as employee_first_name,
       e.last_name as employee_last_name,
       e.email as employee_email,
       e.phone as employee_phone,
       e.job_title as employee_job_title,
       e.speciality as employee_speciality,
       r.total_invoice as repair_total_invoice,
       r.repair_status,
       r.repair_details,
       r.inserted_at as repair_initiated_at,
       r.updated_at as repair_updated_at
FROM repair r
LEFT JOIN product p ON p.serial_no = r.serial_no
LEFT JOIN customer c ON c.customer_id = r.customer_id
LEFT JOIN store s ON s.store_id = r.store_id
LEFT JOIN employee e ON e.employee_id = r.employee_id
ORDER BY repair_initiated_at DESC;


-- TRIGGER DEFINITION:
CREATE OR REPLACE FUNCTION unlist_product_from_inventory()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
BEGIN
	IF NEW.order_status = 'completed' THEN
		 UPDATE inventory SET status = 'unavailable' WHERE serial_no = NEW.serial_no;
	END IF;

	RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER unlist_product_from_inventory_trigger
  AFTER UPDATE
  ON "order"
  FOR EACH ROW
  EXECUTE PROCEDURE unlist_product_from_inventory();


-- PROCEDURE DECLARATIONS:
CREATE OR REPLACE PROCEDURE add_inventory_item(
    IN _store_name VARCHAR(100),
    IN _serial_no VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    _store_id BIGINT;
BEGIN

    SELECT store_id INTO _store_id FROM store WHERE store_name = _store_name;

    IF _store_id IS NULL THEN
        RAISE EXCEPTION 'Store not found: %', _store_name;
    END IF;

    INSERT INTO inventory (store_id, serial_no, status)
    VALUES (_store_id, _serial_no, 'available');

END;
$$;


CREATE OR REPLACE PROCEDURE create_order(
    IN _serial_no VARCHAR(20),
    IN _customer_id BIGINT,
    IN _store_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    _product_price NUMERIC;
    _order_status order_status := 'created';
BEGIN
    -- INPUT VALIDATION
    -- CHECK IF PRODUCT EXISTS IN INVENTORY AND AVAILABLE FOR PURCHASE:
    IF NOT EXISTS(SELECT 1 FROM inventory WHERE serial_no = _serial_no AND store_id = _store_id AND status='available') THEN
        RAISE EXCEPTION 'product with given serial_no is not available for purchase';
    END IF;
    -- CHECK IF CUSTOMER WITH GIVEN ID EXISTS:
    IF NOT EXISTS(SELECT 1 FROM customer WHERE customer_id = _customer_id) THEN
        RAISE EXCEPTION 'customer with given id does not exist';
    END IF;
    -- CHECK IF STORE WITH GIVEN ID EXISTS:
    IF NOT EXISTS(SELECT 1 FROM store WHERE store_id = _store_id) THEN
        RAISE EXCEPTION 'store with given id does not exist';
    END IF;

    -- CHECK IF PRODUCT EXISTS AND GET IT'S DEFAULT PRICE
    SELECT price INTO _product_price FROM product WHERE serial_no = _serial_no;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'product with serial number % not found', _serial_no;
    END IF;

    -- CREATE ORDER
    INSERT INTO "order" (serial_no, customer_id, store_id, total_invoice, order_status)
    VALUES (_serial_no, _customer_id, _store_id, _product_price, _order_status);
END;
$$;


CREATE OR REPLACE PROCEDURE process_order(
    IN _serial_no VARCHAR(20),
    IN _customer_id BIGINT,
    IN _store_id BIGINT,
    IN _employee_id BIGINT,
    IN _total_invoice NUMERIC(8,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    _order_status order_status := 'completed';
BEGIN
    -- CHECK IF ORDER EXISTS:
    IF NOT EXISTS(SELECT 1 FROM "order" WHERE serial_no = _serial_no
                                        AND customer_id = _customer_id
                                        AND store_id = _store_id
                                        AND order_status = 'created') THEN
        RAISE EXCEPTION 'order for given arguments does not exist';
    END IF;

    -- PROCESS THE RECORD BUY ASSIGNING EMPLOYEE, SETTING FINAL INVOICE AMOUNT AND UPDATING STATUS
    UPDATE "order" SET employee_id = _employee_id,
                       total_invoice = _total_invoice,
                       order_status = _order_status,
                       updated_at = NOW()
    WHERE serial_no = _serial_no
      AND customer_id = _customer_id
      AND store_id = _store_id
      AND order_status='created';
END;
$$;


CREATE OR REPLACE PROCEDURE cancel_order(
    IN _serial_no VARCHAR(20),
    IN _customer_id BIGINT,
    IN _store_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    _order_status order_status := 'canceled';
BEGIN
    -- CHECK IF ORDER EXISTS:
    IF NOT EXISTS(SELECT 1 FROM "order" WHERE serial_no = _serial_no
                                        AND customer_id = _customer_id
                                        AND store_id = _store_id
                                        AND order_status='created') THEN
        RAISE EXCEPTION 'order for given arguments does not exist';
    END IF;

    -- PROCESS THE RECORD BUY ASSIGNING EMPLOYEE, SETTING FINAL INVOICE AMOUNT AND UPDATING STATUS
    UPDATE "order" SET order_status = _order_status,
                       updated_at = NOW()
    WHERE serial_no = _serial_no
      AND customer_id = _customer_id
      AND store_id = _store_id
      AND order_status='created';
END;
$$;


CREATE OR REPLACE PROCEDURE request_repair(
    IN _serial_no VARCHAR(20),
    IN _customer_id BIGINT,
    IN _store_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    _initial_repair_price NUMERIC := 0;
    _repair_status repair_status := 'initiated';
BEGIN
    -- INPUT VALIDATION:
    IF NOT EXISTS(SELECT 1 FROM product WHERE serial_no = _serial_no) THEN
        RAISE EXCEPTION 'product with given id does not exist';
    END IF;
    -- CHECK IF CUSTOMER WITH GIVEN ID EXISTS:
    IF NOT EXISTS(SELECT 1 FROM customer WHERE customer_id = _customer_id) THEN
        RAISE EXCEPTION 'customer with given id does not exist';
    END IF;
    -- CHECK IF STORE WITH GIVEN ID EXISTS:
    IF NOT EXISTS(SELECT 1 FROM store WHERE store_id = _store_id) THEN
        RAISE EXCEPTION 'store with given id does not exist';
    END IF;

    -- CREATE REPAIR REQUEST:
    INSERT INTO repair(serial_no, customer_id, store_id, total_invoice, repair_status)
    VALUES (_serial_no, _customer_id, _store_id, _initial_repair_price, _repair_status);
END;
$$;


CREATE OR REPLACE PROCEDURE process_repair(
    IN _serial_no VARCHAR(20),
    IN _customer_id BIGINT,
    IN _store_id BIGINT,
    IN _employee_id BIGINT,
    IN _total_invoice NUMERIC(8,2),
    IN _repair_details TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    _repair_status repair_status := 'in progress';
BEGIN
    -- CHECK IF REPAIR REQUEST EXISTS:
    IF NOT EXISTS(SELECT 1 FROM repair WHERE serial_no = _serial_no
                                        AND customer_id = _customer_id
                                        AND store_id = _store_id
                                        AND repair_status='initiated') THEN
        RAISE EXCEPTION 'repair request was not initiated for given arguments';
    END IF;

    -- PROCESS THE RECORD BUY ASSIGNING EMPLOYEE, SETTING FINAL INVOICE AMOUNT AND UPDATING STATUS:
    UPDATE repair SET employee_id = _employee_id,
                      total_invoice = _total_invoice,
                      repair_status = _repair_status,
                      repair_details = _repair_details,
                      updated_at = NOW()
    WHERE serial_no = _serial_no
      AND customer_id = _customer_id
      AND store_id = _store_id
      AND repair_status='initiated';
END;
$$;


CREATE OR REPLACE PROCEDURE complete_repair(
    IN _serial_no VARCHAR(20),
    IN _customer_id BIGINT,
    IN _store_id BIGINT,
    IN _repair_details TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    _repair_status repair_status := 'completed';
BEGIN
    -- CHECK IF IN PROGRESS REPAIR EXISTS:
    IF NOT EXISTS(SELECT 1 FROM repair WHERE serial_no = _serial_no
                                        AND customer_id = _customer_id
                                        AND store_id = _store_id
                                        AND repair_status='in progress') THEN
        RAISE EXCEPTION 'no repairs in progress for given arguments';
    END IF;

    -- COMPLETE THE REPAIR:
    UPDATE repair SET repair_status = _repair_status,
                      repair_details = _repair_details,
                      updated_at = NOW()
    WHERE serial_no = _serial_no
      AND customer_id = _customer_id
      AND store_id = _store_id
      AND repair_status='in progress';
END;
$$;
