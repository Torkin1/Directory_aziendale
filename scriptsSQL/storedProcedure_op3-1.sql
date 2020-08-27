-- op 3-1. Passando dei valori null ai parametri è possibile trovare tutti gli uffici con postazione vuota a prescindere dalla mansione che svolgono

CREATE PROCEDURE `trovaUfficiConPostazioneVuota` (in nomeMansione varchar(45), in nomeSettore varchar(45))
BEGIN
	select POSTAZIONE.NumTelefonicoEsterno, UFFICIO_FISICO.Codice, UFFICIO_FISICO.NumPiano, UFFICIO_FISICO.IndirizzoEdificio
    from UFFICIO_FISICO 
		join POSTAZIONE on UFFICIO_FISICO.Codice = POSTAZIONE.CodiceUfficio
			and UFFICIO_FISICO.NumPiano = POSTAZIONE.NumPiano
            and UFFICIO_FISICO.IndirizzoEdificio = POSTAZIONE.IndirizzoEdificio
		left join DIPENDENTE on POSTAZIONE.NumTelefonicoEsterno = DIPENDENTE.NumTelefonicoEsternoPostazione
	where DIPENDENTE.CF is null
		and (UFFICIO_FISICO.NomeMansione = "calcolo bilancio" or nomeMansione is null)
        and (UFFICIO_FISICO.NomeSettore = "contabilità" or nomeSettore is null);
END