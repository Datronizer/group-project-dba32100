-- Insert data
CREATE OR REPLACE PROCEDURE InsertCustomer (
    p_CustomerId IN Customer.CustomerId%TYPE,
    p_CustomerInitials IN Customer.CustomerInitials%TYPE,
    p_FirstName IN Customer.FirstName%TYPE,
    p_LastName IN Customer.LastName%TYPE,
    p_PhoneNumber IN Customer.PhoneNumber%TYPE,
    p_Birthdate IN Customer.Birthdate%TYPE,
    p_DriverLicenseNumber IN Customer.DriverLicenseNumber%TYPE,
    p_Status IN Customer.Status%TYPE
) AS
BEGIN
    INSERT INTO Customer (CustomerId, CustomerInitials, FirstName, LastName, PhoneNumber, Birthdate, DriverLicenseNumber, Status)
    VALUES (p_CustomerId, p_CustomerInitials, p_FirstName, p_LastName, p_PhoneNumber, p_Birthdate, p_DriverLicenseNumber, p_Status);
    COMMIT;
END;
--Update data
CREATE OR REPLACE PROCEDURE UpdateCustomer (
    p_CustomerId IN Customer.CustomerId%TYPE,
    p_PhoneNumber IN Customer.PhoneNumber%TYPE,
    p_Status IN Customer.Status%TYPE
) AS
BEGIN
    UPDATE Customer
    SET PhoneNumber = p_PhoneNumber,
        Status = p_Status
    WHERE CustomerId = p_CustomerId;
    COMMIT;
END;
/
-- Delete data
CREATE OR REPLACE PROCEDURE DeleteCustomer (
    p_CustomerId IN Customer.CustomerId%TYPE
) AS
BEGIN
    DELETE FROM Customer
    WHERE CustomerId = p_CustomerId;
    COMMIT;
END;
/
---
--Task a: Show the customer name and DVD name along with rental cost in a list starting 
--from the least renting cost to the highest renting cost using analytical functions.
SELECT 
    c.FirstName || ' ' || c.LastName AS CustomerName,
    d.DvdTitle,
    d.DvdCost,
    RANK() OVER (ORDER BY d.DvdCost ASC) AS CostRank
FROM 
    Rental r
JOIN 
    Customer c ON r.CustomerId = c.CustomerId
JOIN 
    Dvd d ON r.DvdId = d.DvdId
ORDER BY 
    d.DvdCost ASC;
    
----------------
-- Task b: Show the titles and cost of DVDs with the third and
-- fourth highest price using Analytical Functions.
SELECT 
    DvdTitle,
    DvdCost
FROM(
    SELECT 
        DvdTitle,
        DvdCost,
        ROW_NUMBER() OVER (ORDER BY DvdCost DESC) AS PriceRank
    FROM 
        Dvd
)
WHERE 
    PriceRank IN (3, 4);
---
--Task 1: Show the names of the customers, movie name, and the number of 
--movies rented by them. Make sure to show subtotals as per customer 
--(number of movies rented) and subtotal for each movie showing how many times that movie was rented.


--part one, showing the movie rentals:
CREATE OR REPLACE PROCEDURE ShowCustomerMovieRentals AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Customer Name | Movie Name | Number of Rentals');
    FOR rec IN (
        SELECT 
            c.FirstName || ' ' || c.LastName AS CustomerName,
            d.DvdTitle,
            COUNT(r.RentalID) AS NumberOfRentals
        FROM 
            Rental r
        JOIN 
            Customer c ON r.CustomerId = c.CustomerId
        JOIN 
            Dvd d ON r.DvdId = d.DvdId
        GROUP BY 
            c.FirstName || ' ' || c.LastName, d.DvdTitle
        ORDER BY 
            c.FirstName || ' ' || c.LastName, d.DvdTitle
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.CustomerName || ' | ' || rec.DvdTitle || ' | ' || rec.NumberOfRentals);
    END LOOP;
END;

