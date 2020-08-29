-- returns NomeMansione, NomeSettore of the job assigned to the office which contains the provided seat only if the job which the provided employer is to be transferred and the job assigned to the physical office containing the provided seat are the same

CREATE PROCEDURE `getMansioneDaPostazioneSeCorrispondeADaTrasferireA` (
	in cfDipendente char(16),
    in numTelefonicoEsternoPostazione varchar(45), 
	out nomeMansione varchar(45), 
	out nomeSettore varchar(45)
)
BEGIN
	select DA_TRASFERIRE_A.NomeMansione, DA_TRASFERIRE_A.NomeSettore
	from DIPENDENTE
		left join DA_TRASFERIRE_A on DIPENDENTE.CF = DA_TRASFERIRE_A.CFDipendente
		left join UFFICIO_FISICO on DA_TRASFERIRE_A.NomeMansione = UFFICIO_FISICO.NomeMansione
			and DA_TRASFERIRE_A.NomeSettore = UFFICIO_FISICO.NomeSettore
		left join POSTAZIONE on UFFICIO_FISICO.Codice = POSTAZIONE.CodiceUfficio
			and UFFICIO_FISICO.NumPiano = POSTAZIONE.NumPiano
			and UFFICIO_FISICO.IndirizzoEdificio = POSTAZIONE.IndirizzoEdificio
	where POSTAZIONE.NumTelefonicoEsterno = numTelefonicoEsterno
		and DIPENDENTE.CF = cfDipendente
		and DA_TRASFERIRE_A.NomeMansione = UFFICIO_FISICO.NomeMansione
		and DA_TRASFERIRE_A.NomeSettore = UFFICIO_FISICO.NomeSettore
	into nomeMansione, nomeSettore;
END