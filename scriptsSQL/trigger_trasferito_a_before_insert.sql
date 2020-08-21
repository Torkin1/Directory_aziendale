-- Controlla che esista una tupla in DA_TRASFERIRE_A che corrisponda a quella che si vuole inserire in TRASFERITO_A. Se c'è, la cancella.
-- Controlla se un dipendente è stato trasferito alla stessa postazione nei passati 3 anni. Se è questo il caso, segnala un errore

CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`TRASFERITO_A_BEFORE_INSERT`
BEFORE INSERT ON `directory_aziendale`.`TRASFERITO_A`
FOR EACH ROW
BEGIN
	if (select CFDipendente from DA_TRASFERIRE_A where new.CFDipendente = DA_TRASFERIRE_A.CFDipendente) is not null
		then delete from DA_TRASFERIRE_A where new.CFDipendente = DA_TRASFERIRE_A.CFDipendente;
        end if;
	if (select NumTelefonicoEsternoPostazione 
		from TRASFERITO_A 
		where TRASFERITO_A.NumTelefonicoEsternoPostazione = new.NumTelefonicoEsternoPostazione 
			and TRASFERITO_A.CFDipendente = new.CFDipendente
			and timestampdiff(year, TRASFERITO_A.`Data`, curdate()) <= 3 
	) is not null
		then signal sqlstate '45004' set message_text = "ERROR: Un dipendente non può essere trasferito a una postazione dove è stato già trasferito meno di tre anni fa";
    end if;
END