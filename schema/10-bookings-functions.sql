/*
 * Moduł definiujący funkcje dla
 * danych dotyczących zamówień.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

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
 * Zwraca ilość studentów z danej rezerwacji dnia.
 */
create function getDayBookingStudentCount (
	@dayBookingID int
) returns int
as
begin
	return (select count(*)
		from BookingStudentIDs
		where DayBookingID = @dayBookingID);
end
go

/**
 * Zwraca cenę danego dnia konferencji po uwzględnieniu
 * zniżki zależnej od dnia rezerwacji oraz zniżki studenckiej.
 */
create function getDayBookingPrice (
	@dayBookingID int
) returns money
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
	
	declare @studentsNo int = dbo.getDayBookingStudentCount(@dayBookingID);
	
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
	Product nvarchar(64),
	Date date,
	Time time,
	Participants int,
	Discount decimal(3,0),
	Students int,
	StudentDiscount decimal(3,0),
	Price money
)
as
begin
	insert into @invoice (Product, Date, Time, Participants, Discount, Students, StudentDiscount, Price)
	(select
		-- Produkt to dzień
			'Day' as Product,
		-- Wartość dnia jako data
			Day as Date,
		-- Czas nie dotyczy
			null as Time,
		-- Ilość osób z rezerwacji dnia
			Participants,
		-- Wartość zniżki z progu
			(100 * dbo.getDayBookingDiscount(DayBookingID))
				as Discount,
		-- Ilość studentów z rezerwacji
			(dbo.getDayBookingStudentCount(DayBookingID))
				as Students,
		-- Wartość zniżki studenckiej
			(100 * StudentDiscount)
				as StudentDiscount,
		-- Cena
			(dbo.getDayBookingPrice(DayBookingID))
				as Price
		from DayBookings as db
			inner join ConferenceDays as cd
				on cd.ConferenceDayID = db.ConferenceDayID
			inner join Conferences as c
				on c.ConferenceID = cd.ConferenceID
		where BookingID = @bookingID
		union
		select
			'Workshop' as Product,
			cd.Day as Date,
			wt.StartTime as Time,
			wb.Participants,
			0 as Discount,
			(dbo.getDayBookingStudentCount(db.DayBookingID))
				as Students,
			0 as StudentDiscount,
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
	
	insert into @invoice (Product, Date, Time, Participants, Discount, Students, StudentDiscount, Price)
		values (null, null, null, null, null, null, null, @sum);
	
	return;
end
go
