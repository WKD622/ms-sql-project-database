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
 * 
 * @tested
 */
create trigger ParticipantLimitWorkshopBookings
	on WorkshopBookings
	for insert, update as
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
	
	if (@sum > @capacity)
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
 * 
 * @tested
 */
create trigger ParticipantLimitDayBookings
	on DayBookings
	for insert, update as
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
		where cd.ConferenceDayID = @dayID;
	
	declare @sum int;
	select @sum = sum(Participants)
		from DayBookings as db
		where db.ConferenceDayID = @dayID;
	
	if (@sum > @limit)
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
	for insert, update as
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
 * 
 * @tested
 */
create trigger DeleteBookingAfterPayment
	on Bookings
	for delete as
begin
	declare @bookingID int;
	select @bookingID = BookingID
		from deleted;
	
	declare @paymentDate date;
	select @paymentDate = PaymentDate
		from deleted;
	
	if @paymentDate is not null
	begin
		print 'Cannot delete a paid booking';
		rollback;
	end
end
go

/**
 * Sprwdza czy rezerwacja warsztatu robiona jest w dobry dzień.
 */
create trigger WorkshopDay
	on WorkshopBookings
	for insert, update as
begin
	declare @dayID1 int;
	select @dayID1 = DayID
		from WorkshopTerms
		where WorkshopTermID = (select WorkshopTermID from inserted);
	
	declare @dayID2 int;
	select @dayID2 = ConferenceDayID
		from DayBookings
		where DayBookingID = (select DayBookingID from inserted);
	
	if @dayID1 <> @dayID2
	begin
		print 'Cannot book a workshop on a wrong day';
		rollback;
	end
end
go

/**
 * Dla osoby fizycznej w rezerwacji dnia
 * wymaga żeby było Participants = 1.
 * 
 * @tested
 */
create trigger DayBookingParticipants
	on DayBookings
	for insert, update as
begin
	declare @bookingID int;
	select @bookingID = BookingID from inserted;
	
	declare @customerID int;
	select @customerID = CustomerID
		from Bookings
		where BookingID = @bookingID;
	
	if dbo.isPerson(@customerID) = 1 and (select Participants from inserted) <> 1
	begin
		print 'A person may only book one place'
		rollback;
	end
end
go

/**
 * Dla osoby fizycznej w rezerwacji warsztatu wymaga
 * żeby było Participants = 1.
 * 
 * @tested
 */
create trigger WorkshopBookingParticipants
	on WorkshopBookings
	for insert, update as
begin
	declare @customerID int;
	select @customerID = CustomerID
		from DayBookings as db
			inner join Bookings as b
				on db.BookingID = b.BookingID
		where DayBookingID = (select DayBookingID from inserted);
	
	if dbo.isPerson(@customerID) = 1 and (select Participants from inserted) <> 1
	begin
		print 'A person may only book one place'
		rollback;
	end
end
go

/**
 * Sprwdza czy pojemność danego warsztatu nie jest większa niż pojemność
 * dnia konferencji do którego należy ten warsztat.
 */
create trigger WorkshopCapacity
	on WorkshopTerms
	for insert as
begin
	declare @workshopTermID int;
	select @workshopTermID = wt.WorkshopTermID
		from WorkshopTerms as wt
		where wt.WorkshopTermID = (select WorkshopTermID from inserted);
	
	declare @dayID int;
	declare @capacity int;
	
	select @dayID = wt.DayID, @capacity = wt.Capacity
		from WorkshopTerms as wt
		where wt.WorkshopTermID = @workshopTermID;
	
	declare @conferenceID int;
	select @conferenceID = cd.ConferenceID
		from ConferenceDays as cd
		where cd.ConferenceDayID = @dayID;
	
	declare @participantLimit int;
	select @participantLimit = c.ParticipantLimit
		from Conferences as c
		where c.ConferenceID = @conferenceID;
	
	if @participantLimit < @capacity
	begin
		print 'Capacity of WorkshopTerm is bigger than limit of participants for its ConferenceDay'
		rollback;
	end
end
go
