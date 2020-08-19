-- Controlla che il formato delle mail inserite sia valido
-- Controlla che la postazione assegnata al dipendente sia presente in una tupla in TRASFERITO_A relativamente a tale dipendente, se diversa da NULL

CREATE DEFINER=`root`@`localhost` PROCEDURE `DIPENDENTE_before_insert_update`(in email varchar(45), in numTelefonicoEsternoPostazione varchar(45), in cfDipendente char(16), in dataUltimoTrasferimento date)
BEGIN
	if email not like '_%@_%.__%' 
		then signal sqlstate '45001'
        set message_text = "ERROR: invalid Email format, a compliant one is username@hostname.domain";
	elseif not (select NumTelefonicoEsternoPostazione, `Data` from TRASFERITO_A where TRASFERITO_A.NumTelefonicoEsternoPostazione = numTelefonicoEsternoPostazione and TRASFERITO_A.`Data` = dataUltimoTrasferimento)
        then signal sqlstate '45003'
        set message_text =  "ERROR: Employer was not registered as TRASFERITO_A to designed postation.";
    end if;
END