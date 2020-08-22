CREATE TABLE `DA_TRASFERIRE_A` (
  `CFDipendente` char(16) NOT NULL,
  `NomeMansione` varchar(45) NOT NULL,
  `NomeSettore` varchar(45) NOT NULL,
  PRIMARY KEY (`CFDipendente`),
  UNIQUE KEY `NomeMansione` (`NomeMansione`,`NomeSettore`),
  CONSTRAINT `CFDipendente_FK` FOREIGN KEY (`CFDipendente`) REFERENCES `DIPENDENTE` (`CF`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Registra tutti i dipendenti che devono essere sottoposti a trasferimento, specificando la mansione che dovranno svolgere a trasferimento compiuto. Se un dipendente è trasferito a una postazione diversa dello stesso ufficio, oppure a un altro ufficio che svolge la stessa mansione, la mansione registrata sarà quella che il dipendente stava svolgendo prima di essere trasferito.';