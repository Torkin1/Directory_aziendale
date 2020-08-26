-- Implementa l'operazione 8.

create event directory_aziendale.trovaUtentiDaTrasferire on schedule every 1 day on completion preserve do
	insert ignore into DA_TRASFERIRE_A (CFDipendente, NomeMansione, NomeSettore)
    select CFDipendente, NomeMansione, NomeSettore
    from view_DipendentiDaTrasferirePeriodoScadutoConMansione;
