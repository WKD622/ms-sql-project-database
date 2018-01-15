-- Testy dla konferencji.

-- Błąd: zła nazwa
exec addConference '', 1000, '2018-05-01', '2018-05-02', 2, 0.2;

-- Błąd: zła kolejność dat
exec addConference 'conference1', 1000, '2018-05-02', '2018-05-01', 2, 0.2;

-- Błąd: zła wartość zniżki
exec addConference 'conference2', 1000, '2018-05-01', '2018-05-02', 2, 1.2;

-- Błąd: zła wartość ceny
exec addConference 'conference3', -15, '2018-05-01', '2018-05-02', 2, 0.2;

-- Błąd: zły limit
exec addConference 'conference4', 1000, '2018-05-01', '2018-05-02', -2, 0.2;

-- Błąd: limit zerowy
exec addConference 'conference5', 1000, '2018-05-01', '2018-05-02', 0, 0.2;

-- Okej: darmowa konferencja
exec addConference 'conference6', 0, '2018-05-01', '2018-05-02', 2, 0.2;

-- Okej: brak limitu miejsc
exec addConference 'conference7', 0, '2018-05-01', '2018-05-02', null, 0.2;

-- Błąd: powtórzona nazwa
exec addConference 'conference7', 0, '2018-05-01', '2018-05-02', 2, 0.2;

-- Stwórz konferencję
--     nazwa: conference
--     cena za dzień: 1000
--     od: 2018-05-01
--     do: 2018-05-02
exec addConference 'conference', 1000, '2018-05-01', '2018-05-02', 2, 0.2;

-- Pobierz ID konferencji
declare @confereceID int = dbo.getConferenceForName('conference');

-- Błąd: zła nazwa
exec addWorkshop '', '';

-- Błąd: zły opis
exec addWorkshop 'workshop1', '';

-- Okej: opis jest opcjonalny
exec addWorkshop 'workshop2', null;

-- Błąd: powtórzona nazwa
exec addWorkshop 'workshop2', null;

-- Stwórz warsztat
exec addWorkshop 'workshop', 'description';

-- Pobierz ID warsztatu
declare @workshopID int = dbo.getWorkshopForName('workshop');



