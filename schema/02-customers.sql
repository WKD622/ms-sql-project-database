/*
 * Moduł schematu bazy danych odpowiedzialny za przechowywanie
 * informacji o klientach i uczestnikach.
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
	Address    varchar(255)   not null
		check (Address <> ''),
	Phone      varchar(32)    not null
		check (Phone <> ''),
	Email      varchar(255)   not null
		check (Email like '_%@_%._%'),
	Login      varchar(64)    not null
		check (CHAR_LENGTH(Login) > 5),
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
	CompanyName varchar(255) not null
		check (CompanyName <> ''),
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

create table StudentIDs (
	ParticipantID int     not null,
	StudentID     char(6) not null unique
		check (StudentID not like '%[^0-9]%'),
	primary key (ParticipantID)
);

create table Participants (
	ParticipantID int identity not null
	FirstName     varchar(255) not null
		check (FirstName <> ''),
	LastName      varchar(255) not null
		check (LastName <> ''),
	primary key (ParticipantID)
);
