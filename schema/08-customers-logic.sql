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

create function isPerson (
	@customerID int
) returns bit
as
begin
	return exists (select * from Persons where CustomerID = @customerID);
end
go
