-- Testy dla składania zamówień.

-- Student składa zamówienie
declare @bstudent int;
exec addBooking @student1, @bstudent;

declare @bstudent_d1 int;
-- Wybiera pierwszy dzień
exec addDayBooking @bstudent, @dayID1, @bstudent_d1;

-- Błąd: nie może zapisać się na warsztat z drugiego dnia
exec addWorkshopBooking @bstudent_d1, @term2_13_15;

-- Błąd: nie może zapisać wielu uczestników
exec addWorkshopBooking @bstudent_d1, @term1_13_15, 4;

-- Okej
exec addWorkshopBooking @bstudent_d1, @term1_13_15;

-- Błąd: zachodzący warsztat
exec addWorkshopBooking @bstudent_d1, @term2_12_14;
