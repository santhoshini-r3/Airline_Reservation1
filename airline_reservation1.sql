-- AIRLINE RESERVATION PROJECT (MySQL 8.0+): run the tables part, import the CSV files, then run the select queries

DROP DATABASE IF EXISTS airline_reservation;

CREATE DATABASE airline_reservation;

USE airline_reservation;

CREATE TABLE airlines (
    airline_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_name VARCHAR(100) NOT NULL,
    iata_code CHAR(2) NOT NULL UNIQUE,
    country VARCHAR(50),
    founded_year INT
);

CREATE TABLE airports (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    airport_name VARCHAR(100) NOT NULL,
    iata_code CHAR(3) NOT NULL UNIQUE,
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE aircraft_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    model_name VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(50),
    total_seats INT NOT NULL,
    range_km INT
);

CREATE TABLE aircraft (
    aircraft_id INT PRIMARY KEY AUTO_INCREMENT,
    registration_no VARCHAR(15) NOT NULL UNIQUE,
    type_id INT NOT NULL,
    airline_id INT NOT NULL,
    manufacture_year INT,
    status VARCHAR(20) DEFAULT 'Active',

    FOREIGN KEY (type_id)
    REFERENCES aircraft_types(type_id),

    FOREIGN KEY (airline_id)
    REFERENCES airlines(airline_id)
);

CREATE TABLE routes (
    route_id INT PRIMARY KEY AUTO_INCREMENT,
    source_airport_id INT NOT NULL,
    destination_airport_id INT NOT NULL,
    distance_km INT,

    FOREIGN KEY (source_airport_id)
    REFERENCES airports(airport_id),

    FOREIGN KEY (destination_airport_id)
    REFERENCES airports(airport_id),

    UNIQUE (source_airport_id, destination_airport_id),
    CHECK (source_airport_id <> destination_airport_id)
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(10) NOT NULL,
    airline_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    route_id INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    base_fare DECIMAL(10,2),
    status VARCHAR(20),

    FOREIGN KEY (airline_id)
    REFERENCES airlines(airline_id),

    FOREIGN KEY (aircraft_id)
    REFERENCES aircraft(aircraft_id),

    FOREIGN KEY (route_id)
    REFERENCES routes(route_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    date_of_birth DATE,
    city VARCHAR(50),
    country VARCHAR(50),
    loyalty_points INT DEFAULT 0,
    registered_date DATE
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15),
    job_role VARCHAR(50),
    salary DECIMAL(10,2),
    joining_date DATE,
    airline_id INT,
    manager_id INT,

    FOREIGN KEY (airline_id)
    REFERENCES airlines(airline_id),

    FOREIGN KEY (manager_id)
    REFERENCES employees(employee_id)
);

CREATE TABLE flight_crew (
    crew_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    employee_id INT NOT NULL,
    crew_role VARCHAR(30),

    FOREIGN KEY (flight_id)
    REFERENCES flights(flight_id),

    FOREIGN KEY (employee_id)
    REFERENCES employees(employee_id),

    UNIQUE (flight_id, employee_id)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_ref VARCHAR(12) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    booking_date DATE,
    total_amount DECIMAL(12,2),
    status VARCHAR(30),
    booking_channel VARCHAR(30),

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10),
    age INT,
    passport_no VARCHAR(15),

    FOREIGN KEY (booking_id)
    REFERENCES bookings(booking_id)
);

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_number VARCHAR(15) NOT NULL UNIQUE,
    booking_id INT NOT NULL,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    seat_no VARCHAR(5),
    travel_class VARCHAR(20),
    fare DECIMAL(10,2),
    status VARCHAR(20),

    FOREIGN KEY (booking_id)
    REFERENCES bookings(booking_id),

    FOREIGN KEY (passenger_id)
    REFERENCES passengers(passenger_id),

    FOREIGN KEY (flight_id)
    REFERENCES flights(flight_id),

    UNIQUE (flight_id, seat_no)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    payment_date DATE,
    amount DECIMAL(12,2),
    payment_method VARCHAR(30),
    payment_status VARCHAR(20),

    FOREIGN KEY (booking_id)
    REFERENCES bookings(booking_id)
);

