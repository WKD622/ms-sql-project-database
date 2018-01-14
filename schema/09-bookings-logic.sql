/**
 * Ustawia datę wykonania płatności dla wybranego BookingID 
 */
create procedure setPaid (
	@bookingID    int,
	@paymentDate  date,
	@todaysDate   date = null
) as 
	set xact_abort on;
	begin transaction;
		if @todaysDate is not null
		begin 
			update Bookings
			set PaymentDate = @paymentDate
			where BookingID = @bookingID;
		end
		if @todaysDate is null
		begin
			update Bookings
			set PaymentDate = getdate() 
			where BookingID = @bookingID;
		end
	commit transaction
go

/**
 * Dodaje Booking
 */
create procedure addBookings (
	@customerID      int
) as 
	set xact_abort on;
	begin transaction
		declare @bookingDate date = getdate();
		declare @dueDate date = dateadd(day, 7, @bookingDate);
		declare @paymentDate date = null;
		
		insert into DayBookings (
			CustomerID, BookingDate,
			DueDate, PaymentDate
		) values (
			@customerID, @bookingDate,
			@dueDate, @paymentDate
		);
	commit transaction
go

/**
 * Dodaje dayBooking
 */
create procedure addDayBooking (
	@bookingID       int,
	@conferencedayID int,
	@participants    int
) as 
	set xact_abort on;
	begin transaction
		insert into DayBookings (
			BookingID, ConferenceDayID,
			Participants
		) values (
			@bookingID, @conferencedayID,
			@participants
		);
	commit transaction
go

/**
 * Dodaje WorkshopBooking 
 */ 
 create procedure addWorkshopBooking(
	@workshopTermID    int,
	@dayBookingID      int,
	@participants      int
) as 
	set xact_abort on;
	begin transaction
		insert into WorkshopBookings (
			WorkshopTermID, DayBookingID,
			Participants
		) values (
			@workshopTermID, @dayBookingID,
			@participants
		);
	commit transaction
go
