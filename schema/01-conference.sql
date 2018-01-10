
create table Conferences (
	ConferenceID     int identity  not null,
	Name             varchar(255)  not null,
	Price            money         not null,
	StartDay         date          not null,
	EndDay           date          not null,
	ParticipantLimit int           null,
	StudentDiscout   decimal(3, 2) not null,
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
	Name        varchar(255) not null,
	Description varchar(255) null,
	primary key (WorkshopID)
);

create table WorkshopTerms (
	WorkshopTermID int identity not null,
	WorkshopID     int          not null,
	DayID          int          not null,
	Price          money        not null,
	StartTime      time         not null,
	EndTime        time         not null,
	Capacity       int          null,
	primary key (WorkshopTermID),
	constraint CK_WorkshopTerms_StartEnd
		check (EndTime > StartTime)
);

create table Prices (
	PriceID      int identity  not null,
	ConferenceID int           not null,
	DueDate      date          not null,
	Discount     decimal(3, 2) not null,
	primary key (PriceID)
);
