-- op 9

CREATE PROCEDURE `assumiDipendente` (
    in cf char(16),
    in nome varchar(45),
    in cognome varchar(45),
    in luogoNascita varchar(45),
    in dataNascita date,
    in emailPersonale varchar(45),
    in indirizzoResidenza varchar(45),
    in nomeMansione varchar(45),
    in nomeSettore varchar(45)
)
BEGIN
	-- on any error performs a rollback, then resignals to caller
    declare exit handler for sqlexception
    begin
		rollback;
        resignal;
	end;
    -- performs op 9 atomically
    start transaction;
    insert into DIPENDENTE
		values (
			cf,
            nome,
            cognome,
            luogoNascita,
            dataNascita,
            emailPersonale,
            indirizzoResidenza,
            null,
            null
        );
	insert into DA_TRASFERIRE_A
		values (
			cf,
            nomeMansione,
            nomeSettore
        );
    commit;
END