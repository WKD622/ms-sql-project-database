/*
 * Moduł definiujący funkcje i procedury dla
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
	@customerID int
) as
	insert into Bookings (CustomerID) values (@customerID);
go

/**
 * Dodaje rezerwację dnia.
 * 
 * @tested
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
 * 
 * @tested
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

/**
 * 
 */
create function getDayBookingDiscount (
	@dayBookingID int
) returns int
as
begin
	declare @bookingDate as date;
	select @bookingDate = BookingDate
		from Bookings as b
			inner join DayBookings as db
				on db.BookingID = b.BookingID
		where db.DayBookingID = @dayBookingID;
	
	declare @conferenceID as int;
	select @conferenceID = c.ConferenceID
		from Conferences as c
			inner join ConferenceDays as cd
				on c.ConferenceID = cd.ConferenceID
			inner join DayBookings as db
				on db.ConferenceDayID = cd.ConferenceDayID
		where db.DayBookingID = @dayBookingID;
	
	declare @discount decimal(3,2) =
		(select top 1 Discount
			from Prices
			where ConferenceID = @conferenceID and Till >= @bookingDate
			order by Till);
	
	if @discount is null
		return 0
	
	return @discount;
end
go

/**
 * Zwraca cenę danego dnia konferencji po uwzględnieniu
 * zniżki zależnej od dnia rezerwacji oraz zniżki studenckiej.
 */
create function getDayBookingPrice (
	@dayBookingID int
) returns int
as
begin
	declare @discount decimal(3,2) = dbo.getDayBookingDiscount(@dayBookingID);
	
	declare @studentDiscount decimal(3,2);
	declare @price money;
	
	select  @studentDiscount = StudentDiscount, @price = Price
		from Conferences as c
			inner join ConferenceDays as cd
				on c.ConferenceID = cd.ConferenceID
			inner join DayBookings as db
				on db.ConferenceDayID = cd.ConferenceDayID
		where db.DayBookingID = @dayBookingID;
	
	declare @studentsNo int = (select count(*)
		from BookingStudentIDs
		where DayBookingID = @dayBookingID);
	
	declare @participants int = (select Participants
		from DayBookings
		where DayBookingID = @dayBookingID);
	
	set @price = @price * (1 - @discount);
	
	return
		(@price * @studentsNo * (1 - @studentDiscount) +
		@price * (@participants - @studentsNo));
end
go

/** 
 * Generuje tabele z danymi do faktury dla danego bookingu
 */ 
create function generateInvoice (
	@bookingID int
) returns table
as
return
	(select
		'Day' as Product,
		Day as Date,
		null as Time,
		Participants as Spaces,
		(dbo.getDayBookingPrice(DayBookingID))
			as Price
	from DayBookings as db
		inner join ConferenceDays as cd
			on cd.ConferenceDayID = db.ConferenceDayID
	where BookingID = @bookingID
	union
	select
		'Workshop' as Product,
		cd.Day as Date,
		wt.StartTime as Time,
		wb.Participants as Spaces,
		wt.Price
	from WorkshopBookings as wb
		inner join WorkshopTerms as wt
			on wt.WorkshopTermID = wb.WorkshopTermID
		inner join DayBookings as db
			on db.DayBookingID = wb.DayBookingID
		inner join ConferenceDays as cd
			on cd.ConferenceDayID = db.ConferenceDayID
	where BookingID = @bookingID
	);
go
