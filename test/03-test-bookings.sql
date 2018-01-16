-- Testy dla składania zamówień.

-- Student składa zamówienie
declare @bstudent int;
exec addBooking @student1, @bstudent output;

-- Wybiera pierwszy dzień
declare @bstudent_d1 int;
exec addDayBooking @bstudent, @dayID1, @bstudent_d1 output;

---------------------------------------------------------------------------------------------------

select * from dbo.generateInvoice(@bstudent);

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: nie może zapisać się na warsztat z drugiego dnia
	exec addWorkshopBooking @bstudent_d1, @term2_13_15;
	
	raiserror('FAILED 3 1', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 3 1';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: nie może zapisać wielu uczestników
	exec addWorkshopBooking @bstudent_d1, @term1_13_15, 4;
	
	raiserror('FAILED 3 2', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

-- Okej
exec addWorkshopBooking @bstudent_d1, @term1_13_15;

select * from dbo.generateInvoice(@bstudent);

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zachodzący warsztat
	exec addWorkshopBooking @bstudent_d1, @term2_12_14;
	
	raiserror('FAILED 3 3', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 3 2';
end catch

---------------------------------------------------------------------------------------------------
