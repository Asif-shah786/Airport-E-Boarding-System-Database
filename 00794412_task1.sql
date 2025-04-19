-- Task 1: Airport E-Boarding System Database Implementation
-- Student ID: 00794412

-- =============================================
-- 1. Database Creation and Setup
-- =============================================

-- ---------------------------------------------
-- 1.1: Drop Existing Database
-- ---------------------------------------------
USE master;
GO

-- Close all existing connections to the database
IF EXISTS (SELECT name
FROM sys.databases
WHERE name = 'AirportEBoarding')
BEGIN
    -- Kill all active connections to the database
    DECLARE @kill varchar(8000) = '';
    SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) + ';'
    FROM sys.dm_exec_sessions
    WHERE database_id = DB_ID('AirportEBoarding');

    EXEC(@kill);

    -- Drop the database
    DROP DATABASE AirportEBoarding;
    PRINT 'Database AirportEBoarding has been dropped successfully.';
END
ELSE
BEGIN
    PRINT 'Database AirportEBoarding does not exist.';
END
GO

-- ---------------------------------------------
-- 1.2: Create New Database
-- ---------------------------------------------
CREATE DATABASE AirportEBoarding;
PRINT 'Database AirportEBoarding has been created successfully.';
GO

-- ---------------------------------------------
-- 1.3: Use the Database
-- ---------------------------------------------
USE AirportEBoarding;
GO

-- =============================================
-- 2. Table Creation (in correct dependency order)
-- =============================================
-- The database is designed to 3NF (Third Normal Form) with the following normalization approach:
-- 1. First Normal Form (1NF): All tables have a primary key and no repeating groups
-- 2. Second Normal Form (2NF): All non-key attributes are fully dependent on the primary key
-- 3. Third Normal Form (3NF): No transitive dependencies exist

-- Drop existing tables if they exist (in reverse dependency order)
IF OBJECT_ID('AdditionalServices', 'U') IS NOT NULL DROP TABLE AdditionalServices;
IF OBJECT_ID('Baggage', 'U') IS NOT NULL DROP TABLE Baggage;
IF OBJECT_ID('Tickets', 'U') IS NOT NULL DROP TABLE Tickets;
IF OBJECT_ID('Reservations', 'U') IS NOT NULL DROP TABLE Reservations;
IF OBJECT_ID('Flights', 'U') IS NOT NULL DROP TABLE Flights;
IF OBJECT_ID('Passengers', 'U') IS NOT NULL DROP TABLE Passengers;
IF OBJECT_ID('Employees', 'U') IS NOT NULL DROP TABLE Employees;
GO

-- Create Employees table (no dependencies)
CREATE TABLE Employees
(
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    -- Primary key, auto-incrementing
    Username VARCHAR(50) NOT NULL UNIQUE,
    -- Unique username for login
    Password VARCHAR(100) NOT NULL,
    -- Password for authentication
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Ticketing Staff', 'Ticketing Supervisor')),
    -- Role constraint
    Email VARCHAR(100) NOT NULL UNIQUE,
    -- Unique email address
    Name VARCHAR(100) NOT NULL
    -- Employee's full name
);
GO

-- Create Passengers table (no dependencies)
CREATE TABLE Passengers
(
    PassengerID INT IDENTITY(1,1) PRIMARY KEY,
    -- Primary key, auto-incrementing
    PNR VARCHAR(10) NOT NULL UNIQUE,
    -- Passenger Name Record, unique identifier
    Email VARCHAR(100) NOT NULL,
    -- Email address for communication
    MealPreference VARCHAR(20) NOT NULL CHECK (MealPreference IN ('vegetarian', 'non-vegetarian')),
    -- Meal preference constraint
    DateOfBirth DATE NOT NULL,
    -- Date of birth for age calculation
    FirstName VARCHAR(50) NOT NULL,
    -- Passenger's first name
    LastName VARCHAR(50) NOT NULL,
    -- Passenger's last name
    EmergencyContact VARCHAR(20) NULL
    -- Emergency contact number (optional)
);
GO

