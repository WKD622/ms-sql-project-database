-- Testy dla konferencji i warsztatów.

begin try
	-- Błąd: zła nazwa
	exec addConference '', 1000, '2018-05-01', '2018-05-02', 10, 0.2;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zła kolejność dat
	exec addConference 'conference1', 1000, '2018-05-02', '2018-05-01', 10, 0.2;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zła wartość zniżki
	exec addConference 'conference2', 1000, '2018-05-01', '2018-05-02', 10, 1.2;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zła wartość ceny
	exec addConference 'conference3', -15, '2018-05-01', '2018-05-02', 10, 0.2;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły limit
	exec addConference 'conference4', 1000, '2018-05-01', '2018-05-02', -10, 0.2;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: limit zerowy
	exec addConference 'conference5', 1000, '2018-05-01', '2018-05-02', 0, 0.2;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

-- Okej: darmowa konferencja
exec addConference 'conference6', 0, '2018-05-01', '2018-05-02', 10, 0.2;

---------------------------------------------------------------------------------------------------

-- Okej: brak limitu miejsc
exec addConference 'conference7', 0, '2018-05-01', '2018-05-02', null, 0.2;

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: powtórzona nazwa
	exec addConference 'conference7', 0, '2018-05-01', '2018-05-02', 10, 0.2;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

-- Stwórz konferencję
--     nazwa: conference
--     cena za dzień: 1000
--     od: 2018-05-01
--     do: 2018-05-02
--     na 10 ludzi na dzień
exec addConference 'conference', 1000, '2018-05-01', '2018-05-02', 10, 0.2;

---------------------------------------------------------------------------------------------------

-- Pobierz ID konferencji
declare @conferenceID int = dbo.getConferenceForName('conference');

---------------------------------------------------------------------------------------------------

-- Null: nie ma takiego dnia
if dbo.getDayForDate(@conferenceID, '2018-05-03') is not null
begin
	raiserror('FAILED', 18, 0)
end else begin
	while @@trancount > 0 rollback
	print 'PASSED';
end

---------------------------------------------------------------------------------------------------

-- Null: złe ID konferencji
if dbo.getDayForDate(1337, '2018-05-01') is not null
begin
	raiserror('FAILED', 18, 0)
end else begin
	while @@trancount > 0 rollback
	print 'PASSED';
end

---------------------------------------------------------------------------------------------------

-- Okej
declare @dayID1 int = dbo.getDayForDate(@conferenceID, '2018-05-01');
declare @dayID2 int = dbo.getDayForDate(@conferenceID, '2018-05-02');

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zła nazwa
	exec addWorkshop '', '';
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły opis
	exec addWorkshop 'workshop1', '';
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

-- Okej: opis jest opcjonalny
exec addWorkshop 'workshop2', null;

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: powtórzona nazwa
	exec addWorkshop 'workshop2', null;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

-- Stwórz warsztat
exec addWorkshop 'workshop', 'description';

---------------------------------------------------------------------------------------------------

-- Pobierz ID warsztatu
declare @workshopID int = dbo.getWorkshopForName('workshop');

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zła cena
	exec addWorkshopTerm @workshopID, @dayID1, -100, '12:00', '13:35', 10;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły zakres dat
	exec addWorkshopTerm @workshopID, @dayID1, 100, '12:00', '11:35', 10;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zła pojemnosć
	exec addWorkshopTerm @workshopID, @dayID1, 100, '12:00', '13:35', 0;
	
	raiserror('FAILED', 18, 0)
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

-- Okej: nieograniczona pojemność
exec addWorkshopTerm @workshopID, @dayID1, 100, '12:00', '13:35', null;

---------------------------------------------------------------------------------------------------

-- Okej: darmowy warsztat
exec addWorkshopTerm @workshopID, @dayID1, 0, '12:00', '13:35', 10;

---------------------------------------------------------------------------------------------------

-- Stwórz warsztat
--     w pierwszym dnu konferencji
--     cena: 100
--     12:00 -- 14:00
--     na 10 osób
-- etc.
declare @term1_12_14 int;
exec addWorkshopTerm @workshopID, @dayID1, 123, '12:00', '14:00', 10, @term1_12_14 output;

---------------------------------------------------------------------------------------------------

declare @term1_13_15 int;
exec addWorkshopTerm @workshopID, @dayID1, 456, '13:00', '15:00', 10, @term1_13_15 output;

---------------------------------------------------------------------------------------------------

declare @term2_12_14 int;
exec addWorkshopTerm @workshopID, @dayID2, 321, '12:00', '14:00', 10, @term1_12_14 output;

---------------------------------------------------------------------------------------------------

declare @term2_13_15 int;
exec addWorkshopTerm @workshopID, @dayID2, 654, '13:00', '15:00', 10, @term1_13_15 output;

---------------------------------------------------------------------------------------------------
