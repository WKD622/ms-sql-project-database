/*
 * Moduł definiujący funkcje i procedury dla
 * danych dotyczących klientów.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Dodaje firmę.
 * 
 * @tested
 */
create procedure addCompany (
	@name     varchar(255),
	@nip      char(10),
	@address  varchar(255),
	@phone    varchar(32),
	@email    varchar(255),
	@login    varchar(64),
	@password varbinary(255)
) as
	set xact_abort on;
	begin transaction;
		insert into Customers (
			Address, Phone,
			Email, Login,
			Password
		) values (
			@address, @phone,
			@email, @login,
			@password
		);
		
		insert into Companies (
			CustomerID,
			NIP, CompanyName
		) values (
			scope_identity(),
			@nip, @name
		);
	commit transaction;
go

/**
 * Dodaje osobę fizyczną.
 * 
 * @tested
 */
create procedure addPerson (
	@firstName varchar(255),
	@lastName  varchar(255),
	@address   varchar(255),
	@phone     varchar(32),
	@email     varchar(255),
	@login     varchar(64),
	@password  varbinary(255),
	@studentID char(6) = null
) as
	set xact_abort on;
	begin transaction;
		insert into Customers (
			Address, Phone,
			Email, Login,
			Password
		) values (
			@address, @phone,
			@email, @login,
			@password
		);
		
		declare @cid int = scope_identity();
		
		insert into Participants (
			FirstName, LastName
		) values (
			@firstName, @lastName
		);
		
		declare @pid int = scope_identity();
		
		insert into Persons (
			ParticipantID, CustomerID
		) values (
			@pid, @cid
		);
		
		if @studentID is not null
		begin
			insert into StudentIDs (
				ParticipantID, StudentID
			) values (
				@pid, @studentID
			);
		end
	commit transaction;
go

/**
 * Dodaje uczestnika z danej firmy.
 * 
 * @tested
 */
create procedure addCompanyParticipant (
	@companyID int,
	@firstName varchar(255),
	@lastName  varchar(255),
	@studentID char(6) = null
) as
	set xact_abort on;
	begin transaction;
		insert into Participants (
			FirstName, LastName
		) values (
			@firstName, @lastName
		);
		
		declare @pid int = scope_identity();
		
		insert into CompanyParticipants (
			ParticipantID, CompanyID
		) values (
			@pid, @companyID
		);
		
		if @studentID is not null
		begin
			insert into StudentIDs (
				ParticipantID, StudentID
			) values (
				@pid, @studentID
			);
		end
	commit transaction;
go

/**
 * Sprawdź czy dany klient jest osobą fizyczną czy firmą.
 *
 * @tested
 */
create function isPerson (
	@customerID int
) returns bit
as
begin
	if exists (select * from Persons where CustomerID = @customerID)
		return 1
	
	return 0
end
go

/**
 * Sprawdź czy uczestnik jest studentem.
 */
create function isStudent (
	@participantID int
) returns bit
as
begin
	if exists (select * from StudentIDs where ParticipantID = @participantID)
		return 1
	
	return 0
end
go

/**
 * Pobierz nr legitymacji studenckiej.
 */
create function getStudentID (
	@participantID int
) returns char(6)
as
begin
	return (select StudentID from StudentIDs where ParticipantID = @participantID)
end
go

/**
 * Zwróć ID uczestnika dla ID osoby fizycznej.
 */
create function asParticipant (
	@customerID int
) returns int
as
begin
	return (select ParticipantID
		from Persons
		where CustomerID = @customerID);
end
go

/**
 * Zwróć ID klienta dla danego loginu lub {@code null}
 * jeśli klient o takim loginie nie istnieje.
 * 
 * @tested
 */
create function getCustomerForLogin (
	@login varchar(64)
) returns int
as
begin
	return (select CustomerID from Customers where Login = @login);
end
go