-- Create Flights table (no dependencies)
CREATE TABLE Flights
(
    FlightID INT IDENTITY(1,1) PRIMARY KEY,
    -- Primary key, auto-incrementing
    FlightNumber VARCHAR(10) NOT NULL UNIQUE,
    -- Unique flight number
    DepartureTime DATETIME NOT NULL,
    -- Scheduled departure time
    ArrivalTime DATETIME NOT NULL,
    -- Scheduled arrival time
    Origin VARCHAR(50) NOT NULL,
    -- Departure airport
    Destination VARCHAR(50) NOT NULL,
    -- Arrival airport
    CONSTRAINT CheckArrivalAfterDeparture CHECK (ArrivalTime > DepartureTime)
    -- Ensure arrival is after departure
);
GO

-- Create Reservations table (depends on Passengers and Flights)
CREATE TABLE Reservations
(
    ReservationID INT IDENTITY(1,1) PRIMARY KEY,
    -- Primary key, auto-incrementing
    PNR VARCHAR(10) NOT NULL,
    -- Foreign key to Passengers table
    FlightID INT NOT NULL,
    -- Foreign key to Flights table
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('confirmed', 'pending', 'cancelled')),
    -- Reservation status
    ReservationDate DATE NOT NULL,
    -- Date when reservation was made
    PreferredSeat VARCHAR(10) NULL,
    -- Preferred seat number (optional)
    CONSTRAINT FK_Reservations_Passengers FOREIGN KEY (PNR) REFERENCES Passengers(PNR),
    -- Foreign key constraint
    CONSTRAINT FK_Reservations_Flights FOREIGN KEY (FlightID) REFERENCES Flights(FlightID),
    -- Foreign key constraint
    -- Constraint to check that reservation date is not in the past
    CONSTRAINT CheckReservationDate CHECK (ReservationDate >= CAST(GETDATE() AS DATE))
);
GO

-- Create Tickets table (depends on Reservations and Employees)
CREATE TABLE Tickets
(
    TicketID INT IDENTITY(1,1) PRIMARY KEY,
    -- Primary key, auto-incrementing
    ReservationID INT NOT NULL,
    -- Foreign key to Reservations table
    IssueDate DATE NOT NULL,
    -- Date when ticket was issued
    IssueTime TIME NOT NULL,
    -- Time when ticket was issued
    Fare DECIMAL(10,2) NOT NULL,
    -- Ticket fare amount
    SeatNumber VARCHAR(10) NOT NULL,
    -- Assigned seat number
    Class VARCHAR(20) NOT NULL CHECK (Class IN ('business', 'firstclass', 'economy')),
    -- Travel class
    EBoardingNumber VARCHAR(20) NOT NULL UNIQUE,
    -- E-boarding number for check-in
    EmployeeID INT NOT NULL,
    -- Foreign key to Employees table
    CONSTRAINT FK_Tickets_Reservations FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID),
    -- Foreign key constraint
    CONSTRAINT FK_Tickets_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
    -- Foreign key constraint
);
GO

-- Create Baggage table (depends on Tickets)
CREATE TABLE Baggage
(
    BaggageID INT IDENTITY(1,1) PRIMARY KEY,
    -- Primary key, auto-incrementing
    TicketID INT NOT NULL,
    -- Foreign key to Tickets table
    Weight DECIMAL(5,2) NOT NULL,
    -- Baggage weight in kg
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('checkedin', 'loaded')),
    -- Baggage status
    BaggageFee DECIMAL(10,2) NOT NULL,
    -- Baggage fee amount
    CONSTRAINT FK_Baggage_Tickets FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID)
    -- Foreign key constraint
);
GO

-- Create Additional Services table (depends on Tickets)
CREATE TABLE AdditionalServices
(
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    -- Primary key, auto-incrementing
    TicketID INT NOT NULL,
    -- Foreign key to Tickets table
    ServiceType VARCHAR(30) NOT NULL CHECK (ServiceType IN ('extra baggage', 'upgraded meal', 'preferred seat')),
    -- Service type
    Fee DECIMAL(10,2) NOT NULL,
    -- Service fee amount
    CONSTRAINT FK_AdditionalServices_Tickets FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID)
    -- Foreign key constraint
);
GO

