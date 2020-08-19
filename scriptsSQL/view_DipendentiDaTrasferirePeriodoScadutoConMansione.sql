-- Elenca tutti i dipendenti di cui il periodo di turnazione è decorso con la loro attuale mansione.
-- Si assume che il periodo di turnazione dei dipendenti sia di 30 giorni.

CREATE VIEW `dipendentiDaTrasferirePeriodoScadutoConMansione` AS
	select DIPENDENTE.CF as CFDipendente, UFFICIO.NomeMansione, UFFICIO.NomeSettore 
	from DIPENDENTE join POSTAZIONE join UFFICIO 
		on DIPENDENTE.NumTelefonicoEsternoPostazione = POSTAZIONE.NumTelefonicoEsterno 
		and POSTAZIONE.EmailUfficio = UFFICIO.Email
    where datediff(DIPENDENTE.DataUltimoTrasferimento, current_date) > 30