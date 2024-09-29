
-- Exercise: Create SQL queries to check available bookings based on user input
-- Task 1: Replicate the list of records
INSERT INTO customer (customerID) VALUES(1),(2),(3),(4);
INSERT INTO bookings(BookingID, Date, TableNo, CustomerID) VALUES (1,"2022-10-10",5,1), (2,"2022-11-12",3,3), (3,"2022-10-11",2,2), (4,"2022-10-13",2,1);
SELECT * FROM bookings; 

-- Task 2: Create a stored procedure called CheckBooking to check whether a table in the restaurant is already booked (The procedure should have two input parameters in the form of booking date and table number)
DELIMITER //

DROP PROCEDURE IF EXISTS CheckBooking; 
CREATE PROCEDURE CheckBooking(IN bookdate DATE, IN tablenumber INT)
BEGIN 
SELECT CASE 
WHEN bookings.TableNo = tablenumber AND bookings.Date = bookdate THEN CONCAT('Table ', tablenumber, ' is already booked') 
ELSE CONCAT('Table ', tablenumber, ' is not booked yet, can book')
END AS "Booking Status" FROM bookings
WHERE bookings.TableNo = tablenumber AND bookings.Date = bookdate;
END 
// 
DELIMITER ;
CALL CheckBooking("2022-11-12", 3 )

-- Task 3: Verify a booking, and decline any reservations for tables that are already booked under another name. 
ALTER TABLE bookings 
MODIFY COLUMN BookingID INT NOT NULL AUTO_INCREMENT;
ALTER TABLE bookings
DROP constraint FK_bookings_customerid;
DROP PROCEDURE IF EXISTS AddValidBookings;
DELIMITER //
CREATE PROCEDURE AddValidBookings (IN bookdate DATE, IN tablenumber INT)
BEGIN

START TRANSACTION;
SELECT COUNT(*)+1 INTO @assigned_customer FROM Bookings;
SELECT COUNT(*) INTO @checks FROM Bookings AS a
WHERE a.TableNo = tablenumber AND a.Date= bookdate ;
IF @checks > 0 
	THEN ROLLBACK;
    SELECT CONCAT('Table ', tablenumber, ' is already booked - booking canceled') AS 'Booking Status';
ELSE 
	INSERT INTO bookings(Date, TableNo, CustomerID) VALUES (bookdate, tablenumber, @assigned_customer); 
    COMMIT;
    SELECT CONCAT('Table ', tablenumber, ' have been reserved successfully') AS 'Booking Status' ;
END IF;

END//
CALL AddValidBookings("2022-12-17", 6 );

--  Exercise: Create SQL queries to add and update bookings
-- Task 1: In this first task you need to create a new procedure called AddBooking to add a new table booking record.
DROP PROCEDURE IF EXISTS AddBooking;
DELIMITER //
CREATE PROCEDURE AddBooking(IN Booking_ID INT, IN CUSTOMER_ID INT, IN TableNo INT, IN BookingDate DATE)
BEGIN  
START TRANSACTION;
SELECT COUNT(*) INTO @check1 FROM bookings WHERE bookings.BookingID = Booking_ID;
IF @check1 > 0 
	THEN ROLLBACK;
    SELECT CONCAT("The bookings ", CUSTOMER_ID, " is already exists") AS "Booking Status";
ELSE 
	INSERT Bookings(BookingID, Date, TableNo, CustomerID) VALUES (Booking_ID, BookingDate , TableNo,CUSTOMER_ID );
	COMMIT;
	SELECT CONCAT("Adding successfuly");
END IF;
END //
CALL AddBooking(9,3,4, "2022-12-20");

DROP PROCEDURE IF EXISTS UpdateBooking;
DELIMITER //
CREATE PROCEDURE UpdateBooking(IN Booking_ID INT, IN BookingDate DATE)
BEGIN  
START TRANSACTION;
	SELECT COUNT(*) INTO @check1 FROM bookings WHERE bookings.BookingID = Booking_ID;
    IF @check1 > 0 THEN
		UPDATE Bookings
		SET bookings.date= BookingDate 
		WHERE BookingID = Booking_ID;
		COMMIT;
		SELECT CONCAT("UPDATING SUCCESSFULLY") AS "Booking Status";
	ELSE 
		SELECT CONCAT("NOT EXISTS BOOKINGS, TRY AGAIN") AS "Booking Status";
	END IF;
END //
CALL UpdateBooking(100, "2022-12-17");

