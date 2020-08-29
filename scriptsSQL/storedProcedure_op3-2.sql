-- op 3-2

CREATE PROCEDURE `assegnaDipendenteAPostazioneVuota` (in cfDipendente char(16), in numTelefonicoEsternoPostazione varchar(45))
BEGIN
	declare nomeMansione varchar(45);
    declare nomeSettore varchar(45);
    -- if an error occurs a rollback is performed and the error is resignaled to the caller
    declare exit handler for sqlexception
    begin
		rollback;
        resignal;
	end;
    -- checks if the provided seat is empty, raises a signal otherwise
    if (select DIPENDENTE.CF
		from DIPENDENTE
        where DIPENDENTE.NumTelefonicoEsternoPostazione = numTelefonicoEsternoPostazione
    ) is not null 
		then signal sqlstate '45002' set message_text = "ERROR: provided seat is not empty";
	end if;
    start transaction;
    -- checks if the job which the provided employer is to be transferred and the job assigned to the physical office containing the provided seat are the same, raises an error otherwise
    call getMansioneDaPostazioneSeCorrispondeADaTrasferireA(cfDipendente, numTelefonicoEsternoPostazione, nomeMansione, nomeSettore);
	if nomeMansione is null and nomeSettore is null
		then signal sqlstate '45006' set message_text = "ERROR: provided employer is not registered to be transferred to the job assigned to the physical office which contains the seat";
    end if;
    -- assigns the provided employer to the provided seat 
    insert into TRASFERITO_A values (cfDipendente, nomeMansione, nomesettore);
END