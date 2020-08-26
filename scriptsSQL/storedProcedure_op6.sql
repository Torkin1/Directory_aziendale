-- op 6

CREATE PROCEDURE `ricercaDipendente` (in nome varchar(45), in cognome varchar(45))
BEGIN
	select DIPENDENTE.Nome, DIPENDENTE.Cognome, DIPENDENTE.IndirizzoResidenza, DIPENDENTE.EmailPersonale, DIPENDENTE.NumTelefonicoEsternoPostazione, MANSIONE.EmailUfficio
    from DIPENDENTE left join POSTAZIONE on DIPENDENTE.NumTelefonicoEsternoPostazione = POSTAZIONE.NumTelefonicoEsterno
		left join UFFICIO_FISICO on POSTAZIONE.CodiceUfficio = UFFICIO_FISICO.Codice
			and POSTAZIONE.NumPiano = UFFICIO_FISICO.NumPiano
            and POSTAZIONE.IndirizzoEdificio = UFFICIO_FISICO.IndirizzoEdificio
		left join MANSIONE on UFFICIO_FISICO.NomeMansione = MANSIONE.Nome
			and UFFICIO_FISICO.NomeSettore = MANSIONE.NomeSettore
	where DIPENDENTE.Nome = nome
		or DIPENDENTE.Cognome = cognome;
END