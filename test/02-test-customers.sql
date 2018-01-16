-- Testy dla klientów.

-- Błąd: złe imię / nazwisko / adres / telefon
exec addPerson '', 'nazwisko', 'adres', 'telefon', 'person1@example.com', 'person1', 0x00;
exec addPerson 'imię', '', 'adres', 'telefon', 'person1@example.com', 'person1', 0x00;
exec addPerson 'imię', 'nazwisko', '', 'telefon', 'person1@example.com', 'person1', 0x00;
exec addPerson 'imię', 'nazwisko', 'adres', '', 'person1@example.com', 'person1', 0x00;

-- Błąd: zły email
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1', 'person1', 0x00;
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1@', 'person1', 0x00;
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1@com', 'person1', 0x00;

-- Błąd: zły nr legitymacji
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student1', 0x00, '12345';
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student1', 0x00, '12345a';
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student1', 0x00, '7123457';

-- Okej
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student1', 0x00, '123456';
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'person1@example.com', 'person1', 0x00;

-- Okej
declare @person1   int = dbo.getCustomerForLogin('person1');
declare @student1  int = dbo.getCustomerForLogin('student1');
declare @person1p  int = dbo.asParticipant(@person1);
declare @student1p int = dbo.asParticipant(@student1);

-- Powinno wypisać dwa razy 1
print dbo.isPerson(@person1);
print dbo.isPerson(@student1);

-- Powinno wypisać 0 oraz 1
print dbo.isStudent(@person1p);
print dbo.isStudent(@student1p);

-- Błąd: powtórzony login
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'email@example.com', 'student1', 0x00, '123457';

-- Błąd: powtórzony nr legitymacji
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'email@example.com', 'student2', 0x00, '123456';

-- Błąd: powtórzony email
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student2', 0x00, '123457';

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Błąd: zły nip
exec addCompany 'nazwa', '123456789', 'adres', 'telefon', 'company1@example.com', 'company1', 0x00;

-- Okej
exec addCompany 'nazwa', '1234567891', 'adres', 'telefon', 'company1@example.com', 'company1', 0x00;
declare @company1 int = dbo.getCustomerForLogin('company1');

-- Powinno wypisać 0
print dbo.isPerson(@company1);

-- Null: dla firmy nie działa
print dbo.asParticipant(@company1);
