CREATE TABLE IF NOT EXISTS `directory_aziendale`.`POSTAZIONE` (
  `NumTelefonicoEsterno` VARCHAR(45) NOT NULL,
  `NumTelefonicoInterno` VARCHAR(45) NOT NULL,
  `EmailUfficio` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`NumTelefonicoEsterno`),
  UNIQUE INDEX `NumTelefonicoPostazione_UNIQUE` (`NumTelefonicoEsterno` ASC) VISIBLE,
  UNIQUE INDEX `EmailUfficio_UNIQUE` (`EmailUfficio` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;
alter table directory_aziendale.POSTAZIONE
	add constraint NumTelInt_Uff_UNIQUE unique (NumTelefonicoInterno, EmailUfficio);