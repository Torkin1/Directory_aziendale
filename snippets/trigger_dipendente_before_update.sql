-- Controlla la validità del formato dei valori inseriti nella colonna EmailPersonale

CREATE DEFINER = CURRENT_USER TRIGGER `directory_aziendale`.`DIPENDENTE_BEFORE_UPDATE` BEFORE UPDATE ON `DIPENDENTE` FOR EACH ROW
BEGIN
	call directory_aziendale.check_email(new.EmailPersonale);
END