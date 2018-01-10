
create table BookingStudentIDs (
	DayBookingID int     not null,
	StudentID    char(6) not null unique,
	primary key (DayBookingID)
);

create table Bookings (
	BookingID   int identity not null,
	CustomerID  int          not null,
	BookingDate date         not null,
	DueDate     date         not null,
	PaymentDate date         null,
	Paid        bit          not null,
	primary key (BookingID)
);

create table WorkshopBookings (
	WorkshopBookingID int identity not null,
	WorkshopTermID    int          not null,
	DayBookingID      int          not null,
	Participants      int          not null,
	primary key (WorkshopBookingID)
);

create table DayBookingDetails (
	DayBookingID  int not null,
	ParticipantID int not null,
	primary key (DayBookingID, ParticipantID)
);

create table DayBookings (
	DayBookingID    int identity not null,
	BookingID       int          not null,
	ConferenceDayID int          not null,
	Participants    int          not null,
	primary key (DayBookingID)
);

create table WorkshopBookingDetails (
	WorkshopBookingID int not null,
	ParticipantID     int not null,
	primary key (WorkshopBookingID, ParticipantID)
);