CREATE TABLE baggage (
    baggage_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    weight_kg DECIMAL(5,2),
    baggage_type VARCHAR(20),
    fee DECIMAL(8,2),

    FOREIGN KEY (ticket_id)
    REFERENCES tickets(ticket_id)
);

CREATE TABLE booking_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    action_type VARCHAR(20),
    old_status VARCHAR(30),
    new_status VARCHAR(30),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
select *from aircraft;


/* IMPORT THE CSV FILES (airline_csv.zip) in this order: 01 -> 14
   Workbench: Schemas -> airline_reservation -> Tables -> right click a table -> Table Data Import Wizard
              -> choose the matching CSV -> Use existing table -> Next -> Next -> Finish
   (booking_audit has no CSV, triggers fill it later. Faster way: run optional_load_data.sql) */

-- >>>>>>>>>> STOP HERE: import the CSV files now, then run the rest of this file <<<<<<<<<<

SELECT * FROM airlines;
SELECT * FROM airports;
SELECT * FROM aircraft_types;
SELECT * FROM aircraft;
SELECT * FROM routes;
SELECT * FROM flights;
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM flight_crew;
SELECT * FROM bookings;
SELECT * FROM passengers;
SELECT * FROM tickets;
SELECT * FROM payments;
SELECT * FROM baggage;
SELECT * FROM booking_audit;

SELECT * FROM flights;
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM flight_crew;
SELECT * FROM bookings;
SELECT * FROM passengers;
SELECT * FROM tickets;
SELECT * FROM payments;
SELECT * FROM baggage;
SELECT * FROM booking_audit;

SELECT 'bookings' AS table_name, COUNT(*) AS total_rows FROM bookings UNION ALL SELECT 'tickets', COUNT(*) FROM tickets UNION ALL SELECT 'passengers', COUNT(*) FROM passengers UNION ALL SELECT 'payments', COUNT(*) FROM payments UNION ALL SELECT 'flights', COUNT(*) FROM flights UNION ALL SELECT 'customers', COUNT(*) FROM customers;

