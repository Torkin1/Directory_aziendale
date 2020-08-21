CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`TRASFERITO_A_BEFORE_INSERT`
BEFORE INSERT ON `directory_aziendale`.`TRASFERITO_A`
FOR EACH ROW
BEGIN
	if not (select CFDipendente from DA_TRASFERIRE_A where new.CFDipendente = DA_TRASFERIRE_A.CFDipendente)
		then signal sqlstate '45002' set message_text = "ERROR: Non è possibile registare un dipendente come trasferito se prima non è stato contrassegnato come da trasferire."; 
	elseif (select NumTelefonicoEsternoPostazione, `Data` 
			from TRASFERITO_A 
			where TRASFERITO_A.NumTelefonicoEsternoPostazione = new.NumTelefonicoEsternoPostazione 
				and TRASFERITO_A.CFDipendente = new.CFDipendente
                and timestampdiff(year, TRASFERITO_A.`Data`, curdate()) <= 3 
			)
		then signal sqlstate '45004' set message_text = "ERROR: Un dipendente non può essere trasferito a una postazione dove è stato già trasferito meno di tre anni fa";
    else
		delete from DA_TRASFERIRE_A where new.CFDipendente = DA_TRASFERIRE_A.CFDipendente;
    end if;
END