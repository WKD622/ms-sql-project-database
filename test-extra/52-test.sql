-- Zachodzące na siebie warsztaty.

exec addConference 'test', 1000, '2018-01-01', '2018-01-02', 100, 0.2;
exec addPerson 'Kamil', 'Jarosz', 'adr', 'ph', 'emadil@agh.edu.pl', 'kjarosz', 0x00;
exec addWorkshop 'asdf', 'asdf';

declare @conf int = dbo.getConferenceForName('test');
declare @day int = dbo.getDayForDate(@conf, '2018-01-01');
declare @customer int = dbo.getCustomerForLogin('kjarosz');
declare @participant int = dbo.asParticipant(@customer);
declare @workshop int = dbo.getWorkshopForName('asdf');

declare @term1 int;
declare @term2 int;
declare @term3 int;
exec addWorkshopTerm @workshop, @day, 100, '10:00', '12:00', 10, @term1 output;
exec addWorkshopTerm @workshop, @day, 100, '11:00', '13:00', 10, @term2 output;
exec addWorkshopTerm @workshop, @day, 100, '13:00', '14:00', 10, @term3 output;

declare @bookingID int;
declare @dayBookingID int;

exec addBooking @customer, @bookingID output;
exec addDayBooking @bookingID, @day, @dayBookingID output;

exec addWorkshopBooking @dayBookingID, @term1;
exec addWorkshopBooking @dayBookingID, @term3;

-- Błąd
exec addWorkshopBooking @dayBookingID, @term2;