-- =============================================
-- 3. Sample Data Insertion (in correct dependency order)
-- =============================================
-- Insert at least 7 records per table for testing purposes

-- Insert sample employees (no dependencies)
INSERT INTO Employees
    (Username, Password, Role, Email, Name)
VALUES
    ('jsmith', 'password123', 'Ticketing Supervisor', 'john.smith@airport.com', 'John Smith'),
    ('mjohnson', 'password456', 'Ticketing Staff', 'mary.johnson@airport.com', 'Mary Johnson'),
    ('rwilliams', 'password789', 'Ticketing Staff', 'robert.williams@airport.com', 'Robert Williams'),
    ('ljones', 'password101', 'Ticketing Staff', 'lisa.jones@airport.com', 'Lisa Jones'),
    ('dbrown', 'password202', 'Ticketing Supervisor', 'david.brown@airport.com', 'David Brown'),
    ('slee', 'password303', 'Ticketing Staff', 'sarah.lee@airport.com', 'Sarah Lee'),
    ('jwilson', 'password404', 'Ticketing Staff', 'james.wilson@airport.com', 'James Wilson');
GO

-- Insert sample passengers (no dependencies)
INSERT INTO Passengers
    (PNR, Email, MealPreference, DateOfBirth, FirstName, LastName, EmergencyContact)
VALUES
    ('PNR123456', 'john.doe@email.com', 'non-vegetarian', '1980-05-15', 'John', 'Doe', '07700900001'),
    ('PNR234567', 'jane.smith@email.com', 'vegetarian', '1975-08-22', 'Jane', 'Smith', '07700900002'),
    ('PNR345678', 'michael.johnson@email.com', 'non-vegetarian', '1960-03-10', 'Michael', 'Johnson', '07700900003'),
    ('PNR456789', 'sarah.williams@email.com', 'vegetarian', '1990-11-30', 'Sarah', 'Williams', '07700900004'),
    ('PNR567890', 'david.brown@email.com', 'non-vegetarian', '1985-07-18', 'David', 'Brown', '07700900005'),
    ('PNR678901', 'emma.jones@email.com', 'vegetarian', '1978-12-05', 'Emma', 'Jones', '07700900006'),
    ('PNR789012', 'robert.taylor@email.com', 'non-vegetarian', '1965-09-25', 'Robert', 'Taylor', '07700900007');
GO

-- Insert sample flights (no dependencies)
INSERT INTO Flights
    (FlightNumber, DepartureTime, ArrivalTime, Origin, Destination)
VALUES
    ('BA123', DATEADD(day, 30, GETDATE()), DATEADD(day, 30, GETDATE()) + 2, 'London', 'Paris'),
    ('BA124', DATEADD(day, 31, GETDATE()), DATEADD(day, 31, GETDATE()) + 2, 'Paris', 'London'),
    ('BA125', DATEADD(day, 32, GETDATE()), DATEADD(day, 32, GETDATE()) + 8, 'London', 'New York'),
    ('BA126', DATEADD(day, 33, GETDATE()), DATEADD(day, 33, GETDATE()) + 8, 'New York', 'London'),
    ('BA127', DATEADD(day, 34, GETDATE()), DATEADD(day, 34, GETDATE()) + 12, 'London', 'Tokyo'),
    ('BA128', DATEADD(day, 35, GETDATE()), DATEADD(day, 35, GETDATE()) + 12, 'Tokyo', 'London'),
    ('BA129', DATEADD(day, 36, GETDATE()), DATEADD(day, 36, GETDATE()) + 22, 'London', 'Sydney');
GO

-- Insert sample reservations (depends on Passengers and Flights)
INSERT INTO Reservations
    (PNR, FlightID, Status, ReservationDate, PreferredSeat)
