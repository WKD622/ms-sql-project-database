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
 * @tested oprócz output
 */
create procedure addBooking (
	@customerID int,
	@bookingID int output = null
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
	delete Bookings where BookingID = @bookingID;
go

/**
 * Dodaje rezerwację dnia.
 * 
 * @tested
 */
create procedure addDayBooking (
	@bookingID       int,
	@conferenceDayID int,
	@dayBookingID    int output = null,
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

/**
 * Zwraca zniżkę dla danej rezerwacji dnia.
 * Zniżka ta jest zniżką wynikającą z progu cenowego.
 * 
 * @tested
 */
create function getDayBookingDiscount (
	@dayBookingID int
) returns decimal(3, 2)
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
 * Generuje tabele z danymi do faktury dla danej rezerwacji.
 * 
 * @tested
 */
create function generateInvoice (
	@bookingID int
) returns
@invoice table(
	Product varchar(64),
	Date date,
	Time time,
	Spaces int,
	Price money
)
as
begin
	insert into @invoice (Product, Date, Time, Spaces, Price)
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
		where BookingID = @bookingID);
	
	declare @sum int = (select sum(Price) from @invoice);
	
	insert into @invoice (Product, Date, Time, Spaces, Price)
		values (null, null, null, null, @sum);
	
	return;
end
go
