# Airport E-Boarding System Database Implementation

## Project Overview
This project implements a comprehensive database system for an airport e-boarding system. The database is designed to manage passenger information, flight details, reservations, tickets, baggage, and additional services. The implementation follows database design best practices and includes all required components such as views, stored procedures, functions, triggers, and complex queries.

## Student Information
- **Student ID**: 00794412
- **Course**: Advanced Databases
- **Assessment**: Task 1

## Database Structure
The database is designed to 3NF (Third Normal Form) with the following normalization approach:
1. **First Normal Form (1NF)**: All tables have a primary key and no repeating groups
2. **Second Normal Form (2NF)**: All non-key attributes are fully dependent on the primary key
3. **Third Normal Form (3NF)**: No transitive dependencies exist

### Tables
1. **Employees**: Stores employee information (ID, username, password, role, email, name)
2. **Passengers**: Stores passenger details (ID, PNR, email, meal preference, DOB, name, emergency contact)
3. **Flights**: Contains flight information (ID, flight number, departure/arrival times, origin, destination)
4. **Reservations**: Links passengers to flights (ID, PNR, flight ID, status, date, preferred seat)
5. **Tickets**: Stores ticket information (ID, reservation ID, issue date/time, fare, seat, class, e-boarding number)
6. **Baggage**: Contains baggage details (ID, ticket ID, weight, status, fee)
7. **AdditionalServices**: Stores additional services purchased (ID, ticket ID, service type, fee)

### Database Objects
1. **Views**:
   - `vw_EmployeeRevenue`: Shows e-boarding numbers issued by specific employees and includes overall revenue
   - `vw_FlightOccupancy`: Provides information about flight occupancy and revenue

2. **Stored Procedures**:
   - `sp_SearchPassengersByLastName`: Searches for passengers by last name
   - `sp_ListBusinessClassPassengersToday`: Lists business class passengers with meal preferences for today
   - `sp_InsertNewEmployee`: Inserts a new employee with validation
   - `sp_UpdatePassengerDetails`: Updates passenger details
   - `sp_GetPassengerTravelHistory`: Retrieves complete travel history for a passenger

3. **Functions**:
   - `fn_CalculateCheckedInBaggage`: Calculates total checked-in baggage for a specific flight and date

4. **Triggers**:
   - `trg_UpdateSeatStatus`: Automatically updates seat status when a ticket is issued

## Files Included
1. **00794412_task1.sql**: Complete SQL implementation of the airport e-boarding system
2. **airport_eboarding_documentation.md**: Comprehensive documentation of the implementation

## How to Use
1. Open SQL Server Management Studio (SSMS)
2. Open the file `00794412_task1.sql`
3. Execute the script to create the database and all objects
4. Run the test queries at the end of the script to verify functionality

## Features
- **Passenger Management**: Search, update, and track passenger information
- **Flight Management**: Track flight details and occupancy
- **Reservation System**: Manage flight reservations with status tracking
- **Ticket Issuance**: Issue tickets with e-boarding numbers
- **Baggage Management**: Track baggage status and fees
- **Additional Services**: Manage extra services like preferred seats and upgraded meals
- **Employee Management**: Add and manage employee accounts

## Data Integrity and Security
- **Constraints**: Primary keys, foreign keys, and check constraints ensure data integrity
- **Transactions**: Used in stored procedures to ensure data consistency
- **Error Handling**: Comprehensive error handling in stored procedures
- **Validation**: Input validation for critical operations

## Report
The project includes a detailed report (no more than 4,000 words) that covers:
1. Database design and normalization
2. Implementation details and explanations
3. Screenshots of code and execution results
4. Data integrity, concurrency, security, and backup/recovery considerations

## Requirements Met
- Views
- Stored procedures
- System functions and user-defined functions
- Triggers
- SELECT queries with joins and sub-queries
- All functions and stored procedures are defined, called, and results shown

## Setup Instructions

### 1. Start SQL Server Container
```bash
# Navigate to the project directory
cd /path/to/project

# Start the SQL Server container
docker-compose up -d
```

### 2. Connect with Azure Data Studio
1. Open Azure Data Studio
2. Click "New Connection"
3. Enter these details:
   - Connection Type: Microsoft SQL Server
   - Server: localhost,1433
   - Authentication Type: SQL Login
   - User name: sa
   - Password: YourStrong!Passw0rd
   - Database: <leave blank for now>


## Project Documentation

### Additional Files
- `Advanced Databases Assignment Brief and Marking Criteria.pdf`: Assignment documentation and grading criteria
- `Writing Frame.pdf`: Template for project documentation

## Troubleshooting

### Common Issues

1. **Cannot Connect to SQL Server**
   - Ensure Docker Desktop is running
   - Check if container is running: `docker ps`
   - Verify port 1433 is not in use

2. **Data Import Fails**
   - Check if CSV files are in the correct location
   - Verify file permissions
   - Ensure CSV files match the expected format

3. **Database Already Exists**
   - Run `00_drop_db.sql` first
   - Check for active connections
   - Restart SQL Server container if needed

### Reset Database
To completely reset the database:
```bash
# Stop and remove containers
docker-compose down

# Remove volumes
docker volume rm $(docker volume ls -q)

# Start fresh
docker-compose up -d
```
## Notes
- All scripts use GO statements to separate batches
- CSV files must be in the correct location as specified in docker-compose.yml
- Make sure to run scripts in the correct order
- Backup your data before running drop scripts 