SELECT * FROM flights;
SELECT flight_number, airline_id, base_fare FROM flights;
SELECT flight_number, airline_id, base_fare FROM flights WHERE base_fare > 10000;
SELECT employee_name, job_role, salary FROM employees WHERE salary > 100000;
SELECT flight_number, base_fare FROM flights WHERE base_fare BETWEEN 3000 AND 6000;
SELECT airport_id, airport_name, city FROM airports WHERE airport_name LIKE '%International%';
SELECT customer_id, first_name, last_name, loyalty_points FROM customers WHERE city = 'Chennai';
SELECT flight_number, departure_time, base_fare FROM flights ORDER BY base_fare DESC LIMIT 10;
SELECT COUNT(*) AS total_flights FROM flights;
SELECT ROUND(AVG(base_fare), 2) AS average_fare FROM flights;
SELECT MAX(base_fare) AS highest_fare,MIN(base_fare) AS lowest_fare FROM flights;
SELECT city,COUNT(*) AS customer_count FROM customers GROUP BY city ORDER BY customer_count DESC;
SELECT job_role,ROUND(AVG(salary), 2) AS average_salary FROM employees GROUP BY job_role;
SELECT airline_id,COUNT(*) AS flight_count FROM flights GROUP BY airline_id ORDER BY flight_count DESC;
SELECT flight_id,COUNT(*) AS tickets_booked FROM tickets WHERE status <> 'Cancelled' GROUP BY flight_id ORDER BY tickets_booked DESC LIMIT 10;
SELECT f.flight_id,f.flight_number,f.base_fare,a.airline_name FROM flights f JOIN airlines a ON f.airline_id = a.airline_id;
SELECT f.flight_number,ac.registration_no,t.model_name FROM flights f JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id JOIN aircraft_types t ON ac.type_id = t.type_id;
SELECT e.employee_name,e.job_role,e.salary,a.airline_name FROM employees e JOIN airlines a ON e.airline_id = a.airline_id;
SELECT b.booking_id,c.first_name,c.last_name,b.booking_date,b.total_amount,b.status FROM bookings b JOIN customers c ON b.customer_id = c.customer_id;
SELECT f.flight_number, src.city AS from_city, dst.city AS to_city, f.departure_time, f.base_fare FROM flights f JOIN routes r ON f.route_id = r.route_id JOIN airports src ON r.source_airport_id = src.airport_id JOIN airports dst ON r.destination_airport_id = dst.airport_id;
SELECT t.ticket_number, p.full_name, f.flight_number, t.seat_no, t.fare FROM tickets t JOIN passengers p ON t.passenger_id = p.passenger_id JOIN flights f ON t.flight_id = f.flight_id;
SELECT f.flight_id,f.flight_number,tp.total_seats,COUNT(t.ticket_id) AS seats_booked FROM flights f JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id JOIN aircraft_types tp ON ac.type_id = tp.type_id LEFT JOIN tickets t ON f.flight_id = t.flight_id AND t.status <> 'Cancelled' GROUP BY f.flight_id, f.flight_number, tp.total_seats HAVING COUNT(t.ticket_id) < 5;
SELECT f.flight_id,f.flight_number,COUNT(t.ticket_id) AS total_passengers FROM flights f JOIN tickets t ON f.flight_id = t.flight_id WHERE t.status = 'Flown' GROUP BY f.flight_id, f.flight_number ORDER BY total_passengers DESC LIMIT 10;
SELECT f.flight_id, f.flight_number, SUM(t.fare) AS total_revenue FROM flights f JOIN tickets t ON f.flight_id = t.flight_id WHERE t.status = 'Flown' GROUP BY f.flight_id, f.flight_number ORDER BY total_revenue DESC;
SELECT c.customer_id, c.first_name, c.last_name, SUM(b.total_amount) AS total_spending FROM customers c JOIN bookings b ON c.customer_id = b.customer_id WHERE b.status = 'Completed' GROUP BY c.customer_id, c.first_name, c.last_name ORDER BY total_spending DESC LIMIT 10;
SELECT a.airline_id, a.airline_name, SUM(t.fare) AS total_revenue FROM airlines a JOIN flights f ON a.airline_id = f.airline_id JOIN tickets t ON f.flight_id = t.flight_id WHERE t.status = 'Flown' GROUP BY a.airline_id, a.airline_name HAVING SUM(t.fare) > 1000000 ORDER BY total_revenue DESC;
WITH flight_sales AS (SELECT flight_id, COUNT(*) AS total_sold FROM tickets WHERE status <> 'Cancelled' GROUP BY flight_id) SELECT f.flight_id, f.flight_number, fs.total_sold FROM flight_sales fs JOIN flights f ON fs.flight_id = f.flight_id WHERE fs.total_sold > (SELECT AVG(total_sold) FROM flight_sales) ORDER BY fs.total_sold DESC;
WITH customer_spending AS (SELECT customer_id, SUM(total_amount) AS total_spending FROM bookings WHERE status = 'Completed' GROUP BY customer_id) SELECT c.customer_id, c.first_name, c.last_name, cs.total_spending FROM customer_spending cs JOIN customers c ON cs.customer_id = c.customer_id WHERE cs.total_spending > (SELECT AVG(total_spending) FROM customer_spending) ORDER BY cs.total_spending DESC;
SELECT f.flight_id, f.flight_number, f.departure_time FROM flights f LEFT JOIN tickets t ON f.flight_id = t.flight_id WHERE t.flight_id IS NULL;
SELECT a.airline_id, a.airline_name, SUM(tp.total_seats) AS total_seat_capacity FROM airlines a JOIN aircraft ac ON a.airline_id = ac.airline_id JOIN aircraft_types tp ON ac.type_id = tp.type_id GROUP BY a.airline_id, a.airline_name ORDER BY total_seat_capacity DESC;
WITH flight_sales AS (SELECT f.flight_id, f.flight_number, f.airline_id, COUNT(t.ticket_id) AS total_sold FROM flights f JOIN tickets t ON f.flight_id = t.flight_id WHERE t.status = 'Flown' GROUP BY f.flight_id, f.flight_number, f.airline_id), ranked_flights AS (SELECT *, RANK() OVER (PARTITION BY airline_id ORDER BY total_sold DESC) AS flight_rank FROM flight_sales) SELECT rf.flight_number, a.airline_name, rf.total_sold FROM ranked_flights rf JOIN airlines a ON rf.airline_id = a.airline_id WHERE rf.flight_rank = 1;
WITH monthly_sales AS (SELECT DATE_FORMAT(booking_date, '%Y-%m') AS sales_month, SUM(total_amount) AS revenue FROM bookings WHERE status = 'Completed' GROUP BY DATE_FORMAT(booking_date, '%Y-%m')) SELECT sales_month, revenue, LAG(revenue) OVER (ORDER BY sales_month) AS previous_month_revenue FROM monthly_sales ORDER BY sales_month;
WITH monthly_sales AS (SELECT DATE_FORMAT(booking_date, '%Y-%m') AS sales_month, SUM(total_amount) AS revenue FROM bookings WHERE status = 'Completed' GROUP BY DATE_FORMAT(booking_date, '%Y-%m')), previous_sales AS (SELECT sales_month, revenue, LAG(revenue) OVER (ORDER BY sales_month) AS previous_revenue FROM monthly_sales) SELECT sales_month, revenue, previous_revenue, ROUND((revenue - previous_revenue) / NULLIF(previous_revenue, 0) * 100, 2) AS growth_percentage FROM previous_sales ORDER BY sales_month;
WITH flight_revenue AS (SELECT f.flight_id, f.flight_number, f.airline_id, SUM(t.fare) AS revenue FROM flights f JOIN tickets t ON f.flight_id = t.flight_id WHERE t.status = 'Flown' GROUP BY f.flight_id, f.flight_number, f.airline_id), ranked_flights AS (SELECT *, DENSE_RANK() OVER (PARTITION BY airline_id ORDER BY revenue DESC) AS flight_rank FROM flight_revenue) SELECT rf.flight_number, a.airline_name, rf.revenue, rf.flight_rank FROM ranked_flights rf JOIN airlines a ON rf.airline_id = a.airline_id WHERE rf.flight_rank <= 3 ORDER BY a.airline_name, rf.flight_rank;
WITH flight_sales AS (SELECT flight_id, COUNT(*) AS total_sold FROM tickets WHERE status <> 'Cancelled' GROUP BY flight_id), average_sales AS (SELECT AVG(total_sold) AS avg_sold FROM flight_sales) SELECT f.flight_id, f.flight_number, fs.total_sold, f.base_fare FROM flights f JOIN flight_sales fs ON f.flight_id = fs.flight_id CROSS JOIN average_sales a WHERE fs.total_sold > a.avg_sold AND f.base_fare < (SELECT AVG(base_fare) FROM flights) ORDER BY fs.total_sold DESC;
WITH ticket_data AS (SELECT f.airline_id, COUNT(t.ticket_id) AS total_tickets, SUM(t.fare) AS total_revenue FROM flights f JOIN tickets t ON f.flight_id = t.flight_id WHERE t.status = 'Flown' GROUP BY f.airline_id), flight_data AS (SELECT airline_id, COUNT(*) AS total_flights, AVG(base_fare) AS average_base_fare FROM flights GROUP BY airline_id), capacity_data AS (SELECT ac.airline_id, SUM(tp.total_seats) AS total_seat_capacity FROM aircraft ac JOIN aircraft_types tp ON ac.type_id = tp.type_id GROUP BY ac.airline_id) SELECT a.airline_id, a.airline_name, a.country, COALESCE(fd.total_flights, 0) AS total_flights, COALESCE(td.total_tickets, 0) AS tickets_flown, ROUND(COALESCE(td.total_revenue, 0), 2) AS total_revenue, ROUND(COALESCE(fd.average_base_fare, 0), 2) AS average_base_fare, COALESCE(cd.total_seat_capacity, 0) AS total_seat_capacity, ROUND(COALESCE(td.total_revenue, 0) / NULLIF(COALESCE(td.total_tickets, 0), 0), 2) AS revenue_per_ticket, RANK() OVER (ORDER BY COALESCE(td.total_revenue, 0) DESC) AS revenue_rank FROM airlines a LEFT JOIN ticket_data td ON a.airline_id = td.airline_id LEFT JOIN flight_data fd ON a.airline_id = fd.airline_id LEFT JOIN capacity_data cd ON a.airline_id = cd.airline_id ORDER BY revenue_rank;


