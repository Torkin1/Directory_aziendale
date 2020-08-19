-- Mantiene coerente l'attributo ridondante DIPENDENTE.DataUltimoTrasferimento
-- Aggiorna la postazione corrente del DIPENDENTE

CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`TRASFERITO_A_AFTER_INSERT`
AFTER INSERT ON `directory_aziendale`.`TRASFERITO_A`
FOR EACH ROW
BEGIN
	update DIPENDENTE
    set 
		DataUltimoTrasferimento = new.`data`, 
        NumTelefonicoEsternoPostazione = new.NumTelefonicoEsternoPostazione
    where CF = new.CFDipendente;
END