-- part two showing the subtotal:
CREATE OR REPLACE PROCEDURE ShowSubtotals AS
BEGIN
    -- Show subtotals per customer
    DBMS_OUTPUT.PUT_LINE('Customer Name | Total Rentals');
    FOR rec IN (
        SELECT 
            c.FirstName || ' ' || c.LastName AS CustomerName,
            COUNT(r.RentalID) AS TotalRentals
        FROM 
            Rental r
        JOIN 
            Customer c ON r.CustomerId = c.CustomerId
        GROUP BY 
            c.FirstName || ' ' || c.LastName
        ORDER BY 
            c.FirstName || ' ' || c.LastName
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.CustomerName || ' | ' || rec.TotalRentals);
    END LOOP;

    -- Show subtotals per movie
    DBMS_OUTPUT.PUT_LINE('Movie Name | Total Rentals');
    FOR rec IN (
        SELECT 
            d.DvdTitle,
            COUNT(r.RentalID) AS TotalRentals
        FROM 
            Rental r
        JOIN 
            Dvd d ON r.DvdId = d.DvdId
        GROUP BY 
            d.DvdTitle
        ORDER BY 
            d.DvdTitle
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.DvdTitle || ' | ' || rec.TotalRentals);
    END LOOP;
END;

----Task 2: What is the difference between DVD cost and the average cost of all the DVDs of each year.
CREATE OR REPLACE FUNCTION DvdCostDifference
RETURN SYS_REFCURSOR AS
    dvd_cursor SYS_REFCURSOR;
BEGIN
    OPEN dvd_cursor FOR
        SELECT 
            DvdTitle,
            DvdCost,
            DvdYear,
            DvdCost - AVG(DvdCost) OVER (PARTITION BY EXTRACT(YEAR FROM DvdYear)) AS CostDifference
        FROM 
            Dvd;
    RETURN dvd_cursor;
END;
----

-- testing the show customer movie rentals and subtotal procedures:
SET SERVEROUTPUT ON;
BEGIN
    ShowCustomerMovieRentals;
END;
--
SET SERVEROUTPUT ON;
BEGIN
    ShowSubtotals;
END;

--
--
-- testing the dvd cost difference function:
SET SERVEROUTPUT ON;
DECLARE
    dvd_rec SYS_REFCURSOR;
    dvd_title Dvd.DvdTitle%TYPE;
    dvd_cost Dvd.DvdCost%TYPE;
    dvd_year Dvd.DvdYear%TYPE;
    cost_difference NUMBER;
BEGIN
    dvd_rec := DvdCostDifference;
    LOOP
        FETCH dvd_rec INTO dvd_title, dvd_cost, dvd_year, cost_difference;
        EXIT WHEN dvd_rec%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Title: ' || dvd_title || ', Year: ' || dvd_year || ', Cost: ' || dvd_cost || ', Difference: ' || cost_difference);
    END LOOP;
    CLOSE dvd_rec;
END;

--
--
--
-- testing for the insert:
--DECLARE
--    v_CustomerId Customer.CustomerId%TYPE := '&CustomerId';
--    v_CustomerInitials Customer.CustomerInitials%TYPE := '&CustomerInitials';
--    v_FirstName Customer.FirstName%TYPE := '&FirstName';
--    v_LastName Customer.LastName%TYPE := '&LastName';
--    v_PhoneNumber Customer.PhoneNumber%TYPE := '&PhoneNumber';
--    v_Birthdate Customer.Birthdate%TYPE := TO_DATE('&Birthdate', 'MM/DD/YYYY');
--    v_DriverLicenseNumber Customer.DriverLicenseNumber%TYPE := '&DriverLicenseNumber';
--   v_Status Customer.Status%TYPE := '&Status';
--BEGIN
--   InsertCustomer(v_CustomerId, v_CustomerInitials, v_FirstName, v_LastName, v_PhoneNumber, v_Birthdate, v_DriverLicenseNumber, v_Status);
--END; --side note. status has to be with a first capital letter or it wont work since status is an Enum lmao 
--SELECT * FROM Customer
---
--
--
--- testing for the update:
--DECLARE
--    v_CustomerId Customer.CustomerId%TYPE := &CustomerId;
--    v_PhoneNumber Customer.PhoneNumber%TYPE := '&PhoneNumber';
--    v_Status Customer.Status%TYPE := '&Status';
--BEGIN
--    UpdateCustomer(v_CustomerId, v_PhoneNumber, v_Status);
--END;
--
--
--- testing for the delete:
--DECLARE
--    v_CustomerId Customer.CustomerId%TYPE := &CustomerId;
--BEGIN
--    DeleteCustomer(v_CustomerId);
--END;
/