ALTER TABLE customers ADD COLUMN passport_country VARCHAR(50);
ALTER TABLE customers DROP COLUMN passport_country;
SHOW TABLES;
DESCRIBE bookings;

SELECT flight_id, flight_number, base_fare FROM flights WHERE base_fare > (SELECT AVG(base_fare) FROM flights) ORDER BY base_fare DESC;
SELECT customer_id, first_name, last_name FROM customers WHERE customer_id IN (SELECT customer_id FROM bookings WHERE status = 'Completed');
SELECT customer_id, first_name, last_name FROM customers c WHERE NOT EXISTS (SELECT 1 FROM bookings b WHERE b.customer_id = c.customer_id);
SELECT f.flight_id, f.flight_number, f.base_fare FROM flights f WHERE f.base_fare = (SELECT MAX(f2.base_fare) FROM flights f2 WHERE f2.airline_id = f.airline_id);
SELECT airline_name, (SELECT COUNT(*) FROM flights f WHERE f.airline_id = a.airline_id) AS total_flights FROM airlines a ORDER BY total_flights DESC;
 
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, city, country, loyalty_points, registered_date) VALUES ('Test', 'User', 'test.user@example.com', '9000000000', '1995-05-15', 'Chennai', 'India', 0, CURDATE());
SELECT * FROM customers WHERE email = 'test.user@example.com';
UPDATE customers SET city = 'Bengaluru', loyalty_points = 100 WHERE email = 'test.user@example.com';
DELETE FROM customers WHERE email = 'test.user@example.com';
SELECT employee_name, job_role, salary FROM employees WHERE salary > 100000 OR job_role = 'Pilot';
SELECT customer_id, first_name, city FROM customers WHERE city IN ('Chennai', 'Mumbai', 'Delhi') AND loyalty_points > 1000;
SELECT customer_id, first_name, loyalty_points FROM customers ORDER BY loyalty_points DESC LIMIT 5 OFFSET 5;

