/*
 * Moduł definiujący widoki.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * widok rezerwacji, które nie zostały zapłacone w terminie, posortowane według terminu płatności
 */
create view UnpaidBookings as
	select * from Bookings
		where Paid = 0 and getdate() > DueDate
		order by DueDate;
