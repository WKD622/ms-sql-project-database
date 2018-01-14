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
	@lastName  char(10),
	@address   varchar(255),
	@phone     varchar(32),
	@email     varchar(255),
	@login     varchar(64),
	@password  varbinary(255)
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
	commit transaction;
go
