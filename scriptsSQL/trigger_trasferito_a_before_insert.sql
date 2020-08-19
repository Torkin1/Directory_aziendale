-- Controlla che esista una tupla in DA_TRASFERIRE_A che corrisponda a quella che si vuole inserire in TRASFERITO_A. Se c'è, la cancella, altrimenti abortisce l'operazione

CREATE DEFINER = CURRENT_USER TRIGGER `directory_aziendale`.`TRASFERITO_A_BEFORE_INSERT` BEFORE INSERT ON `TRASFERITO_A` FOR EACH ROW
BEGIN
	if (select CFDipendente from DA_TRASFERIRE_A where new.CFDipendente = DA_TRASFERIRE_A.CFDipendente)
		then delete from DA_TRASFERIRE_A where new.CFDipendente = DA_TRASFERIRE_A.CFDipendente;
	else
		signal sqlstate '45002' set message_text = "ERROR: Non è possibile registare un dipendente come trasferito se prima non è stato contrassegnato come da trasferire.";
    end if;
END