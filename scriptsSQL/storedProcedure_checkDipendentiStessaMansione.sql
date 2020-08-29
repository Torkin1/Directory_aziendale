-- Se i due dipendenti in input svolgono la stessa mansione restituisce la mansione svolta, altrimenti segnala un errore

CREATE PROCEDURE `checkDipendentiStessaMansione` (
 in cfDipendente1 char(16),
 in cfDipendente2 char(16),
 out nomeMansione varchar(45),
 out nomeSettore varchar(45)
 )
BEGIN
	select u1.NomeMansione, u1.NomeSettore
		from DIPENDENTE as d1 join POSTAZIONE as p1 on d1.NumTelefonicoEsternoPostazione = p1.NumTelefonicoEsterno
            join UFFICIO_FISICO as u1 on p1.CodiceUfficio = u1.Codice
				and p1.NumPiano = u1.NumPiano
				and p1.IndirizzoEdificio = u1.IndirizzoEdificio
		where d1.CF = cfDipendente1
        and (u1.NomeMansione, u1.NomeSettore) = (
			select u2.NomeMansione, u2.NomeSettore
            from DIPENDENTE as d2 join POSTAZIONE as p2 on d2.NumTelefonicoEsternoPostazione = p2.NumTelefonicoEsterno 
				join UFFICIO_FISICO as u2 on p2.CodiceUfficio = u2.Codice
					and p2.NumPiano = u2.NumPiano
					and p2.IndirizzoEdificio = u2.IndirizzoEdificio
			where d2.CF = cfDipendente2
		) into nomeMansione, nomeSettore;
	if (tempNomeMansione is null and tempNomeSettore is null) 
		then signal sqlstate "45005" set message_text = "ERROR: Le postazioni occupate dai dipendenti forniti appartengono ad uffici fisici che sono attualmente assegnati a due mansioni diverse.";
    end if;
END