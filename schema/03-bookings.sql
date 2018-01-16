/*
 * Moduł schematu bazy danych odpowiedzialny za przechowywanie
 * informacji o zamówieniach.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

create table BookingStudentIDs (
	DayBookingID int     not null,
	StudentID    char(6) not null,
	primary key (DayBookingID),
	constraint BookingStudentIDsUnique
		unique (DayBookingID, StudentID),
	constraint InvalidBookingStudentID
		check (StudentID not like '%[^0-9]%')
);

/**
 * Tabela przechowująca rezerwacje.
 * 
 * @column BookingID
 *     ID rezerwacji
 * @column CustomerID
 *     ID klienta, który rezerwuje
 * @column BookingDate
 *     data rezerwacji
 * @column DueDate
 *     termin płatności
 * @column PaymentDate
 *     data zapłaty
 */
create table Bookings (
	BookingID   int identity not null,
	CustomerID  int          not null,
	BookingDate date         not null default getdate(),
	DueDate     date         not null default dateadd(week, 1, getdate()),
	PaymentDate date         null     default null,
	primary key (BookingID),
	constraint BookingDateDueDate
		check (BookingDate < DueDate),
	constraint BookingDatePaymentDate
		check ((PaymentDate is null) or (BookingDate <= PaymentDate)),
	constraint ReasonableBookingDate
		check (BookingDate <= getDate()),
	constraint ReasonablePaymentDate
		check (PaymentDate <= getDate())
);

/**
 * Tabela przechowująca rezerwacje warsztatów.
 * 
 * @column WorkshopBookingID
 *     ID rezerwacji warsztatu
 * @column WorkshopTermID
 *     ID terminu rezerwowanego warsztatu
 * @column DayBookingID
 *     ID rezerwacji dnia
 * @column Participants
 *     ilość osób, których dotyczy rezerwacja
 */
create table WorkshopBookings (
	WorkshopBookingID int identity not null,
	WorkshopTermID    int          not null,
	DayBookingID      int          not null,
	Participants      int          not null default 1,
	primary key (WorkshopBookingID),
	constraint PositiveWorkshopParticipantsNo
		check (Participants > 0)
);

create table DayBookingDetails (
	DayBookingID  int not null,
	ParticipantID int not null,
	primary key (DayBookingID, ParticipantID)
);

/**
 * Tabela przechowująca rezerwacje dni.
 * 
 * @column DayBookingID
 *     ID rezerwacji dnia
 * @column BookingID
 *     ID rezerwacji
 * @column ConferenceDayID
 *     ID dnia konferencji
 * @column Participants
 *     ilość osób, których dotyczy rezerwacja
 */
create table DayBookings (
	DayBookingID    int identity not null,
	BookingID       int          not null,
	ConferenceDayID int          not null,
	Participants    int          not null default 1,
	primary key (DayBookingID),
	constraint PositiveDayParticipantsNo
		check (Participants > 0)
);

create table WorkshopBookingDetails (
	WorkshopBookingID int not null,
	ParticipantID     int not null,
	primary key (WorkshopBookingID, ParticipantID)
);
