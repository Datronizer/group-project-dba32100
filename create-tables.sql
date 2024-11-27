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
    DvdYear DATE NOT NULL,
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

/* Now we proceed to INSERT data into these tables */
/* Starting with the enums */
INSERT ALL
    INTO DvdRating (Rating) VALUES ('3')
    INTO DvdRating (Rating) VALUES ('PG')
    INTO DvdRating (Rating) VALUES ('14A')
    INTO DvdRating (Rating) VALUES ('G')
    INTO DvdRating (Rating) VALUES ('R')
SELECT * FROM dual;

INSERT ALL
    INTO CustomerStatus (StatusEnum) VALUES ('Active')
    INTO CustomerStatus (StatusEnum) VALUES ('Amount Owing')
    INTO CustomerStatus (StatusEnum) VALUES ('Suspended')
    INTO CustomerStatus (StatusEnum) VALUES ('Inactive')
SELECT * FROM dual;

INSERT ALL
    INTO DvdActionOnReturn (ActionOnReturnEnum) VALUES ('Return to Shelf')
    INTO DvdActionOnReturn (ActionOnReturnEnum) VALUES ('Sell')
SELECT * FROM dual;


/* Now the rest */
INSERT ALL
    INTO Category (CategoryId, CatergoryName) VALUES (1, 'Action/Adventure')
    INTO Category (CategoryId, CatergoryName) VALUES (2, 'Biography')
    INTO Category (CategoryId, CatergoryName) VALUES (3, 'Children')
    INTO Category (CategoryId, CatergoryName) VALUES (4, 'Comedy')
    INTO Category (CategoryId, CatergoryName) VALUES (5, 'Drama')
    INTO Category (CategoryId, CatergoryName) VALUES (6, 'Horror')
    INTO Category (CategoryId, CatergoryName) VALUES (7, 'Musical')
    INTO Category (CategoryId, CatergoryName) VALUES (8, 'Science Fiction')
SELECT * FROM dual;

INSERT ALL
    INTO Customer (CustomerId, CustomerInitials, FirstName, LastName, PhoneNumber, Birthdate, DriverLicenseNumber, Status) VALUES (1, 'EV', 'Edward', 'Vongsaphay', '(905) 555-8932', TO_DATE('01/01/1990', 'MM/DD/YYYY'), '537597397', 'Active')
    INTO Customer (CustomerId, CustomerInitials, FirstName, LastName, PhoneNumber, Birthdate, DriverLicenseNumber, Status) VALUES (2, 'FE', 'Fiona', 'Esposito', '(905) 345-3920', TO_DATE('03/28/1955', 'MM/DD/YYYY'), '232323290', 'Active')
    INTO Customer (CustomerId, CustomerInitials, FirstName, LastName, PhoneNumber, Birthdate, DriverLicenseNumber, Status) VALUES (3, 'GS', 'Graeme', 'Sands', '(416) 849-5391', TO_DATE('11/30/1973', 'MM/DD/YYYY'), '492830981', 'Amount Owing')
    INTO Customer (CustomerId, CustomerInitials, FirstName, LastName, PhoneNumber, Birthdate, DriverLicenseNumber, Status) VALUES (4, 'MA', 'Margeret', 'Armstrong', '(905) 745-7342', TO_DATE('06/19/1968', 'MM/DD/YYYY'), '987654336', 'Suspended')
    INTO Customer (CustomerId, CustomerInitials, FirstName, LastName, PhoneNumber, Birthdate, DriverLicenseNumber, Status) VALUES (5, 'MM', 'Michael', 'McGuinty', '(905) 648-3246', TO_DATE('03/30/1984', 'MM/DD/YYYY'), '345678998', 'Active')
    INTO Customer (CustomerId, CustomerInitials, FirstName, LastName, PhoneNumber, Birthdate, DriverLicenseNumber, Status) VALUES (6, 'PC', 'Phil', 'Charest', '(416) 371-3979', TO_DATE('12/10/1980', 'MM/DD/YYYY'), '604604047', 'Suspended')
    INTO Customer (CustomerId, CustomerInitials, FirstName, LastName, PhoneNumber, Birthdate, DriverLicenseNumber, Status) VALUES (7, 'PC', 'Paula', 'Chow', '(416) 635-5555', TO_DATE('12/10/1979', 'MM/DD/YYYY'), '000123000', 'Inactive')
