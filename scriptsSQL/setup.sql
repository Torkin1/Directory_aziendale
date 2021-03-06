-- MySQL Script generated by MySQL Workbench
-- lun 7 set 2020, 16:30:03
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema directory_aziendale
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema directory_aziendale
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `directory_aziendale` DEFAULT CHARACTER SET utf8 ;
USE `directory_aziendale` ;

-- -----------------------------------------------------
-- Table `directory_aziendale`.`PIANO`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `directory_aziendale`.`PIANO` (
  `Numero` INT UNSIGNED NOT NULL,
  `IndirizzoEdificio` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Numero`, `IndirizzoEdificio`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Registra i piani e gli edifici occupati dall\'azienda.';


-- -----------------------------------------------------
-- Table `directory_aziendale`.`UFFICIO_FISICO`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `directory_aziendale`.`UFFICIO_FISICO` (
  `NomeMansione` VARCHAR(45) NULL DEFAULT NULL,
  `NomeSettore` VARCHAR(45) NULL DEFAULT NULL,
  `Codice` VARCHAR(45) NOT NULL,
  `NumPiano` INT UNSIGNED NOT NULL,
  `IndirizzoEdificio` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Codice`, `NumPiano`, `IndirizzoEdificio`),
  INDEX `MansioneUfficio_FK` (`NomeMansione` ASC, `NomeSettore` ASC) VISIBLE,
  INDEX `Edificio_FK` (`NumPiano` ASC, `IndirizzoEdificio` ASC) VISIBLE,
  CONSTRAINT `Edificio_FK`
    FOREIGN KEY (`NumPiano` , `IndirizzoEdificio`)
    REFERENCES `directory_aziendale`.`PIANO` (`Numero` , `IndirizzoEdificio`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Registra recapiti, ubicazione all\'interno di un edificio e mansione svolta degli uffici dell\'azienda.';


-- -----------------------------------------------------
-- Table `directory_aziendale`.`POSTAZIONE`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `directory_aziendale`.`POSTAZIONE` (
  `NumTelefonicoEsterno` VARCHAR(45) NOT NULL,
  `NumTelefonicoInterno` VARCHAR(45) NOT NULL,
  `CodiceUfficio` VARCHAR(45) NOT NULL,
  `NumPiano` INT UNSIGNED NOT NULL,
  `IndirizzoEdificio` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`NumTelefonicoEsterno`),
  UNIQUE INDEX `NumTelInt_Uff_UNIQUE` (`NumTelefonicoInterno` ASC, `CodiceUfficio` ASC, `NumPiano` ASC, `IndirizzoEdificio` ASC) VISIBLE,
  INDEX `Ufficio_FK` (`CodiceUfficio` ASC, `NumPiano` ASC, `IndirizzoEdificio` ASC) VISIBLE,
  CONSTRAINT `Ufficio_FK`
    FOREIGN KEY (`CodiceUfficio` , `NumPiano` , `IndirizzoEdificio`)
    REFERENCES `directory_aziendale`.`UFFICIO_FISICO` (`Codice` , `NumPiano` , `IndirizzoEdificio`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Ospitata dall\'UFFICIO_FISICO, può essere occupata da un DIPENDENTE per svolgere una MANSIONE.';


-- -----------------------------------------------------
-- Table `directory_aziendale`.`DIPENDENTE`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `directory_aziendale`.`DIPENDENTE` (
  `CF` CHAR(16) NOT NULL,
  `Nome` VARCHAR(45) NOT NULL,
  `Cognome` VARCHAR(45) NOT NULL,
  `LuogoNascita` VARCHAR(45) NULL DEFAULT NULL COMMENT 'Un valore NULL indica che il campo è sconosciuto. Qualora lo fosse, andrebbe aggiornato quando possibile.',
  `DataNascita` DATE NULL DEFAULT NULL COMMENT 'Un valore NULL indica che il campo è sconosciuto. Qualora lo fosse, andrebbe aggiornato quando possibile.',
  `EmailPersonale` VARCHAR(45) NULL DEFAULT NULL COMMENT 'Le stringhe contenute in questa colonna devono essere nella forma dettata dalla seguente espressione regolare: .*@.*\\\\\\\\..* (ad esempio: username@hostname.domain) ',
  `IndirizzoResidenza` VARCHAR(45) NULL DEFAULT NULL COMMENT 'Un valore NULL indica che il campo è sconosciuto. Qualora lo fosse, andrebbe aggiornato quando possibile.',
  `NumTelefonicoEsternoPostazione` VARCHAR(45) NULL DEFAULT NULL COMMENT 'I caratteri presenti devono essere solo cifre numeriche (0-9) ed eventuali simboli (+, -, ...).',
  `DataUltimoTrasferimento` DATE NULL DEFAULT NULL COMMENT 'Un valore NULL indica che il dipendente è stato assunto da poco nell\'azienda e non è stato ancora soggetto a trasferimento dal Settore Spazi.',
  PRIMARY KEY (`CF`),
  UNIQUE INDEX `NumTelefonicoEsternoPostazione_UNIQUE` (`NumTelefonicoEsternoPostazione` ASC) VISIBLE,
  UNIQUE INDEX `EmailPersonale_UNIQUE` (`EmailPersonale` ASC) VISIBLE,
  CONSTRAINT `NumTelefonicoEsternoPostazioneDipendente_FK`
    FOREIGN KEY (`NumTelefonicoEsternoPostazione`)
    REFERENCES `directory_aziendale`.`POSTAZIONE` (`NumTelefonicoEsterno`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Registra i dipendenti nell\\\\\\\\\'azienda con i loro recapiti, la loro attuale postazione e la data dell\\\\\\\\\'ultimo trasferimento, distinti dal CF.';


-- -----------------------------------------------------
-- Table `directory_aziendale`.`MANSIONE`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `directory_aziendale`.`MANSIONE` (
  `Nome` VARCHAR(45) NOT NULL,
  `NomeSettore` VARCHAR(45) NOT NULL,
  `EmailUfficio` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`Nome`, `NomeSettore`),
  UNIQUE INDEX `EmailUfficio` (`EmailUfficio` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Registra le mansioni svolte all\'interno dell\'azienda. Esse sono identificate dal loro nome e dal nome del Settore cui fanno parte, in maniera tale che ogni settore possa nominare le sue mansione l\'uno in maniera indipendente dall\'altro';


-- -----------------------------------------------------
-- Table `directory_aziendale`.`DA_TRASFERIRE_A`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `directory_aziendale`.`DA_TRASFERIRE_A` (
  `CFDipendente` CHAR(16) NOT NULL,
  `NomeMansione` VARCHAR(45) NOT NULL,
  `NomeSettore` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CFDipendente`),
  INDEX `MansioneDaTrasferireA_FK` (`NomeMansione` ASC, `NomeSettore` ASC) VISIBLE,
  CONSTRAINT `CFDipendente_FK`
    FOREIGN KEY (`CFDipendente`)
    REFERENCES `directory_aziendale`.`DIPENDENTE` (`CF`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `MansioneDaTrasferireA_FK`
    FOREIGN KEY (`NomeMansione` , `NomeSettore`)
    REFERENCES `directory_aziendale`.`MANSIONE` (`Nome` , `NomeSettore`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Registra tutti i dipendenti che devono essere sottoposti a trasferimento, specificando la mansione che dovranno svolgere a trasferimento compiuto. Se un dipendente è trasferito a una postazione diversa dello stesso ufficio, oppure a un altro ufficio che svolge la stessa mansione, la mansione registrata sarà quella che il dipendente stava svolgendo prima di essere trasferito.';


-- -----------------------------------------------------
-- Table `directory_aziendale`.`TRASFERITO_A`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `directory_aziendale`.`TRASFERITO_A` (
  `CFDipendente` CHAR(16) NOT NULL,
  `NumTelefonicoEsternoPostazione` VARCHAR(45) NOT NULL,
  `Data` DATE NOT NULL,
  `NomeMansione` VARCHAR(45) NOT NULL,
  `NomeSettore` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`NumTelefonicoEsternoPostazione`, `Data`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Registra tutti i trasferimenti a cui i dipendenti dell\'azienda sono stati sottoposti durante il corso del tempo.';

USE `directory_aziendale` ;

-- -----------------------------------------------------
-- Placeholder table for view `directory_aziendale`.`view_DipendentiDaTrasferirePeriodoScadutoConMansione`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `directory_aziendale`.`view_DipendentiDaTrasferirePeriodoScadutoConMansione` (`CFDipendente` INT, `NomeMansione` INT, `NomeSettore` INT);

-- -----------------------------------------------------
-- procedure assegnaDipendenteAPostazioneVuota
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `assegnaDipendenteAPostazioneVuota`(in inCFDipendente char(16), in inNumTelefonicoEsternoPostazione varchar(45))
BEGIN
    declare varNomeMansione varchar(45);
    declare varNomeSettore varchar(45);
    -- if an error occurs a rollback is performed and the error is resignaled to the caller
    declare exit handler for sqlexception
    begin
		rollback;
        resignal;
	end;
        start transaction;
    -- checks if the provided seat is empty, raises a signal otherwise
    if (select DIPENDENTE.CF
		from DIPENDENTE
        where DIPENDENTE.NumTelefonicoEsternoPostazione = inNumTelefonicoEsternoPostazione
    ) is not null 
		then signal sqlstate '45002' set message_text = "ERROR: provided seat is not empty";
	end if;
    -- checks if the job which the provided employer is to be transferred and the job assigned to the physical office containing the provided seat are the same, raises an error otherwise
    call getMansioneDaPostazioneSeCorrispondeADaTrasferireA(inCFDipendente, inNumTelefonicoEsternoPostazione, varNomeMansione, varNomeSettore);
    if varNomeMansione is null and varNomeSettore is null
		then signal sqlstate '45006' set message_text = "ERROR: provided employer is not registered to be transferred to the job assigned to the physical office which contains the seat";
    end if;
    -- assigns the provided employer to the provided seat 
    insert into TRASFERITO_A values (inCFDipendente, inNumTelefonicoEsternoPostazione, curdate(),  varNomeMansione, varNomeSettore);
    commit;
    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure assumiDipendente
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `assumiDipendente`(
    in cf char(16),
    in nome varchar(45),
    in cognome varchar(45),
    in luogoNascita varchar(45),
    in dataNascita date,
    in emailPersonale varchar(45),
    in indirizzoResidenza varchar(45),
    in nomeMansione varchar(45),
    in nomeSettore varchar(45)
)
BEGIN
	-- on any error performs a rollback, then resignals to caller
    declare exit handler for sqlexception
    begin
		rollback;
        resignal;
	end;
    -- performs op 9 atomically
    start transaction;
    insert into DIPENDENTE
		values (
			cf,
            nome,
            cognome,
            luogoNascita,
            dataNascita,
            emailPersonale,
            indirizzoResidenza,
            null,
            null
        );
	insert into DA_TRASFERIRE_A
		values (
			cf,
            nomeMansione,
            nomeSettore
        );
    commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure cambiaMansioneDipendente
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cambiaMansioneDipendente`(in CFDipendente char(16), in NomeNuovaMansione varchar(45), in NomeNuovoSettore varchar(45))
BEGIN
	insert into DA_TRASFERIRE_A values (CFDipendente, NomeNuovaMansione, NomeNuovoSettore);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure checkDipendentiStessaMansione
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkDipendentiStessaMansione`(
	in inCFDipendente1 char (16), 
	in inCfDipendente2 char(16), 
    out outNomeMansione varchar(45), 
    out outNomeSettore varchar(45)
)
BEGIN
	select u1.NomeMansione, u1.NomeSettore
		from DIPENDENTE as d1 join POSTAZIONE as p1 on d1.NumTelefonicoEsternoPostazione = p1.NumTelefonicoEsterno
            join UFFICIO_FISICO as u1 on p1.CodiceUfficio = u1.Codice
				and p1.NumPiano = u1.NumPiano
				and p1.IndirizzoEdificio = u1.IndirizzoEdificio
		where d1.CF = inCFDipendente1
        and (u1.NomeMansione, u1.NomeSettore) = (
			select u2.NomeMansione, u2.NomeSettore
            from DIPENDENTE as d2 join POSTAZIONE as p2 on d2.NumTelefonicoEsternoPostazione = p2.NumTelefonicoEsterno 
				join UFFICIO_FISICO as u2 on p2.CodiceUfficio = u2.Codice
					and p2.NumPiano = u2.NumPiano
					and p2.IndirizzoEdificio = u2.IndirizzoEdificio
			where d2.CF = inCfDipendente2
		) into outNomeMansione, outNomeSettore;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure checkEmail
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkEmail`(in email varchar(45))
BEGIN
	if email not like '_%@_%.__%' 
		then signal sqlstate '45001'
        set message_text = "ERROR: invalid Email format, a compliant one is username@hostname.domain";
        end if;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure checkTrasferitoA
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkTrasferitoA`(in numTelefonicoEsternoPostazione varchar(45), in cfDipendente char(16), in dataUltimoTrasferimento date)
BEGIN
	if numTelefonicoEsternoPostazione is not null 
		and dataUltimoTrasferimento is not null 
        and (select NumTelefonicoEsternoPostazione from TRASFERITO_A where TRASFERITO_A.NumTelefonicoEsternoPostazione = numTelefonicoEsternoPostazione and TRASFERITO_A.`Data` = dataUltimoTrasferimento) is null
		then signal sqlstate '45003'
		set message_text =  "ERROR: Can't find a transfer of this employer in TRASFERITO_A to designed postation with provided date";
	end if;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure elencaTrasferimentiDipendente
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `elencaTrasferimentiDipendente`(in cfDipendente char(16))
BEGIN
	select *
    from TRASFERITO_A
    where TRASFERITO_A.CFDipendente = cfDipendente or cfDipendente is null
    order by CFDipendente, `Data`;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure generaReportDaTrasferire
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `generaReportDaTrasferire`()
BEGIN
	select CFDipendente, DA_TRASFERIRE_A.NomeMansione as NewNomeMansione, DA_TRASFERIRE_A.NomeSettore as NewNomeSettore
	from DA_TRASFERIRE_A 
	order by NewNomeMansione, NewNomeSettore;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getMansioneDaPostazioneSeCorrispondeADaTrasferireA
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getMansioneDaPostazioneSeCorrispondeADaTrasferireA`(
	in inCFDipendente char(16),
    in inNumTelefonicoEsternoPostazione varchar(45), 
	out outNomeMansione varchar(45), 
	out outNomeSettore varchar(45)
)
BEGIN
	select DA_TRASFERIRE_A.NomeMansione, DA_TRASFERIRE_A.NomeSettore
	from DIPENDENTE
		left join DA_TRASFERIRE_A on DIPENDENTE.CF = DA_TRASFERIRE_A.CFDipendente
		left join UFFICIO_FISICO on DA_TRASFERIRE_A.NomeMansione = UFFICIO_FISICO.NomeMansione
			and DA_TRASFERIRE_A.NomeSettore = UFFICIO_FISICO.NomeSettore
		left join POSTAZIONE on UFFICIO_FISICO.Codice = POSTAZIONE.CodiceUfficio
			and UFFICIO_FISICO.NumPiano = POSTAZIONE.NumPiano
			and UFFICIO_FISICO.IndirizzoEdificio = POSTAZIONE.IndirizzoEdificio
	where POSTAZIONE.NumTelefonicoEsterno = inNumTelefonicoEsternoPostazione
		and DIPENDENTE.CF = inCFDipendente
		and DA_TRASFERIRE_A.NomeMansione = UFFICIO_FISICO.NomeMansione
		and DA_TRASFERIRE_A.NomeSettore = UFFICIO_FISICO.NomeSettore
	 into outNomeMansione, outNomeSettore
    ;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ricercaDipendente
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ricercaDipendente`(in inNome varchar(45), in inCognome varchar(45))
BEGIN
	select DIPENDENTE.Nome, DIPENDENTE.Cognome, DIPENDENTE.IndirizzoResidenza, DIPENDENTE.EmailPersonale, DIPENDENTE.NumTelefonicoEsternoPostazione, MANSIONE.EmailUfficio
    from DIPENDENTE left join POSTAZIONE on DIPENDENTE.NumTelefonicoEsternoPostazione = POSTAZIONE.NumTelefonicoEsterno
		left join UFFICIO_FISICO on POSTAZIONE.CodiceUfficio = UFFICIO_FISICO.Codice
			and POSTAZIONE.NumPiano = UFFICIO_FISICO.NumPiano
            and POSTAZIONE.IndirizzoEdificio = UFFICIO_FISICO.IndirizzoEdificio
		left join MANSIONE on UFFICIO_FISICO.NomeMansione = MANSIONE.Nome
			and UFFICIO_FISICO.NomeSettore = MANSIONE.NomeSettore
	where (DIPENDENTE.Nome = inNome or inNome is null)
		and (DIPENDENTE.Cognome = inCognome or inCognome is null);
        
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ricercaPerNumeroTelefono
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ricercaPerNumeroTelefono`(in numTelefono varchar(45))
BEGIN
	select UFFICIO_FISICO.Codice as CodiceUfficio, UFFICIO_FISICO.NumPiano, UFFICIO_FISICO.IndirizzoEdificio, DIPENDENTE.CF as CFDipendente, DIPENDENTE.Nome as NomeDipendente, DIPENDENTE.Cognome as CognomeDipendente, DA_TRASFERIRE_A.NomeMansione as NomeMansioneInTrasferimentoA, DA_TRASFERIRE_A.NomeSettore as NomeSettoreInTrasferimentoA
    from POSTAZIONE join UFFICIO_FISICO on POSTAZIONE.CodiceUfficio = UFFICIO_FISICO.Codice
			and POSTAZIONE.NumPiano = UFFICIO_FISICO.NumPiano
			and POSTAZIONE.IndirizzoEdificio = UFFICIO_FISICO.IndirizzoEdificio
        left join DIPENDENTE on DIPENDENTE.NumTelefonicoEsternoPostazione = numTelefono
        left join DA_TRASFERIRE_A on DIPENDENTE.CF = DA_TRASFERIRE_A.CFDipendente
	where POSTAZIONE.NumTelefonicoEsterno = numTelefono;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure scambiaDipendenti
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `scambiaDipendenti`(
	in cfDipendente1 char(16), 
	in cfDipendente2 char(16)
)
BEGIN
    declare tempNumeroTelefonico1 varchar(45);
	declare tempNumeroTelefonico2 varchar(45);
    declare tempNomeMansione varchar(45);
    declare tempNomeSettore varchar(45);
    declare exit handler for sqlexception
    begin
		rollback;
        resignal;
	end;
	start transaction;
    -- controlla se le due postazioni appartengono ad uffici fisici assegnati alla stessa mansione e settore, che verranno salvati dentro delle variabili
    call checkDipendentiStessaMansione(cfDipendente1, cfDipendente2, tempNomeMansione, tempNomeSettore);
	if (tempNomeMansione is null and tempNomeSettore is null) 
		then signal sqlstate "45005" set message_text = "ERROR: i dipendenti forniti non sono assegnati alla stessa mansione";
    end if;
    -- scambia i dipendenti e aggiorna la tabella TRASFERITO_A atomicamente
	set tempNumeroTelefonico1 = (select NumTelefonicoEsternoPostazione from DIPENDENTE where CF = cfDipendente1);
	set tempNumeroTelefonico2 = (select NumTelefonicoEsternoPostazione from DIPENDENTE where CF = cfDipendente2);
    update DIPENDENTE set NumTelefonicoEsternoPostazione = null where CF = cfDipendente1;
	update DIPENDENTE set NumTelefonicoEsternoPostazione = null where CF = cfDipendente2;
    insert into TRASFERITO_A values (cfDipendente1, tempNumeroTelefonico2, curdate(), tempNomeMansione, tempNomeSettore);
    insert into TRASFERITO_A values (cfDipendente2, tempNumeroTelefonico1, curdate(), tempNomeMansione, tempNomeSettore);
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure trovaDipendentiScambiabili
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `trovaDipendentiScambiabili`(in cfDipendente char(16))
BEGIN
    select d1.NumTelefonicoEsternoPostazione as possibilePostazioneDaScambiare,
        d1.CF as cfDipendenteOccupante
    from DIPENDENTE as d1
		join POSTAZIONE as p1 on d1.NumTelefonicoEsternoPostazione = p1.NumTelefonicoesterno
        join UFFICIO_FISICO as u1 on p1.CodiceUfficio = u1.Codice
			and p1.NumPiano = u1.NumPiano
            and p1.IndirizzoEdificio = u1.IndirizzoEdificio
	where d1.CF != cfDipendente
		and (u1.NomeMansione, u1.NomeSettore) in (
			select NomeMansione, NomeSettore
			from DIPENDENTE as d2 join POSTAZIONE as p2 on d2.NumTelefonicoEsternoPostazione = p2.NumTelefonicoesterno
				join UFFICIO_FISICO as u2 on p2.CodiceUfficio = u2.Codice
					and p2.NumPiano = u2.NumPiano
					and p2.IndirizzoEdificio = u2.IndirizzoEdificio
			where d2.CF = cfDipendente
	);		
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure trovaUfficiConPostazioneVuota
-- -----------------------------------------------------

DELIMITER $$
USE `directory_aziendale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `trovaUfficiConPostazioneVuota`(in inNomeMansione varchar(45), in inNomeSettore varchar(45))
BEGIN
	select POSTAZIONE.NumTelefonicoEsterno, UFFICIO_FISICO.Codice, UFFICIO_FISICO.NumPiano, UFFICIO_FISICO.IndirizzoEdificio
    from UFFICIO_FISICO 
		join POSTAZIONE on UFFICIO_FISICO.Codice = POSTAZIONE.CodiceUfficio
			and UFFICIO_FISICO.NumPiano = POSTAZIONE.NumPiano
            and UFFICIO_FISICO.IndirizzoEdificio = POSTAZIONE.IndirizzoEdificio
		left join DIPENDENTE on POSTAZIONE.NumTelefonicoEsterno = DIPENDENTE.NumTelefonicoEsternoPostazione
	where DIPENDENTE.CF is null
		and (UFFICIO_FISICO.NomeMansione = inNomeMansione or inNomeMansione is null)
        and (UFFICIO_FISICO.NomeSettore = inNomeSettore or inNomeSettore is null);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `directory_aziendale`.`view_DipendentiDaTrasferirePeriodoScadutoConMansione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `directory_aziendale`.`view_DipendentiDaTrasferirePeriodoScadutoConMansione`;
USE `directory_aziendale`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `directory_aziendale`.`view_DipendentiDaTrasferirePeriodoScadutoConMansione` AS select `directory_aziendale`.`DIPENDENTE`.`CF` AS `CFDipendente`,`directory_aziendale`.`UFFICIO_FISICO`.`NomeMansione` AS `NomeMansione`,`directory_aziendale`.`UFFICIO_FISICO`.`NomeSettore` AS `NomeSettore` from ((`directory_aziendale`.`DIPENDENTE` join `directory_aziendale`.`POSTAZIONE`) join `directory_aziendale`.`UFFICIO_FISICO` on(((`directory_aziendale`.`DIPENDENTE`.`NumTelefonicoEsternoPostazione` = `directory_aziendale`.`POSTAZIONE`.`NumTelefonicoEsterno`) and (`directory_aziendale`.`POSTAZIONE`.`CodiceUfficio` = `directory_aziendale`.`UFFICIO_FISICO`.`Codice`) and (`directory_aziendale`.`POSTAZIONE`.`NumPiano` = `directory_aziendale`.`UFFICIO_FISICO`.`NumPiano`) and (`directory_aziendale`.`POSTAZIONE`.`IndirizzoEdificio` = `directory_aziendale`.`UFFICIO_FISICO`.`IndirizzoEdificio`)))) where ((to_days(`directory_aziendale`.`DIPENDENTE`.`DataUltimoTrasferimento`) - to_days(curdate())) > 30);
USE `directory_aziendale`;

DELIMITER $$
USE `directory_aziendale`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`DIPENDENTE_BEFORE_INSERT`
BEFORE INSERT ON `directory_aziendale`.`DIPENDENTE`
FOR EACH ROW
BEGIN
	call checkEmail(new.EmailPersonale);
    call checkTrasferitoA(new.NumTelefonicoEsternoPostazione, new.CF, new.DataUltimoTrasferimento);
END$$

USE `directory_aziendale`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`DIPENDENTE_BEFORE_UPDATE`
BEFORE UPDATE ON `directory_aziendale`.`DIPENDENTE`
FOR EACH ROW
BEGIN
	call checkEmail(new.EmailPersonale);
    call checkTrasferitoA(new.NumTelefonicoEsternoPostazione, new.CF, new.DataUltimoTrasferimento);
END$$

USE `directory_aziendale`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`MANSIONE_BEFORE_INSERT`
BEFORE INSERT ON `directory_aziendale`.`MANSIONE`
FOR EACH ROW
BEGIN
	call checkEmail(new.EmailUfficio);
END$$

USE `directory_aziendale`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`MANSIONE_BEFORE_UPDATE`
BEFORE UPDATE ON `directory_aziendale`.`MANSIONE`
FOR EACH ROW
BEGIN
	call checkEmail(new.EmailUfficio);
END$$

USE `directory_aziendale`$$
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
END$$

USE `directory_aziendale`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `directory_aziendale`.`TRASFERITO_A_BEFORE_INSERT`
BEFORE INSERT ON `directory_aziendale`.`TRASFERITO_A`
FOR EACH ROW
BEGIN
	if (select CFDipendente from DA_TRASFERIRE_A where new.CFDipendente = DA_TRASFERIRE_A.CFDipendente) is not null
		then delete from DA_TRASFERIRE_A where new.CFDipendente = DA_TRASFERIRE_A.CFDipendente;
        end if;
	if (select NumTelefonicoEsternoPostazione 
		from TRASFERITO_A 
		where TRASFERITO_A.NumTelefonicoEsternoPostazione = new.NumTelefonicoEsternoPostazione 
			and TRASFERITO_A.CFDipendente = new.CFDipendente
			and timestampdiff(year, TRASFERITO_A.`Data`, curdate()) <= 3 
	) is not null
		then signal sqlstate '45004' set message_text = "ERROR: Un dipendente non può essere trasferito a una postazione dove è stato già trasferito meno di tre anni fa";
    end if;
END$$


DELIMITER ;
CREATE USER 'dipendente' IDENTIFIED BY 'Dipendente01!';

GRANT EXECUTE ON procedure `directory_aziendale`.`ricercaPerNumeroTelefono` TO 'dipendente';
GRANT EXECUTE ON procedure `directory_aziendale`.`ricercaDipendente` TO 'dipendente';
CREATE USER 'dipendenteSettoreSpazi' IDENTIFIED BY 'DipendenteSettoreSpazi01!';

GRANT EXECUTE ON procedure `directory_aziendale`.`ricercaPerNumeroTelefono` TO 'dipendenteSettoreSpazi';
GRANT EXECUTE ON procedure `directory_aziendale`.`ricercaDipendente` TO 'dipendenteSettoreSpazi';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `directory_aziendale`.`PIANO` TO 'dipendenteSettoreSpazi';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `directory_aziendale`.`UFFICIO_FISICO` TO 'dipendenteSettoreSpazi';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `directory_aziendale`.`POSTAZIONE` TO 'dipendenteSettoreSpazi';
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE `directory_aziendale`.`TRASFERITO_A` TO 'dipendenteSettoreSpazi';
GRANT SELECT ON TABLE `directory_aziendale`.`DA_TRASFERIRE_A` TO 'dipendenteSettoreSpazi';
GRANT EXECUTE ON procedure `directory_aziendale`.`generaReportDaTrasferire` TO 'dipendenteSettoreSpazi';
GRANT EXECUTE ON procedure `directory_aziendale`.`trovaDipendentiScambiabili` TO 'dipendenteSettoreSpazi';
GRANT EXECUTE ON procedure `directory_aziendale`.`scambiaDipendenti` TO 'dipendenteSettoreSpazi';
GRANT EXECUTE ON procedure `directory_aziendale`.`assegnaDipendenteAPostazioneVuota` TO 'dipendenteSettoreSpazi';
GRANT EXECUTE ON procedure `directory_aziendale`.`trovaUfficiConPostazioneVuota` TO 'dipendenteSettoreSpazi';
CREATE USER 'dipendenteSettoreAmministrativo' IDENTIFIED BY 'DipendenteSettoreAmministrativo01!';

GRANT EXECUTE ON procedure `directory_aziendale`.`ricercaPerNumeroTelefono` TO 'dipendenteSettoreAmministrativo';
GRANT EXECUTE ON procedure `directory_aziendale`.`ricercaDipendente` TO 'dipendenteSettoreAmministrativo';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `directory_aziendale`.`DIPENDENTE` TO 'dipendenteSettoreAmministrativo';
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE `directory_aziendale`.`MANSIONE` TO 'dipendenteSettoreAmministrativo';
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE `directory_aziendale`.`DA_TRASFERIRE_A` TO 'dipendenteSettoreAmministrativo';
GRANT EXECUTE ON procedure `directory_aziendale`.`cambiaMansioneDipendente` TO 'dipendenteSettoreAmministrativo';
GRANT EXECUTE ON procedure `directory_aziendale`.`elencaTrasferimentiDipendente` TO 'dipendenteSettoreAmministrativo';
GRANT EXECUTE ON procedure `directory_aziendale`.`assumiDipendente` TO 'dipendenteSettoreAmministrativo';
CREATE USER 'maintainer' IDENTIFIED BY 'Maintainer01!';

GRANT CREATE, DROP, GRANT OPTION, REFERENCES, EVENT, LOCK TABLES ON directory_aziendale.* TO 'maintainer';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
