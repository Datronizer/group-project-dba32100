SET SERVEROUTPUT ON;
---- BEFORE ANY PART BEGINS ----
/*
    Since our accounts are not allowed to create new users. We will now assume
    that Leader1, 2, and 3 are placeholders for our respective DB usernames.
    
    Thus henceforth, the usernames are as follows:
    - Leader1: S16_TRUONCHI
    - Leader2: S16_ESGUERCA
    - Leader3: S16_NGUYE617
    
    Now we begin.
*/

---- PART A ----
-- TABLE CREATION done by S16_TRUONCHI --

-- Create the enums first
CREATE TABLE DvdRating (
    Rating VARCHAR2(5) PRIMARY KEY  --('PG', 'G', 'R', '14A', '3')
);
CREATE TABLE CustomerStatus (
    StatusEnum VARCHAR2(20) PRIMARY KEY  --('Active', 'Amount Owing', 'Suspended', 'Inactive')
);
CREATE TABLE DvdActionOnReturn(
    ActionOnReturnEnum VARCHAR2(20) PRIMARY KEY  --('Return to Shelf', 'Sell')
);

-- Now make the rest of the tables IN ORDER
CREATE TABLE Category (
    CategoryId INT PRIMARY KEY,
    CatergoryName VARCHAR2(50) NOT NULL
);
CREATE TABLE Dvd (
    DvdId INT PRIMARY KEY,
    DvdTitle VARCHAR2(50) NOT NULL,
    DvdYear NUMBER NOT NULL,  -- if it's just the year then DATE is redundant
    DvdCost FLOAT NOT NULL,
    
    CategoryId INT,
    Rating VARCHAR2(5),
    
    RentedOut CHAR(1), -- 'Y' or 'N'
    ActionOnReturn VARCHAR2(20),
    
    FOREIGN KEY (CategoryId) REFERENCES Category(CategoryId),
    FOREIGN KEY (Rating) REFERENCES DvdRating(Rating),
    FOREIGN KEY (ActionOnReturn) REFERENCES DvdActionOnReturn(ActionOnReturnEnum)
);
CREATE TABLE Customer (
    CustomerId INT PRIMARY KEY,
    CustomerInitials VARCHAR2(2) NOT NULL,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    PhoneNumber VARCHAR2(20) NOT NULL,
    Birthdate DATE NOT NULL,
    DriverLicenseNumber VARCHAR2(20) NOT NULL,
    Status VARCHAR2(20),
    
    FOREIGN KEY (Status) REFERENCES CustomerStatus(StatusEnum)
);
CREATE TABLE Rental (
    RentalID NUMBER(4) PRIMARY KEY,
    RentalDate DATE NOT NULL,
    CustomerId INT,
    DvdId INT,
    
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
    FOREIGN KEY (DvdId) REFERENCES Dvd(DvdId)
);

/* 
    WARNING 
    Please run the Talend job to import data from provided CSV files first
    If you don't run the job, the rest of this will literally not work, as 
    intended by the Project Guidelines.
    
    The Talend testing portion will be commented out to ensure "Run all" works
    smoothly.
*/

---- Test Talend imports
--SELECT * FROM DvdRating;
--SELECT * FROM CustomerStatus;
--SELECT * FROM DvdActionOnReturn;
--
--SELECT * FROM Category;
--SELECT * FROM Customer;
--SELECT * FROM Dvd;
--SELECT * FROM Rental;

-- Pass perms to S16_ESGUERCA and S16_NGUYE617
BEGIN
  FOR t IN (SELECT table_name FROM user_tables) LOOP
    EXECUTE IMMEDIATE 'GRANT SELECT ON ' || t.table_name || ' TO S16_ESGUERCA';
    EXECUTE IMMEDIATE 'GRANT SELECT ON ' || t.table_name || ' TO S16_NGUYE617';
  END LOOP;
END;


