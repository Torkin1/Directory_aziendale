CREATE TABLE IF NOT EXISTS `directory_aziendale`.`UFFICIO` (
  `Email` VARCHAR(45) NOT NULL COMMENT 'Le stringhe contenute in questa colonna devono essere nella forma dettata dalla seguente espressione regolare: .*@.*\\..* (ad esempio: username@hostname.domain) ',
  `NomeMansione` VARCHAR(45) NOT NULL,
  `NomeSettore` VARCHAR(45) NOT NULL,
  `NumPiano` INT(11) NOT NULL,
  `IndirizzoEdificio` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Email`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Registra recapiti, ubicazione all\'interno di un edificio e mansione svolta degli uffici dell\'azienda.';