VALUES
    ('PNR123456', 1, 'confirmed', DATEADD(day, 30, GETDATE()), 'A1'),
    ('PNR234567', 1, 'pending', DATEADD(day, 31, GETDATE()), 'B2'),
    ('PNR345678', 2, 'confirmed', DATEADD(day, 32, GETDATE()), 'C3'),
    ('PNR456789', 3, 'pending', DATEADD(day, 33, GETDATE()), 'D4'),
    ('PNR567890', 4, 'confirmed', DATEADD(day, 34, GETDATE()), 'E5'),
    ('PNR678901', 5, 'cancelled', DATEADD(day, 35, GETDATE()), 'F6'),
    ('PNR789012', 6, 'confirmed', DATEADD(day, 36, GETDATE()), 'G7');
GO

-- Insert sample tickets (depends on Reservations and Employees)
INSERT INTO Tickets
    (ReservationID, IssueDate, IssueTime, Fare, SeatNumber, Class, EBoardingNumber, EmployeeID)
VALUES
    (1, GETDATE(), CAST(GETDATE() AS TIME), 150.00, 'A1', 'business', 'EB001', 1),
    (3, GETDATE(), CAST(GETDATE() AS TIME), 200.00, 'C3', 'firstclass', 'EB002', 2),
    (5, GETDATE(), CAST(GETDATE() AS TIME), 100.00, 'E5', 'economy', 'EB003', 3),
    (7, GETDATE(), CAST(GETDATE() AS TIME), 180.00, 'G7', 'business', 'EB004', 4);
GO

-- Insert sample baggage (depends on Tickets)
INSERT INTO Baggage
    (TicketID, Weight, Status, BaggageFee)
VALUES
    (1, 20.5, 'checkedin', 50.00),
    (2, 15.0, 'loaded', 30.00),
    (3, 25.0, 'checkedin', 60.00),
    (4, 18.5, 'loaded', 40.00);
GO

-- Insert sample additional services (depends on Tickets)
INSERT INTO AdditionalServices
    (TicketID, ServiceType, Fee)
VALUES
    (1, 'preferred seat', 30.00),
    (1, 'upgraded meal', 20.00),
    (2, 'extra baggage', 100.00),
    (3, 'preferred seat', 30.00),
    (4, 'upgraded meal', 20.00);
GO

-- =============================================
-- 4. Required Stored Procedures
-- =============================================

-- Drop existing stored procedures if they exist
IF OBJECT_ID('sp_SearchPassengersByLastName', 'P') IS NOT NULL DROP PROCEDURE sp_SearchPassengersByLastName;
IF OBJECT_ID('sp_ListBusinessClassPassengersToday', 'P') IS NOT NULL DROP PROCEDURE sp_ListBusinessClassPassengersToday;
IF OBJECT_ID('sp_InsertNewEmployee', 'P') IS NOT NULL DROP PROCEDURE sp_InsertNewEmployee;
IF OBJECT_ID('sp_UpdatePassengerDetails', 'P') IS NOT NULL DROP PROCEDURE sp_UpdatePassengerDetails;
IF OBJECT_ID('sp_GetPassengerTravelHistory', 'P') IS NOT NULL DROP PROCEDURE sp_GetPassengerTravelHistory;
GO

-- 4a. Search passengers by last name
-- This stored procedure searches for passengers by last name and sorts by most recent issued ticket first
CREATE PROCEDURE sp_SearchPassengersByLastName
    @LastName VARCHAR(50)
AS
BEGIN
    SELECT
        p.PassengerID,
        p.PNR,
        p.FirstName,
        p.LastName,
        p.Email,
        p.MealPreference,
        p.DateOfBirth,
        p.EmergencyContact,
        t.TicketID,
        t.IssueDate,
        t.IssueTime,
        t.EBoardingNumber,
        f.FlightNumber,
        f.DepartureTime,
        f.ArrivalTime,
        f.Origin,
        f.Destination
    FROM
        Passengers p
        LEFT JOIN
        Reservations r ON p.PNR = r.PNR
        LEFT JOIN
        Tickets t ON r.ReservationID = t.ReservationID
        LEFT JOIN
        Flights f ON r.FlightID = f.FlightID
    WHERE 
        p.LastName LIKE '%' + @LastName + '%'
    ORDER BY 
        t.IssueDate DESC, t.IssueTime DESC;
