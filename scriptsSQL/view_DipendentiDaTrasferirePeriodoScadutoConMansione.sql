-- Elenca tutti i dipendenti di cui il periodo di turnazione è decorso con la loro attuale mansione.
-- Si assume che il periodo di turnazione dei dipendenti sia di 30 giorni.

CREATE VIEW `dipendentiDaTrasferirePeriodoScadutoConMansione` AS
	select DIPENDENTE.CF as CFDipendente, UFFICIO_FISICO.NomeMansione, UFFICIO_FISICO.NomeSettore 
	from DIPENDENTE join POSTAZIONE join UFFICIO_FISICO 
		on DIPENDENTE.NumTelefonicoEsternoPostazione = POSTAZIONE.NumTelefonicoEsterno 
		and POSTAZIONE.NumUfficio = UFFICIO_FISICO.Numero
        and POSTAZIONE.NumPiano = UFFICIO_FISICO.NumPiano
        and POSTAZIONE.IndirizzoEdificio = UFFICIO_FISICO.IndirizzoEdificio
    where datediff(DIPENDENTE.DataUltimoTrasferimento, current_date) > 30