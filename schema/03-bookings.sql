/*
 * Moduł schematu bazy danych odpowiedzialny za przechowywanie
 * informacji o zamówieniach.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

create table BookingStudentIDs (
	DayBookingID int     not null,
	StudentID    char(6) not null unique
		check (StudentID not like '%[^0-9]%'),
	primary key (DayBookingID)
);

create table Bookings (
	BookingID   int identity not null,
	CustomerID  int          not null,
	BookingDate date         not null
		default getdate(),
	DueDate     date         not null
		default dateadd(week, 1, getdate()),
	PaymentDate date         null,
	Paid        bit          not null
		default 0,
	primary key (BookingID)
	constraint BookingDateDueDate
		check (BookingDate < DueDate)
	constraint BookingDatePaymentDate
		check ((PaymentDate is null) or (BookingDate <= PaymentDate))
);

create table WorkshopBookings (
	WorkshopBookingID int identity not null,
	WorkshopTermID    int          not null,
	DayBookingID      int          not null,
	Participants      int          not null
		check (Participants > 0)
		default 1,
	primary key (WorkshopBookingID)
);

create table DayBookingDetails (
	DayBookingID  int not null,
	ParticipantID int not null,
	primary key (DayBookingID, ParticipantID)
);

create table DayBookings (
	DayBookingID    int identity not null
		check (Participants > 0),
	BookingID       int          not null,
	ConferenceDayID int          not null,
	Participants    int          not null
		check (Participants > 0)
		default 1,
	primary key (DayBookingID)
);

create table WorkshopBookingDetails (
	WorkshopBookingID int not null,
	ParticipantID     int not null,
	primary key (WorkshopBookingID, ParticipantID)
);
