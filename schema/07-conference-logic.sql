/*
 * Moduł definiujący funkcje i procedury dla
 * danych dotyczących konferencji.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Dodaje konferencję.
 */
create procedure addConference (
	@name             varchar(255),
	@price            money,
	@startDay         date,
	@endDay           date,
	@participantLimit int,
	@studentDiscount  decimal(3, 2)
) as
	insert into Conferences (
		Name, Price,
		StartDay, EndDay,
		ParticipantLimit,
		StudentDiscount
	) values (
		@name, @price,
		@startDay, @endDay,
		@participantLimit,
		@studentDiscount
	);
go

/**
 * Zwraca ilość wolnych miejsc dla danego dnia konferencji.
 */
create function getAvailablePlacesForDay(
	@conferenceDayID int
) returns int
as
begin
	declare @available as int;
	select @available = c.ParticipantLimit - sum(db.Participants)
		from Conferences as c
			inner join ConferenceDays as cd
				on cd.ConferenceID = c.ConferenceID
			inner join DayBookings as db
				on db.ConferenceDayID = cd.ConferenceDayID
		where cd.ConferenceDayID = @conferenceDayID
		group by c.ParticipantLimit, cd.ConferenceDayID;
	
	return @available;
end
go

/**
 * Zwraca ilość wolnych miejsc dla danego terminu warsztatu.
 */
create function getAvailablePlacesForWorkshop(
	@workshopTermID int
) returns int
as
begin
	declare @available as int;
	select @available = wt.Capacity - sum(wb.Participants)
		from WorkshopTerms as wt
			inner join WorkshopBookings as wb
				on wb.WorkshopTermID = wt.WorkshopTermID
		where wt.WorkshopTermID = @workshopTermID
		group by wt.Capacity, wt.WorkshopTermID;
	
	return @available;
end
go
