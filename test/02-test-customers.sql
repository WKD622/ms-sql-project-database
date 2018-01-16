-- Testy dla klientów.

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: złe imię
	exec addPerson '', 'nazwisko', 'adres', 'telefon', 'person1@example.com', 'person1', 0x00;
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 1';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: złe nazwisko
	exec addPerson 'imię', '', 'adres', 'telefon', 'person1@example.com', 'person1', 0x00;
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły adres
	exec addPerson 'imię', 'nazwisko', '', 'telefon', 'person1@example.com', 'person1', 0x00;
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły telefon
	exec addPerson 'imię', 'nazwisko', 'adres', '', 'person1@example.com', 'person1', 0x00;
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 2';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły email
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1', 'person1', 0x00;
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły email
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1@', 'person1', 0x00;
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły email
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1@com', 'person1', 0x00;
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 3';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły nr legitymacji
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student1', 0x00, '12345';
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły nr legitymacji
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student1', 0x00, '12345a';
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły nr legitymacji
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student1', 0x00, '7123457';
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 4';
end catch

---------------------------------------------------------------------------------------------------

-- Okej
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1@example.com', 'person1', 0x00;
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student1', 0x00, '123456';

print 'PASSED';

-- Okej
declare @person1   int = dbo.getCustomerForLogin('person1');
declare @student1  int = dbo.getCustomerForLogin('student1');
declare @person1p  int = dbo.asParticipant(@person1);
declare @student1p int = dbo.asParticipant(@student1);

---------------------------------------------------------------------------------------------------

-- Powinno wypisać dwa razy 1
if
	dbo.isPerson(@person1) <> 1 or
	dbo.isPerson(@student1) <> 1
begin raiserror('FAILED', 9, 0); return; end
else print 'PASSED';

-- Powinno wypisać 0 oraz 1
if
	dbo.isStudent(@person1p) <> 0 or
	dbo.isStudent(@student1p) <> 1
begin raiserror('FAILED', 9, 0); return; end
else print 'PASSED';

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: powtórzony login
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'email@example.com', 'student1', 0x00, '123457';
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 5';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: powtórzony nr legitymacji
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'email@example.com', 'student2', 0x00, '123456';
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: powtórzony email
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student2', 0x00, '123457';
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 6';
end catch

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły nip
	exec addCompany 'nazwa', '123456789', 'adres', 'telefon', 'company1@example.com', 'company1', 0x00;
	
	raiserror('FAILED', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

-- Okej
exec addCompany 'nazwa', '1234567891', 'adres', 'telefon', 'company1@example.com', 'company1', 0x00;
declare @company1 int = dbo.getCustomerForLogin('company1');

-- Powinno wypisać 0
if
	dbo.isPerson(@company1) <> 0
begin raiserror('FAILED', 9, 0); return; end
else print 'PASSED 2 7';

-- Null: dla firmy nie działa
if
	dbo.asParticipant(@company1) <> null
begin raiserror('FAILED', 9, 0); return; end
else print 'PASSED';
