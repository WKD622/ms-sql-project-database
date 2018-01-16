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
declare @person1  int = dbo.getCustomerForLogin('person1');
declare @student1 int = dbo.getCustomerForLogin('student1');

-- Powinno wypisać dwa razy 1
print dbo.isPerson(@person1);
print dbo.isPerson(@student1);

-- Błąd: powtórzony login
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'email@example.com', 'student1', 0x00, '123457';

-- Błąd: powtórzony nr legitymacji
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'email@example.com', 'student2', 0x00, '123456';

-- Błąd: powtórzony email
exec addPerson 'imię', 'nazwisko', 'adres', 'telefon', 'student1@example.com', 'student2', 0x00, '123457';

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
