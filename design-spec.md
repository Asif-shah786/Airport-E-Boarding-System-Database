# Airport E-Boarding — Design Specification

Reference for the domain model and database objects implemented in [airport_eboarding.sql](airport_eboarding.sql).

## Design goals

- Normalize to **3NF** with documented assumptions
- Enforce integrity with keys, checks, and transactional procedures
- Support reporting (revenue, occupancy) and day-of-operations queries (meals, baggage)
- Ship with seed data and runnable tests for local evaluation

## Tables

### Employees
- `EmployeeID` (PK), `Username`, `Password`, `Role` (Ticketing Staff / Ticketing Supervisor), `Email`, `Name`

### Passengers
- `PassengerID` (PK), `PNR`, `Email`, `MealPreference` (vegetarian / non-vegetarian), `DateOfBirth`, `FirstName`, `LastName`, `EmergencyContact` (optional)

### Flights
- `FlightID` (PK), `FlightNumber`, `DepartureTime`, `ArrivalTime`, `Origin`, `Destination`

### Reservations
- `ReservationID` (PK), `PNR`, `FlightID` (FK), `Status` (confirmed / pending / cancelled), `ReservationDate`, `PreferredSeat` (nullable)

### Tickets
- `TicketID` (PK), `ReservationID` (FK), `IssueDate`, `IssueTime`, `Fare`, `SeatNumber`, `Class` (business / firstclass / economy), `EBoardingNumber`, `EmployeeID` (FK)

### Baggage
- `BaggageID` (PK), `TicketID` (FK), `Weight`, `Status` (checkedin / loaded), `BaggageFee`

### Additional Services
- `ServiceID` (PK), `TicketID` (FK), `ServiceType` (extra baggage / upgraded meal / preferred seat), `Fee`

## Business rules

- Reservation date must not be in the past
- Sample data: at least seven rows per table in `airport_eboarding.sql`

## Queries

- Passengers with **pending** reservations and age **> 40** (join across `Passengers`, `Reservations`, `Flights`)

## Database objects

### Stored procedures
| Procedure | Behavior |
|-----------|----------|
| Search by last name | Sort by most recently issued ticket |
| Business class today | Meal requirements for current day |
| Insert employee | Validated insert |
| Update passenger | Only if passenger has booked before |
| Travel history | Full history by PNR |

### Views
| View | Behavior |
|------|----------|
| Employee revenue | E-boarding numbers per employee; fare + services + baggage/meal/seat breakdown |
| Flight occupancy | Occupancy and revenue per flight |

### Functions
- Total **checked-in** baggage for a given flight and date

### Triggers
- Update seat status when a ticket is issued

### Additional objects
- Extra view, procedure, or function beyond the core set (see script comments)

## SQL surface area

- Views, stored procedures, system and user-defined functions, triggers
- `SELECT` with joins and subqueries; procedure/function calls with sample output in the test section

## Operations (documented in depth)

See [airport_eboarding_documentation.md](airport_eboarding_documentation.md) for:

- Data integrity and concurrency
- Database security
- Backup and recovery

## Implementation

- **Script:** [airport_eboarding.sql](airport_eboarding.sql)
- **Diagram:** [database-diagram.png](database-diagram.png)
