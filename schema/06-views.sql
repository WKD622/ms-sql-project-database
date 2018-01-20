/*
 * Moduł definiujący widoki.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Widok przedstawiąjący listę dni konferencji
 * wraz z podsumowaniem zajętości miejsc.
 * 
 * @tested
 */
create view ConferenceDaysPlaces as
	select
			cd.ConferenceID,
			cd.ConferenceDayID,
			cd.Day,
			c.ParticipantLimit,
			(isnull(sum(Participants), 0))
				as BookedPlaces,
			(c.ParticipantLimit - isnull(sum(Participants), 0))
				as AvailablePlaces
		from ConferenceDays as cd
			left join Conferences as c
				on c.ConferenceID = cd.ConferenceID
			left join DayBookings as db
				on db.ConferenceDayID = cd.ConferenceDayID
		group by cd.ConferenceID, cd.ConferenceDayID,
			cd.Day, c.ParticipantLimit;
go

/**
 * Widok przedstawiąjący listę terminów warsztatów
 * wraz z podsumowaniem zajętości miejsc.
 */
create view WorkshopTermsPlaces as
	select
			wt.WorkshopTermID,
			wt.Capacity,
			(isnull(sum(Participants), 0))
				as BookedPlaces,
			(wt.Capacity - isnull(sum(Participants), 0))
				as AvailablePlaces
		from WorkshopTerms as wt
			left join WorkshopBookings as wb
				on wt.WorkshopTermID = wb.WorkshopTermID
		group by wt.WorkshopTermID, wt.Capacity;
go

/**
 * Widok podsumowujący klientów.
 * 
 * @column IsCompany
 *     równe 1 jeśli klient jest firmą, 0 w innym przypadku
 * @column Name
 *     nazwa klienta -- dla firm nazwa firmy, dla osób
 *     fizycznych imię i nazwisko
 * @column NIP
 *     NIP firmy lub {@code null} w przypadku osoby fizycznej
 * 
 * @tested
 */
create view CustomersSummary as
	select
			c.CustomerID,
			(cast(case
				when comp.CustomerID is not null then 1
				else 0
			end as bit))
				as IsCompany,
			(case
				when comp.CustomerID is not null then comp.CompanyName
				else p.FirstName + ' ' + p.LastName
			end)
				as Name,
			comp.NIP,
			c.Address,
			c.Phone,
			c.Email,
			c.Login
		from Customers as c
			left join Companies as comp
				on comp.CustomerID = c.CustomerID
			left join Persons as per
				on per.CustomerID = c.CustomerID
			left join Participants as p
				on p.ParticipantID = per.ParticipantID;
go

/**
 * Widok aktywności klientów.
 * 
 * @column DayBookingsCount
 *     ilość kupionych dni konferencji
 * @column WorkshopBookingsCount
 *     ilość kupionych warsztatów
 * @column BookingsCount
 *     ilość kupionych warsztatów i dni konferencji
 * 
 * @tested
 */
create view ActiveCustomers as
	select
			cs.CustomerID,
			cs.IsCompany,
			cs.Name,
			(count(distinct db.DayBookingID))
				as DayBookingsCount,
			(count(distinct wb.WorkshopBookingID))
				as WorkshopBookingsCount,
			(count(distinct db.DayBookingID) + count(distinct wb.WorkshopBookingID))
				as BookingsCount
		from CustomersSummary as cs
			left join Bookings as b
				on b.CustomerID = cs.CustomerID
			left join DayBookings as db
				on db.BookingID = b.BookingID
			left join WorkshopBookings as wb
				on wb.DayBookingID = db.DayBookingID
		group by cs.CustomerID, cs.IsCompany, cs.Name;
go

/**
 * Widok rezerwacji, które nie zostały jeszcze zapłacone
 * oraz ich termin płatności się zakończył.
 * 
 * @column Delay
 *     ilość dni spóźnienia
 * 
 * @tested
 */
create view UnpaidBookings as
	select
			BookingID,
			BookingDate,
			DueDate,
			PaymentDate,
			(datediff(day, DueDate, getdate())) as Delay
		from Bookings
		where PaymentDate is null and getdate() > DueDate;