END;
GO

-- 4b. List business class passengers with meal requirements for current day
-- This stored procedure lists all business class passengers with their meal preferences for flights departing today
CREATE PROCEDURE sp_ListBusinessClassPassengersToday
AS
BEGIN
    SELECT
        p.PassengerID,
        p.PNR,
        p.FirstName,
        p.LastName,
        p.Email,
        p.MealPreference,
        t.TicketID,
        t.EBoardingNumber,
        f.FlightNumber,
        f.DepartureTime,
        f.ArrivalTime,
        f.Origin,
        f.Destination
    FROM
        Passengers p
        JOIN
        Reservations r ON p.PNR = r.PNR
        JOIN
        Tickets t ON r.ReservationID = t.ReservationID
        JOIN
        Flights f ON r.FlightID = f.FlightID
    WHERE 
        t.Class = 'business'
        AND CAST(f.DepartureTime AS DATE) = CAST(GETDATE() AS DATE);
END;
GO

-- 4c. Insert a new employee
-- This stored procedure inserts a new employee with validation for duplicate username and email
CREATE PROCEDURE sp_InsertNewEmployee
    @Username VARCHAR(50),
    @Password VARCHAR(100),
    @Role VARCHAR(20),
    @Email VARCHAR(100),
    @Name VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if username already exists
        IF EXISTS (SELECT 1
    FROM Employees
    WHERE Username = @Username)
        BEGIN
        RAISERROR ('Username already exists.', 16, 1);
        RETURN;
    END
        
        -- Check if email already exists
        IF EXISTS (SELECT 1
    FROM Employees
    WHERE Email = @Email)
        BEGIN
        RAISERROR ('Email already exists.', 16, 1);
        RETURN;
    END
        
        -- Insert the new employee
        INSERT INTO Employees
        (Username, Password, Role, Email, Name)
    VALUES
        (@Username, @Password, @Role, @Email, @Name);
        
        -- Get the ID of the newly inserted employee
        DECLARE @NewEmployeeID INT = SCOPE_IDENTITY();
        
        -- Return the new employee ID
        SELECT @NewEmployeeID AS NewEmployeeID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- 4d. Update details for a passenger who has booked a flight before
-- This stored procedure updates passenger details for a passenger who has booked a flight before
CREATE PROCEDURE sp_UpdatePassengerDetails
    @PNR VARCHAR(10),
    @Email VARCHAR(100) = NULL,
    @MealPreference VARCHAR(20) = NULL,
    @EmergencyContact VARCHAR(20) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if passenger exists
        IF NOT EXISTS (SELECT 1
    FROM Passengers
    WHERE PNR = @PNR)
        BEGIN
        RAISERROR ('Passenger with PNR %s does not exist.', 16, 1, @PNR);
        RETURN;
    END
        
        -- Update passenger details
        UPDATE Passengers
        SET 
            Email = ISNULL(@Email, Email),
            MealPreference = ISNULL(@MealPreference, MealPreference),
            EmergencyContact = ISNULL(@EmergencyContact, EmergencyContact)
        WHERE 
            PNR = @PNR;
        
        -- Return updated passenger details
        SELECT
        PassengerID,
        PNR,
        Email,
        MealPreference,
        DateOfBirth,
        FirstName,
        LastName,
        EmergencyContact
    FROM
        Passengers
    WHERE 
            PNR = @PNR;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- =============================================
-- 5. Required Views
-- =============================================

-- Drop existing views if they exist
IF OBJECT_ID('vw_EmployeeRevenue', 'V') IS NOT NULL DROP VIEW vw_EmployeeRevenue;
IF OBJECT_ID('vw_FlightOccupancy', 'V') IS NOT NULL DROP VIEW vw_FlightOccupancy;
GO

