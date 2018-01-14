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
	select @wtermid = WorkshopTermID
		from inserted;
	
	declare @capacity int;
	select @capacity = Capacity
		from WorkshopTerms as wt
		where wt.WorkshopTermID = @wtermid;
	
	declare @participants int;
	select @participants = Participants
		from inserted;
	
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

/**
 * sprawdza czy dzień konferencji zawiera się w przedziale dat
 * konferencji <s>oraz czy już dzień ten nie jest dodany</s>
 * sprawdzanie czy dzień jest dodany jest w unique
 * 
 * DZIAŁA
 */
create trigger ConferenceDayValidity
	on ConferenceDays
	for insert as
begin
	declare @confid int;
	select @confid = ConferenceID
		from inserted;
	
	declare @day date;
	select @day = Day
		from inserted;
	
	/*declare @cnt int;
	select @cnt = count(*)
		from ConferenceDays
		where Day = @day;
	
	if (@cnt > 0)
	begin
		print 'Conference day already added';
		rollback;
	end*/
	
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
