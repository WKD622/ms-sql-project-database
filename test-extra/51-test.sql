-- Sprawdza czy działa zapis uczestników dla firmy.

declare @dayID int;
declare @conferenceID int;
declare @customerID int;
declare @bookingID int;
declare @dayBookingID int;
declare @workshopID int;
declare @workshopTermID int;
declare @workshopTermID2 int;

exec dbo.addConference 'conf1', 4321, '2018-02-10', '2018-02-11', 100, 0.2;
exec dbo.addCompany 'company1', '1234567890', 'adress1', '123456789', 'person1@gmail.com', 'company1login', 0x00;
exec dbo.addWorkshop 'workshop1', 'description1';

select @workshopID = dbo.getWorkshopForName('workshop1');
select @conferenceID = dbo.getConferenceForName('conf1');
select @dayID = dbo.getDayForDate(@conferenceID, '2018-02-10');
select @customerID = dbo.getCustomerForLogin('company1login');

exec dbo.addWorkshopTerm @workshopID, @dayID, 50, '10:00', '12:00', 20, @workshopTermID output;
exec dbo.addWorkshopTerm @workshopID, @dayID, 50, '11:00', '13:00', 20, @workshopTermID2 output;

exec dbo.addBooking @customerID, @bookingID output;
exec dbo.addDayBooking @bookingID, @dayID, @dayBookingID output, 10;

-- Błąd
exec dbo.addWorkshopBooking @dayBookingID, @workshopTermID, 11;

exec dbo.addWorkshopBooking @dayBookingID, @workshopTermID, 10;
exec dbo.addWorkshopBooking @dayBookingID, @workshopTermID2, 5;
