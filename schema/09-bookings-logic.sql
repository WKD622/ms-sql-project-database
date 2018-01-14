/*
 * Moduł definiujący funkcje i procedury dla
 * danych dotyczących zamówień.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Ustawia datę wykonania płatności dla wybranego zamówienia.
 */
create procedure setPaid (
	@bookingID int
) as
	update Bookings
		set PaymentDate = getdate()
		where BookingID = @bookingID;
go

/**
 * Dodaje zamówienie.
 */
create procedure addBooking (
	@customerID int
) as
	insert into DayBookings (
		CustomerID, BookingDate,
		DueDate, PaymentDate
	) values (
		@customerID, default,
		default, null
	);
go

/**
 * Dodaje rezerwację dnia.
 */
create procedure addDayBooking (
	@bookingID       int,
	@conferenceDayID int,
	@participants    int = 1
) as
	insert into DayBookings (
		BookingID, ConferenceDayID,
		Participants
	) values (
		@bookingID, @conferenceDayID,
		@participants
	);
go

/**
 * Dodaje rezerwację warsztatu.
 */
create procedure addWorkshopBooking (
	@workshopTermID int,
	@dayBookingID   int,
	@participants   int
) as
	insert into WorkshopBookings (
		WorkshopTermID, DayBookingID,
		Participants
	) values (
		@workshopTermID, @dayBookingID,
		@participants
	);
go

create function generateInvoice (
	@bookingID int
) returns table
as
begin
	declare @ret table = (select
			'Day' as Product,
			Day as Date,
			null as Time,
			Participants as Spaces,
			(getDayBookingPrice(DayBookingID))
				as Price
		from DayBookings as db
			inner join ConferenceDays as cd
				on cd.ConferenceDayID = db.ConferenceDayID
		where BookingID = @bookingID)
		/*union ...*/;
	
	return @ret;
end
