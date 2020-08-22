-- op 1: Genera report indicante tutti i dipendenti, raggruppati per mansione, che devono essere trasferiti.  (sola lettura)

CREATE PROCEDURE `generaReportDaTrasferire` ()
BEGIN
	select CFDipendente, DA_TRASFERIRE_A.NomeMansione as NewNomeMansione, DA_TRASFERIRE_A.NomeSettore as NewNomeSettore
	from DA_TRASFERIRE_A 
	order by NewNomeMansione, NewNomeSettore;
END