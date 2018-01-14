/*
 * Moduł definiujący widoki.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

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
 */
create view UnpaidBookings as
	select
			BookingID,
			BookingDate,
			DueDate,
			PaymentDate,
			(datediff(day, getdate(), DueDate)) as Delay
		from Bookings
		where PaymentDate is null and getdate() > DueDate;
go
