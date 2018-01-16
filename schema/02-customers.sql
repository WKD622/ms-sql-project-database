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
 *     ID klienta
 * @column Address
 *     adres klienta w formie czytelnej dla człowieka
 * @column Phone
 *     numer telefonu klienta w postaci czytelnej dla człowieka
 * @column Email
 *     adres email klienta
 * @column Login
 *     login klienta
 * @column Password
 *     hasło do konta w postaci hashowanej
 */
create table Customers (
	CustomerID int identity   not null,
	Address    varchar(255)   not null,
	Phone      varchar(32)    not null,
	Email      varchar(255)   not null unique,
	Login      varchar(64)    not null unique,
	Password   varbinary(255) not null,
	primary key (CustomerID),
	constraint AddressEmpty
		check (Address <> ''),
	constraint PhoneEmpty
		check (Phone <> ''),
	constraint InvalidEmail
		check (Email like '_%@_%._%'),
	constraint LoginTooShort
		check (len(Login) >= 5)
);

/**
 * Tabela przechowująca dane klientów -- firm.
 * 
 * @column CustomerID
 *     ID klienta, identyczne z {@link Customers.CustomerID}
 * @column NIP
 *     numer identyfikacji podatkowej firmy
 * @column CompanyName
 *     nazwa firmy
 */
create table Companies (
	CustomerID  int          not null,
	NIP         char(10)     not null unique,
	CompanyName varchar(255) not null,
	primary key (CustomerID),
	constraint InvalidNIP
		check (NIP not like '%[^0-9]%'),
	constraint CompanyNameEmpty
		check (CompanyName <> '')
);

/**
 * Tabela przechowująca dane klientów -- osób fizycznych.
 * 
 * @column CustomerID
 *     ID klienta, identyczne z {@link Customers.CustomerID}
 * @column ParticipantID
 *     ID uczestnika
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
 *     ID firmy
 * @column ParticipantID
 *     ID uczestnika
 */
create table CompanyParticipants (
	CompanyID     int not null,
	ParticipantID int not null,
	primary key (ParticipantID)
);

/**
 * Tabela przechowująca numery legitymacji studenckich
 * uczestników.
 * 
 * @column ParticipantID
 *     ID uczestnika
 * @column StudentID
 *     numer legitymacji studenckiej
 */
create table StudentIDs (
	ParticipantID int     not null,
	StudentID     char(6) not null unique,
	primary key (ParticipantID),
	constraint InvalidStudentID
		check (StudentID not like '%[^0-9]%')
);

/**
 * Tabela przechowująca dane uczestników.
 * 
 * @column ParticipantID
 *     ID uczestnika
 * @column FirstName
 *     imię uczestnika
 * @column LastName
 *     nazwisko uczestnika
 */
create table Participants (
	ParticipantID int identity not null,
	FirstName     varchar(255) not null,
	LastName      varchar(255) not null,
	primary key (ParticipantID),
	constraint FirstNameEmpty
		check (FirstName <> ''),
	constraint LastNameEmpty
		check (LastName <> '')
);
