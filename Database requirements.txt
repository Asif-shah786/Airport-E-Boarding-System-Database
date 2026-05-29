# Airport E-Boarding System Database Requirements

## Database Design Requirements
1. Design and normalize database to 3NF
   - Document and justify design decisions
   - Include database diagram
   - Explain normalization process
   - Document any additional assumptions made

2. Create tables using T-SQL statements
   - Clearly identify primary and foreign keys
   - Justify data types chosen for each column
   - Implement appropriate constraints for data integrity
   - Include at least 7 records per table for testing

## Required Tables
1. Employees
   - EmployeeID (PK)
   - Username
   - Password
   - Role (Ticketing Staff/Ticketing Supervisor)
   - Email
   - Name

2. Passengers
   - PassengerID (PK)
   - PNR
   - Email
   - Meal Preference (vegetarian/non-vegetarian)
   - Date of Birth
   - First Name
   - Last Name
   - Emergency Contact (optional)

3. Flights
   - FlightID (PK)
   - Flight Number
   - Departure Time
   - Arrival Time
   - Origin
   - Destination

4. Reservations
   - ReservationID (PK)
   - PNR
   - FlightID (FK)
   - Status (confirmed/pending/cancelled)
   - Reservation Date
   - Preferred Seat (nullable)

5. Tickets
   - TicketID (PK)
   - ReservationID (FK)
   - Issue Date
   - Issue Time
   - Fare
   - Seat Number
   - Class (business/firstclass/economy)
   - E-Boarding Number
   - EmployeeID (FK)

6. Baggage
   - BaggageID (PK)
   - TicketID (FK)
   - Weight
   - Status (checkedin/loaded)
   - Baggage Fee

7. Additional Services
   - ServiceID (PK)
   - TicketID (FK)
   - Service Type (extra baggage/upgraded meal/preferred seat)
   - Fee

## Required Constraints
1. Reservation date must not be in the past

## Required Queries
1. Identify Passengers with Pending Reservations and age > 40 years

## Required Database Objects

### Stored Procedures
1. Search passengers by last name
   - Sort by most recent issued ticket first

2. List business class passengers with meal requirements for current day

3. Insert a new employee

4. Update details for a passenger who has booked a flight before

### Views
1. Employee Revenue View
   - Show e-boarding numbers issued by specific employee
   - Include overall revenue (fare + additional services)
   - Include details of fare, baggage fees, upgraded meal, preferred seat

### Functions
1. Calculate total checked-in baggage for specific flight and date

### Triggers
1. Automatic seat status update when ticket is issued

## Additional Requirements
- Provide at least 2 additional useful database objects (views, stored procedures, functions, or triggers)
- Document operational guidance for:
  - Data integrity and concurrency
  - Database security
  - Database backup and recovery

## Required SQL Elements
- Views
- Stored procedures
- System functions and user-defined functions
- Triggers
- SELECT queries with joins and sub-queries

## Implementation Notes
- Primary SQL script: `code.sql`
- Organize sections with clear comments
- Include function and stored procedure calls with results in test sections