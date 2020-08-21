-- Elenca tutti i dipendenti di cui il periodo di turnazione è decorso con la loro attuale mansione.
-- Si assume che il periodo di turnazione dei dipendenti sia di 30 giorni.

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `directory_aziendale`.`dipendentiDaTrasferirePeriodoScadutoConMansione` AS
    SELECT 
        `directory_aziendale`.`DIPENDENTE`.`CF` AS `CFDipendente`,
        `directory_aziendale`.`UFFICIO_FISICO`.`NomeMansione` AS `NomeMansione`,
        `directory_aziendale`.`UFFICIO_FISICO`.`NomeSettore` AS `NomeSettore`
    FROM
        ((`directory_aziendale`.`DIPENDENTE`
        JOIN `directory_aziendale`.`POSTAZIONE`)
        JOIN `directory_aziendale`.`UFFICIO_FISICO` ON (((`directory_aziendale`.`DIPENDENTE`.`NumTelefonicoEsternoPostazione` = `directory_aziendale`.`POSTAZIONE`.`NumTelefonicoEsterno`)
            AND (`directory_aziendale`.`POSTAZIONE`.`NumUfficio` = `directory_aziendale`.`UFFICIO_FISICO`.`Numero`
            and `directory_aziendale`.`POSTAZIONE`.`NumPiano` = `directory_aziendale`.`UFFICIO_FISICO`.`NumPiano`
            and `directory_aziendale`.`POSTAZIONE`.`IndirizzoEdificio` = `directory_aziendale`.`UFFICIO_FISICO`.`IndirizzoEdificio`))))
    WHERE
        ((TO_DAYS(`directory_aziendale`.`DIPENDENTE`.`DataUltimoTrasferimento`) - TO_DAYS(CURDATE())) > 30)