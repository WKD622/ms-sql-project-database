/*
 * Moduł definiujący procedury dla
 * danych dotyczących zamówień.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Ustawia datę wykonania płatności dla wybranego zamówienia.
 * 
 * @tested
 */
create procedure setPaid (
	@bookingID   int,
	@paymentDate date = null
) as
	if @paymentDate is null
		select @paymentDate = getdate();
	
	update Bookings
		set PaymentDate = @paymentDate
		where BookingID = @bookingID;
go

/**
 * Dodaje zamówienie.
 * 
 * @tested
 */
create procedure addBooking (
	@customerID int,
	@bookingID  int = null output
) as
	insert into Bookings (CustomerID) values (@customerID);
	select @bookingID = scope_identity();
go

/**
 * Usuwa zamówienie.
 * 
 * @tested dla klienta indywidualnego, ale dla firmy powinno działać też na 99.9%
 */
create procedure cancelBooking (
	@bookingID int
) as
	declare @daybookingID int;
	
	delete WorkshopBookings
		where DayBookingID in
			(select DayBookingID
				from DayBookings
				where BookingID = @bookingID);
	
	delete DayBookings
		where BookingID = @bookingID;
	
	delete Bookings where BookingID = @bookingID;
go

/**
 * Dodaje nr legitymacji studenckiej dla zamówienia.
 * 
 * @tested
 */
create procedure addBookingStudentID (
	@dayBookingID int,
	@studentID    char(6)
) as
	insert into BookingStudentIDs (DayBookingID, StudentID)
		values (@dayBookingID, @studentID);
go

/**
 * Dodaje rezerwację dnia.
 */
create procedure addDayBooking (
	@bookingID       int,
	@conferenceDayID int,
	@dayBookingID    int = null output,
	@participants    int = 1
) as
	insert into DayBookings (
		BookingID, ConferenceDayID,
		Participants
	) values (
		@bookingID, @conferenceDayID,
		@participants
	);
	
	select @dayBookingID = scope_identity();
	
	declare @customerID int = (select CustomerID
		from Bookings
		where BookingID = @bookingID);
	
	if dbo.isPerson(@customerID) = 1
	begin
		declare @participantID int = dbo.asParticipant(@customerID);
		declare @studentID char(6) = dbo.getStudentID(@participantID);
		
		if @studentID is not null
		begin
			exec addBookingStudentID @dayBookingID, @studentID;
		end
		
		exec fillDayBooking @dayBookingID, @participantID;
	end
go

/**
 * Dodaje rezerwację warsztatu.
 * 
 * @tested
 */
create procedure addWorkshopBooking (
	@dayBookingID      int,
	@workshopTermID    int,
	@workshopBookingID int = null output,
	@participants      int = 1
) as
	insert into WorkshopBookings (
		WorkshopTermID, DayBookingID,
		Participants
	) values (
		@workshopTermID, @dayBookingID,
		@participants
	);
	
	declare @customerID int = (select CustomerID
		from Bookings as b
			inner join DayBookings as db
				on db.BookingID = b.BookingID
		where DayBookingID = @dayBookingID);
	
	if dbo.isPerson(@customerID) = 1
	begin
		declare @participantID int = dbo.asParticipant(@customerID);
		declare @studentID char(6) = dbo.getStudentID(@participantID);
		
		if @studentID is not null
		begin
			exec addBookingStudentID @dayBookingID, @studentID;
		end
		
		exec fillWorkshopBooking @dayBookingID, @participantID;
	end
go

create procedure fillDayBooking (
	@dayBookingID  int,
	@participantID int
) as
	insert into DayBookingDetails (
		DayBookingID, ParticipantID
	) values (
		@dayBookingID, @participantID
	);
go

create procedure fillWorkshopBooking (
	@workshopBookingID int,
	@participantID     int
) as
	insert into WorkshopBookingDetails (
		WorkshopBookingID, ParticipantID
	) values (
		@workshopBookingID, @participantID
	);
go
