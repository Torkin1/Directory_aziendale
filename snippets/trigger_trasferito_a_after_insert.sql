-- Mantiene coerente l'attributo ridondante DIPENDENTE.DataUltimoTrasferimento

CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`TRASFERITO_A_AFTER_INSERT`
AFTER INSERT ON `directory_aziendale`.`TRASFERITO_A`
FOR EACH ROW
BEGIN
	update DIPENDENTE
    set
		DataUltimoTrasferimento = new.`data`
	where
		CF = new.CFDipendente;
END