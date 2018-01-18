-- Testy dla klientów.

-- Wyjście: --

-- Student
--     login: student1
-- Osoba
--     login: person1
-- Firma
--     login: company1

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: złe imię
	exec addPerson '', 'nazwisko', 'adres', 'telefon', 'person1@example.com', 'person1', 0x00;
	
	raiserror('FAILED 2 0', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 1';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: złe nazwisko
	exec addPerson 'imię', '', 'adres', 'telefon', 'person1@example.com', 'person1', 0x00;
	
	raiserror('FAILED 2 1', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły adres
	exec addPerson 'imię', 'nazwisko', '', 'telefon', 'person1@example.com', 'person1', 0x00;
	
	raiserror('FAILED 2 2', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły telefon
	exec addPerson 'imię', 'nazwisko', 'adres', '', 'person1@example.com', 'person1', 0x00;
	
	raiserror('FAILED 2 3', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 2';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły telefon
	exec addPerson 'imię', 'nazwisko', 'adres', '6012a5678', 'person1@example.com', 'person1', 0x00;
	
	raiserror('FAILED 2 4', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 2';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły email
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1', 'person1', 0x00;
	
	raiserror('FAILED 2 5', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły email
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1@', 'person1', 0x00;
	
	raiserror('FAILED 2 6', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły email
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1@com', 'person1', 0x00;
	
	raiserror('FAILED 2 7', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 3';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły nr legitymacji
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student1', 0x00, '12345';
	
	raiserror('FAILED 2 8', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły nr legitymacji
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student1', 0x00, '12345a';
	
	raiserror('FAILED 2 9', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
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
begin raiserror('FAILED 2 10', 9, 0); return; end
else print 'PASSED';

-- Powinno wypisać 0 oraz 1
if
	dbo.isStudent(@person1p) <> 0 or
	dbo.isStudent(@student1p) <> 1
begin raiserror('FAILED 2 11', 9, 0); return; end
else print 'PASSED';

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: powtórzony login
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'email@example.com', 'student1', 0x00, '123457';
	
	raiserror('FAILED 2 12', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 5';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: powtórzony nr legitymacji
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'email@example.com', 'student2', 0x00, '123456';
	
	raiserror('FAILED 2 13', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: powtórzony email
	exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student2', 0x00, '123457';
	
	raiserror('FAILED 2 14', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED 2 6';
end catch

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--Okej
	exec addCompany 'nazwa', '0123456789', 'adres', 'telefon', 'company1@example.com', 'company1', 0x00;
	
--------------------------------------------------------------------------------------------------- 
begin try
	-- Błąd: zły nip
	exec addCompany 'nazwa', '123456789', 'adres', 'telefon', 'company1@example.com', 'company1', 0x00;
	
	raiserror('FAILED 2 15', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zła nazwa
	exec addCompany '', '01234567890', 'adres', 'telefon', 'company1@example.com', 'company1', 0x00;
	
	raiserror('FAILED 2 16', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły telefon
	exec addCompany 'nazwa', '0123456789', 'adres', '', 'company1@example.com', 'company1', 0x00;
	
	raiserror('FAILED 2 17', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły email
	exec addCompany 'nazwa', '0123456789', 'adres', 'telefon', 'company1', 'company1', 0x00;
	
	raiserror('FAILED 2 18', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły email
	exec addCompany 'nazwa', '0123456789', 'adres', 'telefon', 'company1@', 'company1', 0x00;
	
	raiserror('FAILED 2 19', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: zły email
	exec addCompany 'nazwa', '0123456789', 'adres', 'telefon', 'company1@com', 'company1', 0x00;
	
	raiserror('FAILED 2 20', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

begin try
	-- Błąd: za krótki login
	exec addCompany 'nazwa', '0123456789', 'adres', 'telefon', 'company1@example.com', 'com', 0x00;
	
	raiserror('FAILED 2 21', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

	
---------------------------------------------------------------------------------------------------

	begin try
	-- Błąd: powtórzony login 
	exec addCompany 'nazwa', '0123456789', 'adres', 'telefon', 'company1@example2.com', 'company1', 0x00;
	
	raiserror('FAILED 2 22', 9, 0); return;
end try begin catch
	while @@trancount > 0 rollback
	print 'PASSED';
end catch

---------------------------------------------------------------------------------------------------

	begin try
	-- Błąd: powtórzony email
	exec addCompany 'nazwa', '0123456789', 'adres', 'telefon', 'company1@example2.com', 'company2', 0x00;
	
	raiserror('FAILED 2 23', 9, 0); return;
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
begin raiserror('FAILED 2 16', 9, 0); return; end
else print 'PASSED 2 24';

-- Null: dla firmy nie działa
if
	dbo.asParticipant(@company1) <> null
begin raiserror('FAILED 2 25', 9, 0); return; end
else print 'PASSED';
