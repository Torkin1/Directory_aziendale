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
	start transaction;
    -- controlla se le due postazioni appartengono ad uffici fisici assegnati alla stessa mansione e settore, che verranno salvati dentro delle variabili
    call checkDipendentiStessaMansione(cfDipendente1, cfDipendente2, tempNomeMansione, tempNomeSettore);
	if (tempNomeMansione is null and tempNomeSettore is null) 
		then signal sqlstate "45005" set message_text = "ERROR: Le postazioni occupate dai dipendenti forniti appartengono ad uffici fisici che sono attualmente assegnati a due mansioni diverse.";
    end if;
    -- scambia i dipendenti e aggiorna la tabella TRASFERITO_A atomicamente
	set tempNumeroTelefonico1 = (select NumTelefonicoEsternoPostazione from DIPENDENTE where CF = cfDipendente1);
	set tempNumeroTelefonico2 = (select NumTelefonicoEsternoPostazione from DIPENDENTE where CF = cfDipendente2);
    update DIPENDENTE set NumTelefonicoEsternoPostazione = null where CF = cfDipendente1;
	update DIPENDENTE set NumTelefonicoEsternoPostazione = null where CF = cfDipendente2;
    insert into TRASFERITO_A values (cfDipendente1, tempNumeroTelefonico2, curdate(), tempNomeMansione, tempNomeSettore);
    insert into TRASFERITO_A values (cfDipendente2, tempNumeroTelefonico1, curdate(), tempNomeMansione, tempNomeSettore);
	commit;
END