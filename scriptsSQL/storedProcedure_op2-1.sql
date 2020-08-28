-- op 2-1

CREATE PROCEDURE `trovaDipendentiScambiabili` (in cfDipendente char(16))
BEGIN
    select d1.NumTelefonicoEsternoPostazione as possibilePostazioneDaScambiare,
        d1.CF as cfDipendenteOccupante
    from DIPENDENTE as d1
		join POSTAZIONE as p1 on d1.NumTelefonicoEsternoPostazione = p1.NumTelefonicoesterno
        join UFFICIO_FISICO as u1 on p1.CodiceUfficio = u1.Codice
			and p1.NumPiano = u1.NumPiano
            and p1.IndirizzoEdificio = u1.IndirizzoEdificio
	where d1.CF != cfDipendente
		and (u1.NomeMansione, u1.NomeSettore) in (
			select NomeMansione, NomeSettore
			from DIPENDENTE as d2 join POSTAZIONE as p2 on d2.NumTelefonicoEsternoPostazione = p2.NumTelefonicoesterno
				join UFFICIO_FISICO as u2 on p2.CodiceUfficio = u2.Codice
					and p2.NumPiano = u2.NumPiano
					and p2.IndirizzoEdificio = u2.IndirizzoEdificio
			where d2.CF = cfDipendente
		)
	);		
END