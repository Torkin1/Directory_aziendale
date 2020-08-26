-- op 7

CREATE PROCEDURE `ricercaPerNumeroTelefono` (in numTelefono varchar(45))
BEGIN
	select UFFICIO_FISICO.Codice as CodiceUfficio, UFFICIO_FISICO.NumPiano, UFFICIO_FISICO.IndirizzoEdificio, DIPENDENTE.CF as CFDipendente, DIPENDENTE.Nome as NomeDipendente, DIPENDENTE.Cognome as CognomeDipendente, DA_TRASFERIRE_A.NomeMansione as NomeMansioneInTrasferimentoA, DA_TRASFERIRE_A.NomeSettore as NomeSettoreInTrasferimentoA
    from POSTAZIONE join UFFICIO_FISICO on POSTAZIONE.CodiceUfficio = UFFICIO_FISICO.Codice
			and POSTAZIONE.NumPiano = UFFICIO_FISICO.NumPiano
			and POSTAZIONE.IndirizzoEdificio = UFFICIO_FISICO.IndirizzoEdificio
        left join DIPENDENTE on DIPENDENTE.NumTelefonicoEsternoPostazione = numTelefono
        left join DA_TRASFERIRE_A on DIPENDENTE.CF = DA_TRASFERIRE_A.CFDipendente
	where POSTAZIONE.NumTelefonicoEsterno = numTelefono;
END