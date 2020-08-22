CREATE DEFINER=`root`@`localhost` PROCEDURE `checkTrasferitoA`(in numTelefonicoEsternoPostazione varchar(45), in cfDipendente char(16), in dataUltimoTrasferimento date)
BEGIN
    if (numTelefonicoEsternoPostazione is null and dataUltimoTrasferimento is not null) or (numTelefonicoEsternoPostazione is not null and dataUltimoTrasferimento is null)
		then signal sqlstate '45002' set message_text = "ERROR: NumTelefonicoEsternoPostazione and DataUltimoTrasferimento must be both null or both not null";
	elseif numTelefonicoEsternoPostazione is not null 
		and dataUltimoTrasferimento is not null 
        and (select NumTelefonicoEsternoPostazione from TRASFERITO_A where TRASFERITO_A.NumTelefonicoEsternoPostazione = numTelefonicoEsternoPostazione and TRASFERITO_A.`Data` = dataUltimoTrasferimento) is null
		then signal sqlstate '45003'
		set message_text =  "ERROR: Can't find a transfer of this employer in TRASFERITO_A to designed postation with provided date";
	end if;
END