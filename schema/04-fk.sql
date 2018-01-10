/*
 * Moduł przechowujący klucze obce do tabel.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

--- Persons.CustomerID <-> Customers.CustomerID
alter table Persons
	add constraint FKPersons336560
	foreign key (CustomerID)
	references Customers (CustomerID);

--- Companies.CustomerID <-> Customers.CustomerID
alter table Companies
	add constraint FKCompanies259074
	foreign key (CustomerID)
	references Customers (CustomerID);

--- CompanyParticipants.CustomerID <-> Companies.CustomerID
alter table CompanyParticipants
	add constraint FKCompanyPar396925
	foreign key (CompanyID)
	references Companies (CustomerID);

--- ConferenceDays.ConferenceID <-> Conferences.ConferenceID
alter table ConferenceDays
	add constraint FKConference689988
	foreign key (ConferenceID)
	references Conferences (ConferenceID);

--- WorkshopTerms.WorkshopID <-> Workshops.WorkshopID
alter table WorkshopTerms
	add constraint FKWorkshopTe655363
	foreign key (WorkshopID)
	references Workshops (WorkshopID);

--- WorkshopTerms.DayID <-> ConferenceDays.ConferenceDayID
alter table WorkshopTerms
	add constraint FKWorkshopTe428820
	foreign key (DayID)
	references ConferenceDays (ConferenceDayID);

--- Persons.ParticipantID <-> Participants.ParticipantID
alter table Persons
	add constraint FKPersons422904
	foreign key (ParticipantID)
	references Participants (ParticipantID);

--- CompanyParticipants.ParticipantID <-> Participants.ParticipantID
alter table CompanyParticipants
	add constraint FKCompanyPar628077
	foreign key (ParticipantID)
	references Participants (ParticipantID);

--- WorkshopBookingDetails.ParticipantID <-> Participants.ParticipantID
alter table WorkshopBookingDetails
	add constraint FKWorkshopBo225545
	foreign key (ParticipantID)
	references Participants (ParticipantID);

--- WorkshopBookingDetails.WorkshopBookingID <-> WorkshopBookings.WorkshopBookingID
alter table WorkshopBookingDetails
	add constraint FKWorkshopBo133697
	foreign key (WorkshopBookingID)
	references WorkshopBookings (WorkshopBookingID);

--- WorkshopBookings.WorkshopTermID <-> WorkshopTerms.WorkshopTermID
alter table WorkshopBookings
	add constraint FKWorkshopBo238930
	foreign key (WorkshopTermID)
	references WorkshopTerms (WorkshopTermID);

--- DayBookingDetails.DayBookingID <-> DayBookings.DayBookingID
alter table DayBookingDetails
	add constraint FKDayBooking258140
	foreign key (DayBookingID)
	references DayBookings (DayBookingID);

--- DayBookingDetails.ParticipantID <-> Participants.ParticipantID
alter table DayBookingDetails
	add constraint FKDayBooking637424
	foreign key (ParticipantID)
	references Participants (ParticipantID);

--- Prices.ConferenceID <-> Conferences.ConferenceID
alter table Prices
	add constraint FKPrices192071
	foreign key (ConferenceID)
	references Conferences (ConferenceID);

--- WorkshopBookings.DayBookingID <-> DayBookings.DayBookingID
alter table WorkshopBookings
	add constraint FKWorkshopBo201789
	foreign key (DayBookingID)
	references DayBookings (DayBookingID);

--- StudentIDs.ParticipantID <-> Participants.ParticipantID
alter table StudentIDs
	add constraint FKStudentIDs613554
	foreign key (ParticipantID)
	references Participants (ParticipantID);

--- DayBookings.BookingID <-> Bookings.BookingID
alter table DayBookings
	add constraint FKDayBooking362799
	foreign key (BookingID)
	references Bookings (BookingID);

--- BookingStudentIDs.DayBookingID <-> DayBookings.DayBookingID
alter table BookingStudentIDs
	add constraint FKBookingStu301
	foreign key (DayBookingID)
	references DayBookings (DayBookingID);

--- Bookings.CustomerID <-> Customers.CustomerID
alter table Bookings
	add constraint FKBookings930718
	foreign key (CustomerID)
	references Customers (CustomerID);

--- DayBookings.ConferenceDayID <-> ConferenceDays.ConferenceDayID
alter table DayBookings
	add constraint FKDayBooking44781
	foreign key (ConferenceDayID)
	references ConferenceDays (ConferenceDayID);