-- 5. Employee Revenue View
-- This view shows e-boarding numbers issued by specific employee and includes overall revenue
CREATE VIEW vw_EmployeeRevenue
AS
    SELECT
        e.EmployeeID,
        e.Name AS EmployeeName,
        f.FlightID,
        f.FlightNumber,
        f.DepartureTime,
        f.Origin,
        f.Destination,
        COUNT(t.TicketID) AS TicketsIssued,
        SUM(t.Fare) AS TotalFare,
        SUM(ISNULL(b.BaggageFee, 0)) AS TotalBaggageFees,
        SUM(ISNULL(CASE WHEN a.ServiceType = 'upgraded meal' THEN a.Fee ELSE 0 END, 0)) AS TotalMealFees,
        SUM(ISNULL(CASE WHEN a.ServiceType = 'preferred seat' THEN a.Fee ELSE 0 END, 0)) AS TotalSeatFees,
        SUM(t.Fare) + SUM(ISNULL(b.BaggageFee, 0)) + 
    SUM(ISNULL(CASE WHEN a.ServiceType = 'upgraded meal' THEN a.Fee ELSE 0 END, 0)) + 
    SUM(ISNULL(CASE WHEN a.ServiceType = 'preferred seat' THEN a.Fee ELSE 0 END, 0)) AS TotalRevenue
    FROM
        Employees e
        JOIN
        Tickets t ON e.EmployeeID = t.EmployeeID
        JOIN
        Reservations r ON t.ReservationID = r.ReservationID
        JOIN
        Flights f ON r.FlightID = f.FlightID
        LEFT JOIN
        Baggage b ON t.TicketID = b.TicketID
        LEFT JOIN
        AdditionalServices a ON t.TicketID = a.TicketID
    GROUP BY 
    e.EmployeeID, e.Name, f.FlightID, f.FlightNumber, f.DepartureTime, f.Origin, f.Destination;
GO

-- =============================================
-- 6. Required Functions
-- =============================================

-- Drop existing functions if they exist
IF OBJECT_ID('fn_CalculateCheckedInBaggage', 'FN') IS NOT NULL DROP FUNCTION fn_CalculateCheckedInBaggage;
GO

-- 6. Calculate total checked-in baggage for specific flight and date
-- This function calculates the total checked-in baggage for a specific flight and date
CREATE FUNCTION fn_CalculateCheckedInBaggage
(
    @FlightID INT,
    @Date DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
    f.FlightID,
    f.FlightNumber,
    f.DepartureTime,
    f.Origin,
    f.Destination,
    COUNT(b.BaggageID) AS TotalBaggageCount,
    SUM(b.Weight) AS TotalBaggageWeight,
    SUM(b.BaggageFee) AS TotalBaggageFees
FROM
    Flights f
    JOIN
    Reservations r ON f.FlightID = r.FlightID
    JOIN
    Tickets t ON r.ReservationID = t.ReservationID
    JOIN
    Baggage b ON t.TicketID = b.TicketID
WHERE 
        f.FlightID = @FlightID
    AND CAST(f.DepartureTime AS DATE) = @Date
    AND b.Status = 'checkedin'
GROUP BY 
        f.FlightID, f.FlightNumber, f.DepartureTime, f.Origin, f.Destination
);
GO

-- =============================================
-- 7. Required Triggers
-- =============================================

-- Drop existing triggers if they exist
IF OBJECT_ID('trg_UpdateSeatStatus', 'TR') IS NOT NULL DROP TRIGGER trg_UpdateSeatStatus;
GO

-- 7. Automatic seat status update when ticket is issued
-- This trigger automatically updates the seat status in the Reservations table when a ticket is issued
CREATE TRIGGER trg_UpdateSeatStatus
ON Tickets
AFTER INSERT
AS
BEGIN
    -- Update the seat status in the Reservations table
    UPDATE r
    SET r.PreferredSeat = i.SeatNumber
    FROM Reservations r
        JOIN inserted i ON r.ReservationID = i.ReservationID;
END;
GO

-- =============================================
-- 8. Additional Database Objects
-- =============================================

