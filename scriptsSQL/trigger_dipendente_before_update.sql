CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`DIPENDENTE_BEFORE_UPDATE`
BEFORE UPDATE ON `directory_aziendale`.`DIPENDENTE`
FOR EACH ROW
BEGIN
	call checkEmail(new.EmailPersonale);
    call checkTrasferitoA(new.NumTelefonicoEsternoPostazione, new.CF, new.DataUltimoTrasferimento);
END