----------------
---- PART B ----
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
/

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
CREATE OR REPLACE PROCEDURE ShowCustomerMovieRentals AS
BEGIN
    -- Show the names of the customers, movie name, and the number of movies rented by them
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
/
---

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
            DvdCost - AVG(DvdCost) OVER (PARTITION BY DvdYear) AS CostDifference
        FROM 
            Dvd;
    RETURN dvd_cursor;
END;
/
----

 testing the show customer movie rentals procedure:
BEGIN
    ShowCustomerMovieRentals;
END;



 testing the dvd cost difference function:
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


--testing for the insert:
DECLARE
    v_CustomerId Customer.CustomerId%TYPE := &CustomerId;
    v_CustomerInitials Customer.CustomerInitials%TYPE := '&CustomerInitials';
    v_FirstName Customer.FirstName%TYPE := '&FirstName';
    v_LastName Customer.LastName%TYPE := '&LastName';
    v_PhoneNumber Customer.PhoneNumber%TYPE := '&PhoneNumber';
    v_Birthdate Customer.Birthdate%TYPE := TO_DATE('&Birthdate', 'MM/DD/YYYY');
    v_DriverLicenseNumber Customer.DriverLicenseNumber%TYPE := '&DriverLicenseNumber';
    v_Status Customer.Status%TYPE := '&Status';
BEGIN
    InsertCustomer(v_CustomerId, v_CustomerInitials, v_FirstName, v_LastName, v_PhoneNumber, v_Birthdate, v_DriverLicenseNumber, v_Status);
END;
/
SELECT * FROM Customer;
--


-- testing for the update:
DECLARE
    v_CustomerId Customer.CustomerId%TYPE := &CustomerId;
    v_PhoneNumber Customer.PhoneNumber%TYPE := '&PhoneNumber';
    v_Status Customer.Status%TYPE := '&Status';
BEGIN
    UpdateCustomer(v_CustomerId, v_PhoneNumber, v_Status);
END;
/
SELECT * FROM Customer;

-- testing for the delete:
DECLARE
    v_CustomerId Customer.CustomerId%TYPE := &CustomerId;
BEGIN
    DeleteCustomer(v_CustomerId);
END;
/
SELECT * FROM Customer;


----------------
---- PART C ----
-- Create the Year table
-- Create Rating Table
CREATE TABLE PartCDvdRating (
    Rating VARCHAR2(5) PRIMARY KEY  --('PG', 'G', 'R', '14A', '3')
);
/
-- Create ActionOnReturn Table
CREATE TABLE PartCDvdActionOnReturn (
    ActionOnReturnEnum VARCHAR2(20) PRIMARY KEY
);
/
-- Create Category Table with Surrogate Key
CREATE TABLE PartCCategory (
    CategoryId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CategoryName VARCHAR2(50) NOT NULL
);
/
-- Create Customer Table with Surrogate Key
CREATE TABLE PartCCustomer (
    CustomerId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CustomerInitials VARCHAR2(2) NOT NULL,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    PhoneNumber VARCHAR2(20) NOT NULL,
    Birthdate DATE NOT NULL,
    DriverLicenseNumber VARCHAR2(20) NOT NULL,
    Status VARCHAR2(20) NOT NULL
);
/
-- Create Year Table with Surrogate Key
CREATE TABLE PartCYear (
    YearId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Year INT NOT NULL
);
/
-- Create Rental Table
CREATE TABLE PartCRental (
    RentalID NUMBER(4) PRIMARY KEY,
    RentalDate DATE NOT NULL,
    CustomerId INT,
    DvdId INT,
    
    FOREIGN KEY (CustomerId) REFERENCES PartCCustomer(CustomerId),
    FOREIGN KEY (DvdId) REFERENCES Dvd(DvdId)
);
/
-- Now we populate them
-- Populate PartCCategory Table
INSERT INTO PartCCategory (CategoryName)
SELECT DISTINCT cat.CatergoryName
FROM Dvd d
JOIN Category cat ON d.CategoryId = cat.CategoryId;
/
-- Populate PartCCustomer Table
INSERT INTO PartCCustomer (CustomerInitials, FirstName, LastName, PhoneNumber, Birthdate, DriverLicenseNumber, Status)
SELECT DISTINCT c.CustomerInitials, c.FirstName, c.LastName, c.PhoneNumber, c.Birthdate, c.DriverLicenseNumber, c.Status
FROM Dvd d
JOIN Rental r ON d.DvdId = r.DvdId
JOIN Customer c ON r.CustomerId = c.CustomerId;
/
-- Populate PartCYear Table
INSERT INTO PartCYear (Year)
SELECT DISTINCT DvdYear FROM Dvd;
/
-- Populate PartCDvdRating Table
INSERT INTO PartCDvdRating (Rating)
SELECT DISTINCT Rating FROM Dvd;
/
-- Populate PartCDvdActionOnReturn Table
INSERT INTO PartCDvdActionOnReturn (ActionOnReturnEnum)
SELECT DISTINCT ActionOnReturn FROM Dvd;