SELECT * FROM dual;

INSERT ALL
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (1, 'Elizabeth: The Golden Age', TO_DATE('2018', 'YYYY'), 5.29, 5, 'PG', 'Y', 'Return to Shelf')
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (2, 'The Bourne Ultimatum', TO_DATE('2006', 'YYYY'), 3.99, 1, 'PG', 'N', 'Sell')
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (3, 'Shrek 2', TO_DATE('2004', 'YYYY'), 3.99, 3, '3', 'N', 'Return to Shelf')
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (4, 'Ace Ventura, Pet Detective', TO_DATE('2004', 'YYYY'), 3.99, 4, '14A', 'N', 'Sell')
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (5, 'Hairspray', TO_DATE('2017', 'YYYY'), 5.29, 7, 'PG', 'N', 'Sell')
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (6, 'A Charlie Brown Christmas', TO_DATE('2000', 'YYYY'), 3.99, 3, 'G', 'N', 'Return to Shelf')
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (7, 'Leonard Cohen: I''m Your Man', TO_DATE('2022', 'YYYY'), 3.99, 2, 'PG', 'Y', 'Return to Shelf')
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (8, 'Nightmare on Elm Street', TO_DATE('1999', 'YYYY'), 3.99, 6, 'R', 'Y', 'Return to Shelf')
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (9, 'Star Trek: Nemesis', TO_DATE('2005', 'YYYY'), 3.99, 8, 'PG', 'Y', 'Return to Shelf')
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (10, 'The King''s Speech', TO_DATE('2020', 'YYYY'), 5.29, 5, 'R', 'Y', 'Return to Shelf')
    INTO Dvd (DvdId, DvdTitle, DvdYear, DvdCost, CategoryId, Rating, RentedOut, ActionOnReturn) VALUES (11, 'True Grit', TO_DATE('2020', 'YYYY'), 5.29, 1, 'PG', 'Y', 'Return to Shelf')
SELECT * FROM dual;

INSERT ALL
    INTO Rental (RentalID, RentalDate, CustomerId, DvdId) VALUES (1001, TO_DATE('12/02/2011', 'MM/DD/YYYY'), 2, 10)
    INTO Rental (RentalID, RentalDate, CustomerId, DvdId) VALUES (1002, TO_DATE('12/02/2011', 'MM/DD/YYYY'), 2, 3)
    INTO Rental (RentalID, RentalDate, CustomerId, DvdId) VALUES (1003, TO_DATE('12/02/2011', 'MM/DD/YYYY'), 5, 6)
    INTO Rental (RentalID, RentalDate, CustomerId, DvdId) VALUES (1004, TO_DATE('12/07/2011', 'MM/DD/YYYY'), 6, 1)
    INTO Rental (RentalID, RentalDate, CustomerId, DvdId) VALUES (1005, TO_DATE('12/07/2011', 'MM/DD/YYYY'), 3, 7)
    INTO Rental (RentalID, RentalDate, CustomerId, DvdId) VALUES (1006, TO_DATE('12/07/2011', 'MM/DD/YYYY'), 3, 9)
SELECT * FROM dual;



-- This bottom part can be commented in and will work immediately
--
---- Just in case, quick drop table
---- Drop the tables in reverse order of creation to avoid foreign key constraint issues
--DROP TABLE Rental;
--DROP TABLE Customer;
--DROP TABLE Dvd;
--DROP TABLE Category;
--
---- Drop the enum tables last
--DROP TABLE DvdActionOnReturn;
--DROP TABLE CustomerStatus;
--DROP TABLE DvdRating;