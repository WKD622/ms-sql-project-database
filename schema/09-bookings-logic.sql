/*
 * Moduł definiujący funkcje i procedury dla
 * danych dotyczących zamówień.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Ustawia datę wykonania płatności dla wybranego BookingID 
 */
create procedure setPaid (
	@bookingID    int,
	@paymentDate  date = null;
) as
	set xact_abort on;
	begin transaction;
		if @paymentDate is not null
		begin
			update Bookings
				set PaymentDate = @paymentDate
				where BookingID = @bookingID;
		end
		
		if @paymentDate is null
		begin
			update Bookings
				set PaymentDate = getdate() 
				where BookingID = @bookingID;
		end
	commit transaction;
go

/**
 * Dodaje zamówienie.
 */
create procedure addBooking (
	@customerID int
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
 * Dodaje rezerwację dnia.
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
 * Dodaje rezerwację warsztatu. 
 */
create procedure addWorkshopBooking(
	@workshopTermID int,
	@dayBookingID   int,
	@participants   int
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

create function getAvailablePlacesForDay(
	@conferenceDayID int
) returns int
as
begin
	declare @available as int;
	select @available = (c.ParticipantLimit - isnull(sum(db.Participants), 0))
		from Conferences as c
			inner join ConferenceDays as cd
				on cd.ConferenceID = c.ConferenceID
			left join DayBookings as db
				on db.ConferenceDayID = cd.ConferenceDayID
		where cd.ConferenceDayID = @conferenceDayID
		group by c.ParticipantLimit, cd.ConferenceDayID;
	
	return @available;
end
go
