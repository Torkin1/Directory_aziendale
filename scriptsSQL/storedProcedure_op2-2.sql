-- op 2-2

CREATE PROCEDURE `scambiaDipendenti` (
	in cfDipendente1 char(16), 
	in cfDipendente2 char(16)
)
BEGIN
    declare tempNumeroTelefonico1 varchar(45);
	declare tempNumeroTelefonico2 varchar(45);
    declare tempNomeMansione varchar(45);
    declare tempNomeSettore varchar(45);
    declare exit handler for sqlexception
    begin
		rollback;
        resignal;
	end;
    -- controlla se le due postazioni appartengono ad uffici fisici assegnati alla stessa mansione e settore, che verranno salvati dentro delle variabili
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
		) into tempNomeMansione, tempNomeSettore;
	if (tempNomeMansione is null and tempNomeSettore is null) 
		then signal sqlstate "45005" set message_text = "ERROR: Le postazioni occupate dai dipendenti forniti appartengono ad uffici fisici che sono attualmente assegnati a due mansioni diverse.";
    end if;
    -- scambia i dipendenti e aggiorna la tabella TRASFERITO_A atomicamente
    start transaction;
	set tempNumeroTelefonico1 = (select NumTelefonicoEsternoPostazione from DIPENDENTE where CF = cfDipendente1);
	set tempNumeroTelefonico2 = (select NumTelefonicoEsternoPostazione from DIPENDENTE where CF = cfDipendente2);
    update DIPENDENTE set NumTelefonicoEsternoPostazione = null where CF = cfDipendente1;
	update DIPENDENTE set NumTelefonicoEsternoPostazione = null where CF = cfDipendente2;
    insert into TRASFERITO_A values (cfDipendente1, tempNumeroTelefonico2, curdate(), tempNomeMansione, tempNomeSettore);
    insert into TRASFERITO_A values (cfDipendente2, tempNumeroTelefonico1, curdate(), tempNomeMansione, tempNomeSettore);
	commit;
END