go

/**
 * Widok podsumowania rezerwacji warsztatów.
 * 
 * @column CustomerID
 *     ID klienta składającego zamówienie
 * @column ParticipantID
 *     ID uczestnika biorącego udział w warsztacie
 * @column WorkshopID
 *     ID warsztatu
 * @column Name
 *     nazwa warsztatu
 * @column Description
 *     opis warsztatu
 * @column Day
 *     dzień, w którym warsztat ma miejsce
 * @column StartTime
 *     czas rozpoczęcia warsztatu
 * @column EndTime
 *     czas zakończenia warsztatu
 * @column Paid
 *     {@code 1} jeśli zapłacony
 * 
 * @tested
 */
create view WorkshopBookingsSummary as
	select
			c.CustomerID,
			wbd.ParticipantID,
			w.WorkshopID,
			w.Name,
			w.Description,
			cd.Day,
			wt.StartTime,
			wt.EndTime,
			(case when b.PaymentDate is null then 0 else 1 end)
				as Paid
		from Workshops as w
			inner join WorkshopTerms as wt
				on wt.WorkshopID = w.WorkshopID
			inner join WorkshopBookings as wb
				on wb.WorkshopTermID = wt.WorkshopTermID
			left join WorkshopBookingDetails as wbd
				on wbd.WorkshopBookingID = wb.WorkshopBookingID
			inner join DayBookings as db
				on db.DayBookingID = wb.DayBookingID
			inner join Bookings as b
				on db.BookingID = b.BookingID
			inner join Customers as c
				on c.CustomerID = b.CustomerID
			inner join ConferenceDays as cd
				on cd.ConferenceDayID = db.ConferenceDayID;
go

/**
 * Widok podsumowania warsztatów.
 * 
 * @column WorkshopID
 *     ID warsztatu
 * @column WorkshopTermID
 *     ID terminu warsztatu
 * @column Name
 *     nazwa warsztatu
 * @column Description
 *     opis warsztatu
 * @column Day
 *     dzień, w którym warsztat ma miejsce
 * @column StartTime
 *     czas rozpoczęcia warsztatu
 * @column EndTime
 *     czas zakończenia warsztatu
 * @column Capacity
 *     pojemność warsztatu
 * @column Enrolled
 *     ilośc osób zapisanych
 * @column PercentEnrolled
 *     procent zapełnienia warsztatu
 * 
 * @tested
 */
create view WorkshopsSummary as
	select
			w.WorkshopID,
			wt.WorkshopTermID,
			w.Name,
			w.Description,
			cd.Day,
			wt.StartTime,
			wt.EndTime,
			(sum(wb.Participants)) as Enrolled,
			wt.Capacity,
			cast(
				100 * (
					cast(sum(wb.Participants) as decimal) /
					wt.Capacity
				) as decimal(5, 2)
			)
				as PercentEnrolled
		from Workshops as w
			inner join WorkshopTerms as wt
				on wt.WorkshopID = w.WorkshopID
			inner join WorkshopBookings as wb
				on wb.WorkshopTermID = wt.WorkshopTermID
			inner join DayBookings as db
				on db.DayBookingID = wb.DayBookingID
			inner join ConferenceDays as cd
				on cd.ConferenceDayID = db.ConferenceDayID
		group by w.WorkshopID, wt.WorkshopTermID, Name,
			Description, Day, StartTime, EndTime, wt.Capacity;
go

/**
 * nie działa dla niezapisanych osób (pokazuje
 * jeden wiersz dla jednego klienta)
 */
create view WorkshopParticipantLists as
	select
			wt.WorkshopTermID,
			w.Name,
			p.ParticipantID,
			p.FirstName,
			p.LastName
		from WorkshopTerms as wt
			left join Workshops as w
				on w.WorkshopID = wt.WorkshopID
			left join WorkshopBookings as wb
				on wb.WorkshopTermID = wt.WorkshopTermID
			left join WorkshopBookingDetails as wbd
				on wb.WorkshopBookingID = wbd.WorkshopBookingID
			left join Participants as p
				on p.ParticipantID = wbd.ParticipantID;
go
