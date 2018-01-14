/*
 * Moduł definiujący funkcje i procedury.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
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
