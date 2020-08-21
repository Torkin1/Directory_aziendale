CREATE TABLE IF NOT EXISTS `directory_aziendale`.`POSTAZIONE` (
  `NumTelefonicoEsterno` VARCHAR(45) NOT NULL,
  `NumTelefonicoInterno` VARCHAR(45) NOT NULL,
  CodiceUfficio varchar(45) not null ,
  NumPiano int unsigned not null ,
  IndirizzoEdificio varchar(45),
  PRIMARY KEY (`NumTelefonicoEsterno`)
  );
alter table directory_aziendale.POSTAZIONE
	add constraint NumTelInt_Uff_UNIQUE unique (NumTelefonicoInterno, CodiceUfficio, NumPiano, IndirizzoEdificio);