SHOW INDEX FROM tickets;
 
-- Before index: check the plan (look at 'type' = ALL, 'rows')
EXPLAIN SELECT * FROM bookings WHERE booking_date = '2026-06-15';
 
CREATE INDEX idx_bookings_date ON bookings(booking_date);                  -- normal index
CREATE INDEX idx_bookings_status_date ON bookings(status, booking_date);   -- composite index
CREATE INDEX idx_flights_departure ON flights(departure_time);
CREATE INDEX idx_flights_route ON flights(route_id);
CREATE INDEX idx_tickets_booking ON tickets(booking_id);
CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_customers_city ON customers(city);
CREATE UNIQUE INDEX idx_passengers_passport ON passengers(booking_id, passport_no);  -- unique index
CREATE FULLTEXT INDEX idx_airport_name_ft ON airports(airport_name, city);           -- full-text index

EXPLAIN SELECT * FROM bookings WHERE booking_date = '2026-06-15';
EXPLAIN SELECT * FROM flights WHERE departure_time BETWEEN '2026-06-01' AND '2026-06-30';
EXPLAIN SELECT c.city, COUNT(*) FROM customers c WHERE c.city = 'Chennai' GROUP BY c.city;
 
SELECT airport_name, city FROM airports WHERE MATCH(airport_name, city) AGAINST('Chennai');
 
SHOW INDEX FROM bookings;
DROP INDEX idx_customers_city ON customers;
 
 
 
 
 
 
 DELIMITER $$
 
