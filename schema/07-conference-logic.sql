/*
 * Moduł definiujący funkcje i procedury dla
 * danych dotyczących konferencji.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Dodaje dni do konferencji.
 * 
 * @tested
 */
create procedure addConferenceDays (
	@confid int
) as
	set xact_abort on;
	begin transaction;
		declare @startDay date;
		declare @endDay date;
		
		select @startDay = StartDay, @endDay = EndDay
			from Conferences
			where Conferences.ConferenceID = @confid;
		
		declare @currDay date = @startDay;
		
		while @currDay <= @endDay
		begin
			insert into ConferenceDays
				(ConferenceID, Day) values (@confid, @currDay);
			
			set @currDay = dateadd(day, 1, @currDay);
		end
	commit transaction;
go

/**
 * Dodaje konferencję wraz z dniami.
 * 
 * @tested
 */
create procedure addConference (
	@name             varchar(255),
	@price            money,
	@startDay         date,
	@endDay           date,
	@participantLimit int,
	@studentDiscount  decimal(3, 2)
) as
	set xact_abort on;
	begin transaction;
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
		
		declare @confid int = scope_identity();
		exec addConferenceDays @confid;
	commit transaction;
go

/**
 * Dodaje próg cenowy dla konferencji.
 */
create procedure addConferencePrice (
	@confid   int,
	@till     date,
	@discount decimal(3, 2)
) as
	insert into Prices (
		ConferenceID,
		Till, Discount
	) values (
		@confid, @till,
		@discount
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

/**
 * Zwraca ilość wolnych miejsc dla danego terminu warsztatu.
 */
create function getAvailablePlacesForWorkshop(
	@workshopTermID int
) returns int
as
begin
	declare @available as int;
	select @available = (wt.Capacity - isnull(sum(wb.Participants), 0))
		from WorkshopTerms as wt
			left join WorkshopBookings as wb
				on wb.WorkshopTermID = wt.WorkshopTermID
		where wt.WorkshopTermID = @workshopTermID
		group by wt.Capacity, wt.WorkshopTermID;
	
	return @available;
end
go
