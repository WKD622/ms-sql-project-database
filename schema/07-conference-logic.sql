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
 * Dodaje warsztat.
 * 
 * @tested
 */
create procedure addWorkshop (
	@name        varchar(255),
	@description varchar(255) = null
) as
	insert into Workshops (
		Name, Description
	) values (
		@name, @description
	);
go

/**
 * Dodaje instancję wybranego warsztatu.
 * 
 * @tested
 */
create procedure addWorkshopTerm (
	@workshopID int,
	@dayID      int,
	@price      money,
	@startTime  time,
	@endTime    time,
	@capacity   int = null,
	
	@workshopTermID int = null output
) as
	insert into WorkshopTerms (
		WorkshopID, DayID,
		Price, StartTime,
		EndTime, Capacity
	) values (
		@workshopID, @dayID,
		@price, @startTime,
		@endTime, @capacity
	);
	
	select @workshopTermID = scope_identity();
go

/**
 * Dodaje próg cenowy dla konferencji.
 * 
 * @tested
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
 * Zwraca {@code null} gdy ilość miejsc jest nieograniczona.
 * 
 * @tested
 */
create function getAvailableSpacesForDay (
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
 * Zwraca {@code null} gdy ilość miejsc jest nieograniczona.
 * 
 * @tested
 */
create function getAvailableSpacesForWorkshop (
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

/**
 * Zwraca ConferenceID dla podanej nazwy konferencji.
 * 
 * @tested
 */
create function getConferenceForName (
	@name varchar(255)
) returns int
as
begin
	declare @conferenceID as int;
	
	select @conferenceID = c.conferenceID
		from Conferences as c
		where c.Name = @name;
	
	return @conferenceID;
end
go

/**
 * Zwraca ID warsztatu dla podanej nazwy warsztatu.
 * 
 * @tested
 */
create function getWorkshopForName (
	@name varchar(255)
) returns int
as
begin
	declare @workshopID as int;
	
	select @workshopID = w.WorkshopID
		from Workshops as w
		where w.Name = @name;
	
	return @workshopID;
end
go

/**
 * Zwraca cenę danego terminu warsztatu.
 * 
 * @tested
 */
create function getWorkshopTermPrice (
	@workshopTermID int
) returns int
as
begin
	return (select Price
		from WorkshopTerms
		where WorkshopTermID = @workshopTermID);
end
go

/**
 * Zwraca ID dnia konferencji dla podanej daty.
 * 
 * @tested
 */
create function getDayForDate (
	@conferenceID int,
	@date date
) returns int
as
begin
	return (select ConferenceDayID
		from ConferenceDays
		where
			ConferenceID = @conferenceID and
			Day = @date);
end
go

drop type TimeTable;
create type TimeTable as table (
	TimeFrom time,
	TimeTo time
);
go

/**
 * Zwraca prawdę jeśli dany zakres czasów zachodzi
 * na dowolny z @times.
 */
create function isTimeConflict (
	@from time, @to time,
	@times TimeTable readonly
) returns bit
as
begin
	if exists (select * from @times
		where TimeFrom < @to and TimeTo > @from)
		return 1;
	
	return 0;
end
go
