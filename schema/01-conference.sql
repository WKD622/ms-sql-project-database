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
 *     ID konferencji
 * @column Name
 *     nazwa konferencji
 * @column Price
 *     cena za dzień konferencji
 * @column StartDay
 *     dzień rozpoczęcia konferencji
 * @column EndDay
 *     dzień zakończenia konferencji
 * @column ParticipantLimit
 *     limit ilości osób na jeden dzień konferencji
 * @column StudentDiscout
 *     wartość zniżki studenckiej
 * 
 * @constraint StartDayEndDay
 *     sprawdza czy dzień końcowy jest po/równy dniu początkowemu
 */
create table Conferences (
	ConferenceID     int identity  not null,
	Name             varchar(255)  not null unique,
	Price            money         not null,
	StartDay         date          not null,
	EndDay           date          not null,
	ParticipantLimit int           null,
	StudentDiscount  decimal(3, 2) not null default 0,
	primary key (ConferenceID),
	constraint StartDayEndDay
		check (StartDay <= EndDay),
	constraint ConferenceNameEmpty
		check (Name <> ''),
	constraint InvlidConferencePrice
		check (Price >= 0),
	constraint InvalidParticipantLimit
		check (ParticipantLimit is null or ParticipantLimit > 0),
	constraint InvalidStudentDiscount
		check (StudentDiscount >= 0 and StudentDiscount <= 1)
);

/**
 * Tabela przechowująca dane o dniach konferencji. Każdy dzień
 * konferencji odnosi się do danej konferencji, jest unikalny oraz
 * zawiera się w przedziale między {@link StartDay} a {@link EndDay}.
 * 
 * @column ConferenceDayID
 *     ID dnia konferencji
 * @column ConferenceID
 *     ID konferencji, do której się odnosi ten dzień
 * @column Day
 *     dany dzień konferencji
 * 
 * @constraint UniqueConferenceDay
 *     sprawdza czy w danej konferencji dni są unikalne
 */
create table ConferenceDays (
	ConferenceDayID int identity not null,
	ConferenceID    int          not null,
	Day             date         not null,
	primary key (ConferenceDayID),
	constraint UniqueConferenceDay
		unique (ConferenceID, Day)
);

/**
 * Tabela przechowująca dane o warsztatach. Jest to słownik
 * warsztatów.
 * 
 * @column WorkshopID
 *     ID warsztatu
 * @column Name
 *     nazwa warsztatu
 * @column Description
 *     opis warsztatu
 */
create table Workshops (
	WorkshopID  int identity not null,
	Name        varchar(255) not null unique,
	Description varchar(1023) null,
	primary key (WorkshopID),
	constraint WorkshopNameEmpty
		check (Name <> ''),
	constraint WorkshopDescriptionEmpty
		check (Description is null or Description <> '')
);

/**
 * Tabela przechowująca dane o konkretnych terminach warsztatów.
 * Każdy termin jest zdefiniowany przez warsztat z {@link Workshops}.
 * 
 * @column WorkshopTermID
 *     ID terminu warsztatu
 * @column WorkshopID
 *     ID warsztatu, który definiuje ten termin
 * @column DayID
 *     ID dnia, w którym termin ma miejsce
 * @column Price
 *     cena terminu warsztatu
 * @column StartTime
 *     czas rozpoczęcia
 * @column EndTime
 *     czas zakończenia
 * @column Capacity
 *     pojemność -- ilość osób, które mogą się zapisać
 * 
 * @constraint StartTimeEndTime
 *     sprawdza czy czas zakończenia warsztatu jest po
 *     czasie rozpoczęcia
 * @constraint InvalidWorkshopPrice
 *     sprawdza czy cena warsztatu jest większa lub równa 0
 * @constraint InvalidWorkshopCapacity
 *     sprawdza czy pojemność jest albo nieograniczona,
 *     albo większa od zera
 */
create table WorkshopTerms (
	WorkshopTermID int identity not null,
	WorkshopID     int          not null,
	DayID          int          not null,
	Price          money        not null,
	StartTime      time         not null,
	EndTime        time         not null,
	Capacity       int          null,
	primary key (WorkshopTermID),
	constraint StartTimeEndTime
		check (StartTime < EndTime),
	constraint InvalidWorkshopPrice
		check (Price >= 0),
	constraint InvalidWorkshopCapacity
		check (Capacity is null or Capacity > 0)
);

create table Prices (
	PriceID      int identity  not null,
	ConferenceID int           not null,
	Till         date          not null,
	Discount     decimal(3, 2) not null,
	primary key (PriceID),
	constraint InvalidPriceDiscount
		check (Discount >= 0 and Discount <= 1)
);