-- 8a. View for Flight Occupancy
-- This view provides information about flight occupancy and revenue
CREATE VIEW vw_FlightOccupancy
AS
    SELECT
        f.FlightID,
        f.FlightNumber,
        f.DepartureTime,
        f.ArrivalTime,
        f.Origin,
        f.Destination,
        COUNT(t.TicketID) AS TotalPassengers,
        SUM(CASE WHEN t.Class = 'business' THEN 1 ELSE 0 END) AS BusinessClassPassengers,
        SUM(CASE WHEN t.Class = 'firstclass' THEN 1 ELSE 0 END) AS FirstClassPassengers,
        SUM(CASE WHEN t.Class = 'economy' THEN 1 ELSE 0 END) AS EconomyPassengers,
        SUM(t.Fare) AS TotalRevenue
    FROM
        Flights f
        LEFT JOIN
        Reservations r ON f.FlightID = r.FlightID
        LEFT JOIN
        Tickets t ON r.ReservationID = t.ReservationID
    GROUP BY 
    f.FlightID, f.FlightNumber, f.DepartureTime, f.ArrivalTime, f.Origin, f.Destination;
GO

-- 8b. Stored Procedure for Passenger Travel History
-- This stored procedure retrieves the complete travel history for a passenger
CREATE PROCEDURE sp_GetPassengerTravelHistory
    @PNR VARCHAR(10)
AS
BEGIN
    SELECT
        p.PassengerID,
        p.PNR,
        p.FirstName,
        p.LastName,
        t.TicketID,
        t.IssueDate,
        t.EBoardingNumber,
        t.Class,
        f.FlightNumber,
        f.DepartureTime,
        f.ArrivalTime,
        f.Origin,
        f.Destination,
        r.Status AS ReservationStatus,
        b.Weight AS BaggageWeight,
        b.Status AS BaggageStatus,
        b.BaggageFee,
        a.ServiceType,
        a.Fee AS ServiceFee
    FROM
        Passengers p
        JOIN
        Reservations r ON p.PNR = r.PNR
        JOIN
        Tickets t ON r.ReservationID = t.ReservationID
        JOIN
        Flights f ON r.FlightID = f.FlightID
        LEFT JOIN
        Baggage b ON t.TicketID = b.TicketID
        LEFT JOIN
        AdditionalServices a ON t.TicketID = a.TicketID
    WHERE 
        p.PNR = @PNR
    ORDER BY 
        f.DepartureTime DESC;
END;
GO

-- =============================================
-- 9. Required Queries
-- =============================================

-- 9. Identify Passengers with Pending Reservations and age > 40 years
-- This query identifies passengers with pending reservations who are over 40 years old
SELECT
    p.PassengerID,
    p.PNR,
    p.FirstName,
    p.LastName,
    p.DateOfBirth,
    DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) AS Age,
    r.ReservationID,
    r.Status AS ReservationStatus,
    r.ReservationDate,
    f.FlightNumber,
    f.DepartureTime,
    f.Origin,
    f.Destination
FROM
    Passengers p
    JOIN
    Reservations r ON p.PNR = r.PNR
    JOIN
    Flights f ON r.FlightID = f.FlightID
WHERE 
    r.Status = 'pending'
    AND DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) > 40
ORDER BY 
    r.ReservationDate;
GO

-- =============================================
-- 10. Test Queries
-- =============================================

-- Test the stored procedures
EXEC sp_SearchPassengersByLastName @LastName = 'Smith';
GO

EXEC sp_ListBusinessClassPassengersToday;
GO

EXEC sp_InsertNewEmployee 
    @Username = 'newuser',
    @Password = 'password123',
    @Role = 'Ticketing Staff',
    @Email = 'new.user@airport.com',
    @Name = 'New User';
GO

EXEC sp_UpdatePassengerDetails 
    @PNR = 'PNR123456',
    @Email = 'updated.email@email.com',
    @MealPreference = 'vegetarian',
    @EmergencyContact = '07700900099';
GO

-- Test the view
SELECT *
FROM vw_EmployeeRevenue;
GO

-- Test the function
SELECT *
FROM fn_CalculateCheckedInBaggage(1, CAST(DATEADD(day, 30, GETDATE()) AS DATE));
GO

-- Test the additional database objects
SELECT *
FROM vw_FlightOccupancy;
GO

EXEC sp_GetPassengerTravelHistory @PNR = 'PNR123456';
GO