CREATE TABLE IF NOT EXISTS `directory_aziendale`.`UFFICIO_FISICO` (
  `NomeMansione` VARCHAR(45) NOT NULL,
  `NomeSettore` VARCHAR(45) NOT NULL,
  Codice varchar(45) ,
  `NumPiano` INT unsigned NOT NULL,
  `IndirizzoEdificio` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Codice`, NumPiano, IndirizzoEdificio))
COMMENT = 'Registra recapiti, ubicazione all\'interno di un edificio e mansione svolta degli uffici dell\'azienda.';