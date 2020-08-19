-- -- Eseguono controlli definiti nella stored procedure DIPENDENTE_before_insert_update prima di permettere un update

CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`DIPENDENTE_BEFORE_UPDATE`
BEFORE UPDATE ON `directory_aziendale`.`DIPENDENTE`
FOR EACH ROW
BEGIN
	call directory_aziendale.DIPENDENTE_before_insert_update(new.EmailPersonale, new.NumTelefonicoEsternoPostazione, new.CF, new.DataUltimoTrasferimento);
END