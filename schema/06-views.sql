/*
 * Moduł definiujący widoki.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

/**
 * Widok rezerwacji, które nie zostały zapłacone w terminie.
 */
create view UnpaidBookings as
	select * from Bookings
		where Paid = 0 and getdate() > DueDate;
go
