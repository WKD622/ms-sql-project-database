-- Czy da się zrobić rezerwację na warsztat w niezarezerwowany dzień.

begin try
	declare @dayIdCorrect int;
	declare @dayIdIncorrect int;
	declare @conferenceID int;
	declare @customerID int;
	declare @bookingID int;
	declare @dayBookingID int;
	declare @workshopID int;
	declare @workshopTermID int;
	
	--dodanie osoby 
	exec dbo.addPerson 'firstname1', 'lastname1', 'adress1', '123456789', 'person1@gmail.com', 'person1log', 0x00;
	--dodanie konferencji
	exec dbo.addConference 'conf1', 100, '2018-02-10', '2018-02-17', 100, 0.2;
	--dodanie warsztatu
	exec dbo.addWorkshop 'workshop1', 'description1';
	
	select @workshopID = dbo.getWorkshopForName 'workshop1'
	select @conferenceID = dbo.getConferenceForName 'conf1'
	select @dayIdCorrect = dbo.getDayForDate @conferenceID, '2018-02-10'
	select @dayIdIncorrect = dbo.getDayForDate @conferenceID, '2018-02-11'
	select @customerID = dbo.getCustomerForLogin 'person1log'
	
	--dodanie instancji warsztatu 
	exec dbo.addWorkshopTerm @workshopID, @dayIdCorrect, 50, '10:00', '12:00', 20, @workshopTermID output;
	
	--dodaje booking
	exec dbo.addBooking @customerID, @bookingID output;
	
	--dodaje dayBooking 
	exec dbo.addDayBooking @bookingID, @dayIdCorrect, @dayBookingID output;
	
	--dodaje workshopbooking na zly dzien - powinno nie działać
	exec dbo.addWorkshopBooking @dayIdIncorrect, @workshopTermID;
	
	raiserror('FAILED 50', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 50';
end catch