CREATE TABLE IF NOT EXISTS `directory_aziendale`.`DIPENDENTE` (
  `CF` CHAR(16) NOT NULL,
  `Nome` VARCHAR(45) NOT NULL,
  `Cognome` VARCHAR(45) NOT NULL,
  `LuogoNascita` VARCHAR(45) NULL DEFAULT NULL COMMENT 'Un valore NULL indica che il campo è sconosciuto. Qualora lo fosse, andrebbe aggiornato quando possibile.',
  `DataNascita` DATE NULL DEFAULT NULL COMMENT 'Un valore NULL indica che il campo è sconosciuto. Qualora lo fosse, andrebbe aggiornato quando possibile.',
  `EmailPersonale` VARCHAR(45) NULL DEFAULT NULL COMMENT 'Le stringhe contenute in questa colonna devono essere nella forma dettata dalla seguente espressione regolare: .*@.*\\..* (ad esempio: username@hostname.domain) ',
  `IndirizzoResidenza` VARCHAR(45) NULL DEFAULT NULL COMMENT 'Un valore NULL indica che il campo è sconosciuto. Qualora lo fosse, andrebbe aggiornato quando possibile.',
  `NumTelefonicoEsternoPostazione` VARCHAR(45) NULL DEFAULT NULL COMMENT 'I caratteri presenti devono essere solo cifre numeriche (0-9) ed eventuali simboli (+, -, ...).',
  `DataUltimoTrasferimento` DATE NULL DEFAULT NULL COMMENT 'Un valore NULL indica che il dipendente è stato assunto da poco nell\'azienda e non è stato ancora soggetto a trasferimento dal Settore Spazi.',
  PRIMARY KEY (`CF`),
  UNIQUE INDEX `NumTelefonicoEsternoPostazione_UNIQUE` (`NumTelefonicoEsternoPostazione` ASC) VISIBLE,
  UNIQUE INDEX `EmailPersonale_UNIQUE` (`EmailPersonale` ASC) VISIBLE,
  UNIQUE INDEX `CF_UNIQUE` (`CF` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Registra i dipendenti nell\'azienda con i loro recapiti, la loro attuale postazione e la data dell\'ultimo trasferimento, distinti dal CF.'
PACK_KEYS = DEFAULT;