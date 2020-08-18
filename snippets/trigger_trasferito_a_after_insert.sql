-- Mantiene aggiornato l'attributo ridondante DIPENDENTE.DataUltimoTrasferimento

CREATE DEFINER = CURRENT_USER TRIGGER `directory_aziendale`.`TRASFERITO_A_AFTER_INSERT` AFTER INSERT ON `TRASFERITO_A` FOR EACH ROW
BEGIN
	update DIPENDENTE
    set
		DataUltimoTrasferimento = new.`data`
	where
		CF = new.CFDipendente;
END