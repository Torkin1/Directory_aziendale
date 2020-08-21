CREATE DEFINER=`root`@`localhost` PROCEDURE `DIPENDENTE_before_insert_update`(in email varchar(45), in numTelefonicoEsternoPostazione varchar(45), in cfDipendente char(16), in dataUltimoTrasferimento date)
BEGIN
	call checkEmail(email);
	if (select NumTelefonicoEsternoPostazione from TRASFERITO_A where TRASFERITO_A.NumTelefonicoEsternoPostazione = numTelefonicoEsternoPostazione and TRASFERITO_A.`Data` = dataUltimoTrasferimento) is null
        then signal sqlstate '45003'
        set message_text =  "ERROR: Employer was not registered as TRASFERITO_A to designed postation.";
    end if;
END