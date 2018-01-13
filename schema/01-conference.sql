
create table Conferences (
	ConferenceID     int identity  not null,
	Name             varchar(255)  not null
		check (Name <> ''),
	Price            money         not null
		check (Price >= 0),
	StartDay         date          not null,
	EndDay           date          not null,
	ParticipantLimit int           null
		check (ParticipantLimit is null) or (ParticipantLimit > 0),
	StudentDiscout   decimal(3, 2) not null
		check (StudentDiscount >= 0 and StudentDiscount <= 1)
		default 0,
	primary key (ConferenceID),
	constraint StartEnd
		check (EndDay > StartDay)
);

create table ConferenceDays (
	ConferenceDayID int identity not null,
	ConferenceID    int          not null,
	Day             date         not null,
	primary key (ConferenceDayID)
);

create table Workshops (
	WorkshopID  int identity not null,
	Name        varchar(255) not null
		check (Name <> ''),
	Description varchar(255) null
		check (Description is null or Description <> ''),
	primary key (WorkshopID)

	
);

create table WorkshopTerms (
	WorkshopTermID int identity not null,
	WorkshopID     int          not null,
	DayID          int          not null,
	Price          money        not null
		check (Price >= 0),
	StartTime      time         not null,
	EndTime        time         not null,
	Capacity       int          null
		check (Capacity is null or Capacity > 0),
	primary key (WorkshopTermID),
	constraint CK_WorkshopTerms_StartEnd
		check (EndTime > StartTime)
);

create table Prices (
	PriceID      int identity  not null,
	ConferenceID int           not null,
	DueDate      date          not null,
	Discount     decimal(3, 2) not null
		check (Discount >= 0 and Discount <= 1),
	primary key (PriceID)
);
