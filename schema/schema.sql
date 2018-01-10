/*
 * Schemat bazy danych.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Tabela przechowująca dane klientów.
 * 
 * @column CustomerID
 *             ID klienta
 * @column Address
 *             adres klienta w formie czytelnej dla człowieka
 * @column Phone
 *             numer telefonu klienta w postaci czytelnej dla człowieka
 * @column Email
 *             adres email klienta
 * @column Login
 *             login klienta
 * @column Password
 *             hasło do konta w postaci hashowanej
 */
create table Customers (
	CustomerID int identity   not null,
	Address    varchar(255)   not null,
	Phone      varchar(32)    not null,
	Email      varchar(255)   not null,
	Login      varchar(64)    not null,
	Password   varbinary(256) not null,
	primary key (CustomerID)
);

/**
 * Tabela przechowująca dane klientów -- firm.
 * 
 * @column CustomerID
 *             ID klienta, identyczne z {@link Customers.CustomerID}
 * @column NIP
 *             numer identyfikacji podatkowej firmy
 * @column CompanyName
 *             nazwa firmy
 */
create table Companies (
	CustomerID  int          not null,
	NIP         char(10)     not null unique,
	CompanyName varchar(255) not null,
	primary key (CustomerID)
);

/**
 * Tabela przechowująca dane klientów -- osób fizycznych.
 * 
 * @column CustomerID
 *             ID klienta, identyczne z {@link Customers.CustomerID}
 * @column ParticipantID
 *             ID uczestnika
 */
create table Persons (
	CustomerID    int not null unique,
	ParticipantID int not null unique,
	primary key (ParticipantID, CustomerID)
);

/**
 * Tabela przechowująca dane uczestników (delegatów) z danej firmy.
 * 
 * @column CustomerID
 *             ID firmy
 * @column ParticipantID
 *             ID uczestnika
 */
create table CompanyParticipants (
	CompanyID     int not null,
	ParticipantID int not null,
	primary key (ParticipantID)
);

create table Conferences (
	ConferenceID     int identity  not null,
	Name             varchar(255)  not null,
	Price            money         not null,
	StartDay         date          not null,
	EndDay           date          not null,
	ParticipantLimit int           null,
	StudentDiscout   decimal(3, 2) not null,
	primary key (ConferenceID),
	constraint StartEnd
		check (EndDay > StartDay)
);

create table ConferenceDays (
	ConferenceDayID int identity not null,
	ConferenceID    int          not null,
	Day             date         not null,
	primary key (ConferenceDayID)
);

create table Workshops (
	WorkshopID  int identity not null,
	Name        varchar(255) not null,
	Description varchar(255) null,
	primary key (WorkshopID)
);

create table WorkshopTerms (
	WorkshopTermID int identity not null,
	WorkshopID     int          not null,
	DayID          int          not null,
	Price          money        not null,
	StartTime      time         not null,
	EndTime        time         not null,
	Capacity       int          null,
	primary key (WorkshopTermID),
	constraint CK_WorkshopTerms_StartEnd
		check (EndTime > StartTime)
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

create table Participants (
	ParticipantID int identity not null,
	FirstName     varchar(255) not null,
	LastName      varchar(255) not null,
	primary key (ParticipantID)
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

create table Prices (
	PriceID      int identity  not null,
	ConferenceID int           not null,
	DueDate      date          not null,
	Discount     decimal(3, 2) not null,
	primary key (PriceID)
);

create table StudentIDs (
	ParticipantID int     not null,
	StudentID     char(6) not null unique,
	primary key (ParticipantID)
);

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

alter table Persons
	add constraint FKPersons336560
	foreign key (CustomerID)
	references Customers (CustomerID);

alter table Companies
	add constraint FKCompanies259074
	foreign key (CustomerID)
	references Customers (CustomerID);

alter table CompanyParticipants
	add constraint FKCompanyPar396925
	foreign key (CompanyID)
	references Companies (CustomerID);

alter table ConferenceDays
	add constraint FKConference689988
	foreign key (ConferenceID)
	references Conferences (ConferenceID);

alter table WorkshopTerms
	add constraint FKWorkshopTe655363
	foreign key (WorkshopID)
	references Workshops (WorkshopID);

alter table WorkshopTerms
	add constraint FKWorkshopTe428820
	foreign key (DayID)
	references ConferenceDays (ConferenceDayID);

alter table Persons
	add constraint FKPersons422904
	foreign key (ParticipantID)
	references Participants (ParticipantID);

alter table CompanyParticipants
	add constraint FKCompanyPar628077
	foreign key (ParticipantID)
	references Participants (ParticipantID);

alter table WorkshopBookingDetails
	add constraint FKWorkshopBo225545
	foreign key (ParticipantID)
	references Participants (ParticipantID);

alter table WorkshopBookingDetails
	add constraint FKWorkshopBo133697
	foreign key (WorkshopBookingID)
	references WorkshopBookings (WorkshopBookingID);

alter table WorkshopBookings
	add constraint FKWorkshopBo238930
	foreign key (WorkshopTermID)
	references WorkshopTerms (WorkshopTermID);

alter table DayBookingDetails
	add constraint FKDayBooking258140
	foreign key (DayBookingID)
	references DayBookings (DayBookingID);

alter table DayBookingDetails
	add constraint FKDayBooking637424
	foreign key (ParticipantID)
	references Participants (ParticipantID);

alter table Prices
	add constraint FKPrices192071
	foreign key (ConferenceID)
	references Conferences (ConferenceID);

alter table WorkshopBookings
	add constraint FKWorkshopBo201789
	foreign key (DayBookingID)
	references DayBookings (DayBookingID);

alter table StudentIDs
	add constraint FKStudentIDs613554
	foreign key (ParticipantID)
	references Participants (ParticipantID);

alter table DayBookings
	add constraint FKDayBooking362799
	foreign key (BookingID)
	references Bookings (BookingID);

alter table BookingStudentIDs
	add constraint FKBookingStu301
	foreign key (DayBookingID)
	references DayBookings (DayBookingID);

alter table Bookings
	add constraint FKBookings930718
	foreign key (CustomerID)
	references Customers (CustomerID);

alter table DayBookings
	add constraint FKDayBooking44781
	foreign key (ConferenceDayID)
	references ConferenceDays (ConferenceDayID);
