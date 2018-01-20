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
 * 
 * @tested
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
		declare @studentID char(6) = dbo.getStudentID(dbo.asParticipant(@customerID));
		
		if @studentID is not null
		begin
			exec addBookingStudentID @dayBookingID, @studentID;
		end
	end
go

/**
 * Dodaje rezerwację warsztatu.
 * 
 * @tested
 */
create procedure addWorkshopBooking (
	@dayBookingID   int,
	@workshopTermID int,
	@participants   int = 1
) as
	insert into WorkshopBookings (
		WorkshopTermID, DayBookingID,
		Participants
	) values (
		@workshopTermID, @dayBookingID,
		@participants
	);
go

/*
create type CompanyParticipants as table (
	FirstName varchar(255),
	LastName varchar(255)
);
go

create procedure addParticipants (
	
)
*/