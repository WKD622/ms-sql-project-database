/*
 * Moduł definiujący triggery.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Dla danego WorkshopTermID w WorkshopBookings, suma pól
 * Paticipants (plus ilość miejsc z nowego wiersza) musi być
 * mniejsza bądź równa wartości Capacity w WorkshopTerms.
 */
create trigger ParticipantLimitWorkshopBookings
	on WorkshopBookings
	for insert as
begin
	declare @wtermid int;
	declare @participants int;
	select
			@wtermid = WorkshopTermID,
			@participants = Participants
		from inserted;
	
	declare @capacity int;
	select @capacity = Capacity
		from WorkshopTerms as wt
		where wt.WorkshopTermID = @wtermid;
	
	declare @sum int;
	select @sum = sum(Participants)
		from WorkshopBookings as wb
		where wb.WorkshopTermID = @wtermid;
	
	if (@sum + @participants > @capacity)
	begin
		print 'Too many participants';
		rollback;
	end
end
go

/**
 * Dla danego dnia, suma pól Paticipants (plus ilość miejsc z
 * nowego wiersza) musi być mniejsza bądź równa wartości
 * ParticipantLimit w Conferences.
 */
create trigger ParticipantLimitDayBookings
	on DayBookings
	for insert as
begin
	declare @dayID int;
	declare @participants int;
	select
			@dayID = ConferenceDayID,
			@participants = Participants
		from inserted;
	
	declare @limit int;
	select @limit = ParticipantLimit
		from Conferences as c
			inner join ConferenceDays as cd
				on cd.ConferenceID = c.ConferenceID
		where db.ConferenceDayID = @dayID;
	
	declare @sum int;
	select @sum = sum(Participants)
		from DayBookings as db
		where db.ConferenceDayID = @dayID;
	
	if (@sum + @participants > @limit)
	begin
		print 'Too many participants';
		rollback;
	end
end
go

/**
 * Sprawdza czy dzień konferencji zawiera się w
 * terminie konferencji.
 * 
 * @tested
 */
create trigger ConferenceDayValidate
	on ConferenceDays
	for update as
begin
	declare @confid int;
	select @confid = ConferenceID
		from inserted;
	
	declare @day date;
	select @day = Day
		from inserted;
	
	declare @from date;
	declare @to date;
	select @from = StartDay, @to = EndDay
		from Conferences where ConferenceID = @confid;
	
	if (@day < @from or @day > @to)
	begin
		print 'Invalid conference day (not in the interval)';
		rollback;
	end
end
go

/**
 * Nie pozwala usunąć zamówienia, które jest
 * opłacone.
 */
create trigger DeleteBookingAfterPayment
	on Bookings
	for delete as
begin
	declare @bokingid int;
	select @bokingid = BookingID
		from deleted;
	
	declare @paymentDate date;
	select @paymentDate = PaymentDate
		from Bookings
		where BookingID = @bookingID;
	
	if @paymetDate is not null
	begin
		print 'Cannot delete a paid booking';
		rollback;
	end
end
go

/**
 * Dla osoby fizycznej w rezerwacji dnia
 * wymaga żeby było Participants = 1.
 */
create trigger DayBookingParticipants
	on DayBookings
	for update as
begin
	declare @customerID int;
	select @customerID = CustomerID
		from Bookings
		where BookingID = (select BookingID from inserted);
	
	if isPerson(@customerID) = 1 and (select Participants from inserted) <> 1
	begin
		print 'A person may only book one place'
		rollback;
	end
end
go

/**
 * Dla osoby fizycznej w rezerwacji warsztatu wymaga
 * żeby było Participants = 1.
 */
create trigger WorkshopBookingParticipants
	on WorkshopBookings
	for update as
begin
	declare @customerID int;
	select @customerID = CustomerID
		from DayBookings as db
			inner join Bookings as b
				on db.BookingID = b.BookingID
		where DayBookingID = (select DayBookingID from inserted);
	
	if isPerson(@customerID) = 1 and (select Participants from inserted) <> 1
	begin
		print 'A person may only book one place'
		rollback;
	end
end
go
