/*
 * Moduł definiujący funkcje i procedury dla
 * danych dotyczących konferencji.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Dodaje konferencję, zwracając jej ID.
 */
create procedure addConference (
	@name             varchar(255),
	@price            money,
	@startDay         date,
	@endDay           date
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

create function availablePlacesConferenceDay(
	@conferenceDayID int
) returns int
as
begin
	declare @limit as int;
	select @limit = c.ParticipantLimit - sum(db.Participants)
		from Conferences as c
			inner join ConferenceDays as cd
				on cd.ConferenceID = c.ConferenceID
			inner join DayBookings as db
				on db.ConferenceDayID = cd.ConferenceDayID
		where cd.ConferenceDayID = @conferenceDayID
		group by c.ParticipantLimit, cd.ConferenceDayID;
	
	return @limit;
end
go
