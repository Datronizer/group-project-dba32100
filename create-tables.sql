CREATE TABLE DvdRentals.Category (
    CategoryId INT PRIMARY KEY,
    CatergoryName VARCHAR2(50)
);

CREATE TABLE DvdRentals.Dvd (
    DvdId INT PRIMARY KEY,
    DvdTitle VARCHAR2(50) NOT NULL,
    DvdYear DATE NOT NULL,
    DvdCost FLOAT NOT NULL,
    
    CategoryId INT,
    Rating VARCHAR(5),
    
    RentedOut BOOLEAN,
    ActionOnReturn ENUM 
--    ('Return to Shelf', 'Sell') 
    NOT NULL
);
CREATE TABLE DvdRentals.Customer;
CREATE TABLE DvdRentals.Rental;
CREATE TABLE DvdRentals.Rating;