DECLARE
    v_DvdId Dvd.DvdId%TYPE;
    v_RentalDate Rental.RentalDate%TYPE;
    v_CustomerId Rental.CustomerId%TYPE;
    v_CategoryId Dvd.CategoryId%TYPE;
    v_DvdYear Dvd.DvdYear%TYPE;
    v_CustomerKey INT;
    v_CategoryKey INT;
    v_YearKey INT;
    CURSOR dvd_cursor IS
        SELECT d.DvdId, r.RentalDate, r.CustomerId, d.CategoryId, d.DvdYear
        FROM Dvd d
        JOIN Rental r ON d.DvdId = r.DvdId;
BEGIN
    OPEN dvd_cursor;
    LOOP
        FETCH dvd_cursor INTO v_DvdId, v_RentalDate, v_CustomerId, v_CategoryId, v_DvdYear;
        EXIT WHEN dvd_cursor%NOTFOUND;

        -- Debugging output
        DBMS_OUTPUT.PUT_LINE('DvdId: ' || v_DvdId || ', RentalDate: ' || v_RentalDate || ', CustomerId: ' || v_CustomerId || ', CategoryId: ' || v_CategoryId || ', DvdYear: ' || v_DvdYear);

        -- Get surrogate keys
        BEGIN
            SELECT CustomerId INTO v_CustomerKey 
            FROM PartCCustomer 
            WHERE CustomerId = v_CustomerId AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_CustomerKey := NULL;
            WHEN TOO_MANY_ROWS THEN
                v_CustomerKey := NULL;
        END;

        BEGIN
            SELECT CategoryId INTO v_CategoryKey 
            FROM PartCCategory 
            WHERE CategoryId = v_CategoryId AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_CategoryKey := NULL;
            WHEN TOO_MANY_ROWS THEN
                v_CategoryKey := NULL;
        END;

        BEGIN
            SELECT YearId INTO v_YearKey 
            FROM PartCYear 
            WHERE Year = v_DvdYear AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_YearKey := NULL;
            WHEN TOO_MANY_ROWS THEN
                v_YearKey := NULL;
        END;

        -- Insert into fact table
        INSERT INTO PartCRental (RentalID, RentalDate, CustomerId, DvdId)
        VALUES (v_DvdId, v_RentalDate, v_CustomerKey, v_DvdId);
    END LOOP;
    CLOSE dvd_cursor;
END;
/
SELECT * FROM PartCRental;

------------------------------
---- ONLY FOR EMERGENCIES ----
---- This bottom part can be commented in and will work immediately
----
---- In case of emergency reset, quick drop table
---- Drop the tables in reverse order of creation to avoid constraint issues
DROP TABLE PartCDvdActionOnReturn;
DROP TABLE PartCCategory;
DROP TABLE PartCDvdRating;
DROP TABLE PartCYear;
DROP TABLE PartCRental;
DROP TABLE PartCCustomer;

--DROP TABLE Rental;
--DROP TABLE Customer;
--DROP TABLE Dvd;
--DROP TABLE Category;
--
---- Drop the enum tables last
--DROP TABLE DvdActionOnReturn;
--DROP TABLE CustomerStatus;
--DROP TABLE DvdRating;