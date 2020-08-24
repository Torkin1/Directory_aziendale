-- op 4: Modifica la Mansione di un Dipendente.

CREATE PROCEDURE `cambiaMansioneDipendente` (in CFDipendente char(16), in NomeNuovaMansione varchar(45), in NomeNuovoSettore varchar(45))
BEGIN
	insert into DA_TRASFERIRE_A values (CFDipendente, NomeNuovaMansione, NomeNuovoSettore);
END