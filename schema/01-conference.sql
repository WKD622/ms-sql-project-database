/*
 * Moduł schematu bazy danych odpowiedzialny za przechowywanie
 * informacji o konferencjach.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Tabela przechowująca dane o konferencjach. Każdy wiersz to
 * osobna konferencja.
 * 
 * @column ConferenceID
 *             ID konferencji
 * @column Name
 *             nazwa konferencji
 * @column Price
 *             cena za dzień konferencji
 * @column StartDay
 *             dzień rozpoczęcia konferencji
 * @column EndDay
 *             dzień zakończenia konferencji
 * @column ParticipantLimit
 *             limit ilości osób na jeden dzień konferencji
 * @column StudentDiscout
 *             wartość zniżki studenckiej
 */
create table Conferences (
	ConferenceID     int identity  not null,
	Name             varchar(255)  not null
		check (Name <> ''),
	Price            money         not null
		check (Price >= 0),
	StartDay         date          not null,
	EndDay           date          not null,
	ParticipantLimit int           null
		check (ParticipantLimit is null or ParticipantLimit > 0),
	StudentDiscout   decimal(3, 2) not null
		check (StudentDiscount >= 0 and StudentDiscount <= 1)
		default 0,
	primary key (ConferenceID),
	constraint StartEnd
		check (EndDay > StartDay)
);

/**
 * Tabela przechowująca dane o dniach konferencji. Każdy dzień
 * konferencji odnosi się do danej konferencji, jest unikalny oraz
 * zawiera się w przedziale między {@link StartDay} a {@link EndDay}.
 * 
 * @column ConferenceDayID
 *             ID dnia konferencji
 * @column ConferenceID
 *             ID konferencji, do której się odnosi ten dzień
 * @column Day
 *             dany dzień konferencji
 */
create table ConferenceDays (
	ConferenceDayID int identity not null,
	ConferenceID    int          not null,
	Day             date         not null,
	primary key (ConferenceDayID)
);

/**
 * Tabela przechowująca dane o warsztatach.
 * 
 * @column ConferenceDayID
 *             ID dnia konferencji
 * @column ConferenceID
 *             ID konferencji, do której się odnosi ten dzień
 * @column Day
 *             dany dzień konferencji
 */
create table Workshops (
	WorkshopID  int identity not null,
	Name        varchar(255) not null
		check (Name <> ''),
	Description varchar(255) null
		check (Description is null or Description <> ''),
	primary key (WorkshopID)
);

create table WorkshopTerms (
	WorkshopTermID int identity not null,
	WorkshopID     int          not null,
	DayID          int          not null,
	Price          money        not null
		check (Price >= 0),
	StartTime      time         not null,
	EndTime        time         not null,
	Capacity       int          null
		check (Capacity is null or Capacity > 0),
	primary key (WorkshopTermID),
	constraint CK_WorkshopTerms_StartEnd
		check (EndTime > StartTime)
);

create table Prices (
	PriceID      int identity  not null,
	ConferenceID int           not null,
	DueDate      date          not null,
	Discount     decimal(3, 2) not null
		check (Discount >= 0 and Discount <= 1),
	primary key (PriceID)
);
