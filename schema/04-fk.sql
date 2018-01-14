/*
 * Moduł przechowujący klucze obce do tabel.
 * 
 * @author Kamil Jarosz
 * @author Jakub Ziarko
 */

--- Persons.CustomerID <-> Customers.CustomerID
alter table Persons
	add constraint FK_Persons_Customers
	foreign key (CustomerID)
	references Customers (CustomerID);

--- Companies.CustomerID <-> Customers.CustomerID
alter table Companies
	add constraint FK_Companies_Customers
	foreign key (CustomerID)
	references Customers (CustomerID);

--- CompanyParticipants.CustomerID <-> Companies.CustomerID
alter table CompanyParticipants
	add constraint FK_CompanyParticipants_Companies
	foreign key (CompanyID)
	references Companies (CustomerID);

--- ConferenceDays.ConferenceID <-> Conferences.ConferenceID
alter table ConferenceDays
	add constraint FK_ConferenceDays_Conferences
	foreign key (ConferenceID)
	references Conferences (ConferenceID);

--- WorkshopTerms.WorkshopID <-> Workshops.WorkshopID
alter table WorkshopTerms
	add constraint FK_WorkshopTerms_Workshops
	foreign key (WorkshopID)
	references Workshops (WorkshopID);

--- WorkshopTerms.DayID <-> ConferenceDays.ConferenceDayID
alter table WorkshopTerms
	add constraint FK_WorkshopTerms_ConferenceDays
	foreign key (DayID)
	references ConferenceDays (ConferenceDayID);

--- Persons.ParticipantID <-> Participants.ParticipantID
alter table Persons
	add constraint FK_Persons_Participants
	foreign key (ParticipantID)
	references Participants (ParticipantID);

--- CompanyParticipants.ParticipantID <-> Participants.ParticipantID
alter table CompanyParticipants
	add constraint FK_CompanyParticipants_Participants
	foreign key (ParticipantID)
	references Participants (ParticipantID);

--- WorkshopBookingDetails.ParticipantID <-> Participants.ParticipantID
alter table WorkshopBookingDetails
	add constraint FK_WorkshopBookingDetails_Participants
	foreign key (ParticipantID)
	references Participants (ParticipantID);

--- WorkshopBookingDetails.WorkshopBookingID <-> WorkshopBookings.WorkshopBookingID
alter table WorkshopBookingDetails
	add constraint FK_WorkshopBookingDetails_WorkshopBookings
	foreign key (WorkshopBookingID)
	references WorkshopBookings (WorkshopBookingID);

--- WorkshopBookings.WorkshopTermID <-> WorkshopTerms.WorkshopTermID
alter table WorkshopBookings
	add constraint FK_WorkshopBookings_WorkshopTerms
	foreign key (WorkshopTermID)
	references WorkshopTerms (WorkshopTermID);

--- DayBookingDetails.DayBookingID <-> DayBookings.DayBookingID
alter table DayBookingDetails
	add constraint FK_DayBookingDetails_DayBookings
	foreign key (DayBookingID)
	references DayBookings (DayBookingID);

--- DayBookingDetails.ParticipantID <-> Participants.ParticipantID
alter table DayBookingDetails
	add constraint FK_DayBookingDetails_Participants
	foreign key (ParticipantID)
	references Participants (ParticipantID);

--- Prices.ConferenceID <-> Conferences.ConferenceID
alter table Prices
	add constraint FK_Prices_Conferences
	foreign key (ConferenceID)
	references Conferences (ConferenceID);

--- WorkshopBookings.DayBookingID <-> DayBookings.DayBookingID
alter table WorkshopBookings
	add constraint FK_WorkshopBookings_DayBookings
	foreign key (DayBookingID)
	references DayBookings (DayBookingID);

--- StudentIDs.ParticipantID <-> Participants.ParticipantID
alter table StudentIDs
	add constraint FK_StudentIDs_Participants
	foreign key (ParticipantID)
	references Participants (ParticipantID);

--- DayBookings.BookingID <-> Bookings.BookingID
alter table DayBookings
	add constraint FK_DayBookings_Bookings
	foreign key (BookingID)
	references Bookings (BookingID);

--- BookingStudentIDs.DayBookingID <-> DayBookings.DayBookingID
alter table BookingStudentIDs
	add constraint FK_BookingStudentIDs_DayBookings
	foreign key (DayBookingID)
	references DayBookings (DayBookingID);

--- Bookings.CustomerID <-> Customers.CustomerID
alter table Bookings
	add constraint FK_Bookings_Customers
	foreign key (CustomerID)
	references Customers (CustomerID);

--- DayBookings.ConferenceDayID <-> ConferenceDays.ConferenceDayID
alter table DayBookings
	add constraint FK_DayBookings_ConferenceDays
	foreign key (ConferenceDayID)
	references ConferenceDays (ConferenceDayID);