-- Function 1: flight duration in minutes
DROP FUNCTION IF EXISTS fn_flight_duration$$
CREATE FUNCTION fn_flight_duration(p_flight_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_minutes INT;
    SELECT TIMESTAMPDIFF(MINUTE, departure_time, arrival_time) INTO v_minutes
    FROM flights WHERE flight_id = p_flight_id;
    RETURN v_minutes;
END$$
 
-- Function 2: ticket price with 5% GST
DROP FUNCTION IF EXISTS fn_fare_with_tax$$
CREATE FUNCTION fn_fare_with_tax(p_fare DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(p_fare * 1.05, 2);
END$$
 
-- Function 3: seats still available on a flight
DROP FUNCTION IF EXISTS fn_seats_available$$
CREATE FUNCTION fn_seats_available(p_flight_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT;
    DECLARE v_booked INT;
 
    SELECT t.total_seats INTO v_total
    FROM flights f
    JOIN aircraft a ON f.aircraft_id = a.aircraft_id
    JOIN aircraft_types t ON a.type_id = t.type_id
    WHERE f.flight_id = p_flight_id;
 
    SELECT COUNT(*) INTO v_booked
    FROM tickets WHERE flight_id = p_flight_id AND status <> 'Cancelled';
 
    RETURN v_total - v_booked;
END$$
 
-- Procedure 1: search flights (IN parameters)
DROP PROCEDURE IF EXISTS sp_search_flights$$
CREATE PROCEDURE sp_search_flights(IN p_source CHAR(3), IN p_destination CHAR(3), IN p_date DATE)
BEGIN
    SELECT f.flight_id, f.flight_number, al.airline_name, f.departure_time, f.arrival_time,
           f.base_fare, fn_seats_available(f.flight_id) AS seats_left
    FROM flights f
    JOIN airlines al ON f.airline_id = al.airline_id
    JOIN routes r ON f.route_id = r.route_id
    JOIN airports s ON r.source_airport_id = s.airport_id
    JOIN airports d ON r.destination_airport_id = d.airport_id
    WHERE s.iata_code = p_source
      AND d.iata_code = p_destination
      AND DATE(f.departure_time) = p_date
      AND f.status IN ('Scheduled', 'Delayed')
    ORDER BY f.departure_time;
END$$
 
-- Procedure 2: cancel a booking (OUT parameter + transaction + error handler)
DROP PROCEDURE IF EXISTS sp_cancel_booking$$
CREATE PROCEDURE sp_cancel_booking(IN p_booking_id INT, OUT p_message VARCHAR(100))
BEGIN
    DECLARE v_status VARCHAR(30);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: cancellation failed';
    END;
 
    SELECT status INTO v_status FROM bookings WHERE booking_id = p_booking_id;
 
    IF v_status IS NULL THEN
        SET p_message = 'Booking not found';
    ELSEIF v_status = 'Cancelled' THEN
        SET p_message = 'Booking already cancelled';
    ELSEIF v_status = 'Completed' THEN
        SET p_message = 'Flown booking cannot be cancelled';
    ELSE
        START TRANSACTION;
        UPDATE bookings SET status = 'Cancelled' WHERE booking_id = p_booking_id;
        UPDATE tickets SET status = 'Cancelled' WHERE booking_id = p_booking_id;
        UPDATE payments SET payment_status = 'Refunded' WHERE booking_id = p_booking_id AND payment_status = 'Success';
        COMMIT;
        SET p_message = 'Booking cancelled successfully';
    END IF;
END$$
 
-- Procedure 3: airline revenue (IN and OUT parameters)
DROP PROCEDURE IF EXISTS sp_airline_revenue$$
CREATE PROCEDURE sp_airline_revenue(IN p_airline_id INT, OUT p_revenue DECIMAL(14,2))
BEGIN
    SELECT IFNULL(SUM(t.fare), 0) INTO p_revenue
    FROM tickets t JOIN flights f ON t.flight_id = f.flight_id
    WHERE f.airline_id = p_airline_id AND t.status = 'Flown';
END$$
 
DELIMITER ;
 
-- Using the functions
SELECT flight_id, flight_number, fn_flight_duration(flight_id) AS duration_minutes,
       base_fare, fn_fare_with_tax(base_fare) AS fare_with_gst,
       fn_seats_available(flight_id) AS seats_left
FROM flights LIMIT 10;
 
-- Using the procedures
CALL sp_search_flights('KTM', 'IST', '2026-10-20');
CALL sp_airline_revenue(1, @revenue);
SELECT @revenue AS airline_1_revenue;
 
-- Pick a Confirmed booking and cancel it
SELECT booking_id INTO @cancel_id FROM bookings WHERE status = 'Confirmed' LIMIT 1;
CALL sp_cancel_booking(@cancel_id, @msg);
SELECT @cancel_id AS booking_id, @msg AS result;
SELECT booking_id, status FROM bookings WHERE booking_id = @cancel_id;
 
SHOW PROCEDURE STATUS WHERE Db = 'airline_reservation';
SHOW FUNCTION STATUS WHERE Db = 'airline_reservation';

SELECT COUNT(*) FROM bookings;
SELECT COUNT(*) FROM tickets;




DELIMITER $$
 
-- Trigger 1: log every new booking
DROP TRIGGER IF EXISTS trg_bookings_after_insert$$
CREATE TRIGGER trg_bookings_after_insert
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    INSERT INTO booking_audit (booking_id, action_type, old_status, new_status)
    VALUES (NEW.booking_id, 'INSERT', NULL, NEW.status);
END$$
 
-- Trigger 2: log booking status changes
DROP TRIGGER IF EXISTS trg_bookings_after_update$$
CREATE TRIGGER trg_bookings_after_update
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO booking_audit (booking_id, action_type, old_status, new_status)
        VALUES (NEW.booking_id, 'STATUS_CHANGE', OLD.status, NEW.status);
    END IF;
END$$
 
-- Trigger 3: validation - fare must be positive
DROP TRIGGER IF EXISTS trg_tickets_before_insert$$
CREATE TRIGGER trg_tickets_before_insert
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
    IF NEW.fare <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ticket fare must be greater than zero';
    END IF;
END$$
 
-- Trigger 4: add loyalty points (1 point per Rs.100) after a successful payment
DROP TRIGGER IF EXISTS trg_payments_after_insert$$
CREATE TRIGGER trg_payments_after_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'Success' THEN
        UPDATE customers
        SET loyalty_points = loyalty_points + FLOOR(NEW.amount / 100)
        WHERE customer_id = (SELECT customer_id FROM bookings WHERE booking_id = NEW.booking_id);
    END IF;
END$$
 
DELIMITER ;
 
SHOW TRIGGERS;
 
-- Test the audit trigger (the booking cancelled earlier is already logged)
SELECT * FROM booking_audit ORDER BY audit_id DESC LIMIT 5;
 
-- Test the validation trigger (this INSERT must FAIL with error 1644)
-- INSERT INTO tickets (ticket_number, booking_id, passenger_id, flight_id, seat_no, travel_class, fare, status)
-- VALUES ('TKERR0000001', 1, 1, 1, '88A', 'Economy', 0, 'Booked');
 
-- DROP TRIGGER trg_payments_after_insert;
 
-- Scheduled events (needs the event scheduler to be ON)
-- SET GLOBAL event_scheduler = ON;   -- needs admin privilege, run it only if you want the events to actually fire
SHOW VARIABLES LIKE 'event_scheduler';
 
DELIMITER $$
 
-- Event 1: every day mark finished flights as Landed
DROP EVENT IF EXISTS ev_update_landed_flights$$
CREATE EVENT ev_update_landed_flights
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE flights SET status = 'Landed'
    WHERE arrival_time < NOW() AND status IN ('Scheduled', 'Delayed');
END$$
 
-- Event 2: every hour fail payments that stayed Pending for more than 1 day
DROP EVENT IF EXISTS ev_expire_pending_payments$$
CREATE EVENT ev_expire_pending_payments
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE payments SET payment_status = 'Failed'
    WHERE payment_status = 'Pending' AND payment_date < CURDATE() - INTERVAL 1 DAY;
END$$
 
DELIMITER ;
 
SHOW EVENTS FROM airline_reservation;
-- ALTER EVENT ev_expire_pending_payments DISABLE;
-- DROP EVENT ev_expire_pending_payments;


-- value to booking_audit
DELIMITER $$

DROP TRIGGER IF EXISTS trg_bookings_after_insert$$
CREATE TRIGGER trg_bookings_after_insert
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    INSERT INTO booking_audit (booking_id, action_type, old_status, new_status)
    VALUES (NEW.booking_id, 'INSERT', NULL, NEW.status);
END$$

DROP TRIGGER IF EXISTS trg_bookings_after_update$$
CREATE TRIGGER trg_bookings_after_update
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO booking_audit (booking_id, action_type, old_status, new_status)
        VALUES (NEW.booking_id, 'STATUS_CHANGE', OLD.status, NEW.status);
    END IF;
END$$

DELIMITER ;

INSERT INTO booking_audit (booking_id, action_type, old_status, new_status)
SELECT booking_id, 'INSERT', NULL, status FROM bookings;

UPDATE bookings SET status = 'Cancelled' WHERE booking_id = 1 AND status <> 'Cancelled';
SELECT * FROM booking_audit ORDER BY audit_id DESC LIMIT 5;

