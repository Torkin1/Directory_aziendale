create table if not exists directory_aziendale.DA_TRASFERIRE_A(
	CFDipendente char(16) primary key,
    NomeMansione varchar(45) not null,
    NomeSettore varchar(45) not null,
    unique (NomeMansione, NomeSettore)
)
comment = 'Registra tutti i dipendenti che devono essere sottoposti a trasferimento, specificando la mansione che dovranno svolgere a trasferimento compiuto. Se un dipendente è trasferito a una postazione diversa dello stesso ufficio, oppure a un altro ufficio che svolge la stessa mansione, la mansione registrata sarà quella che il dipendente stava svolgendo prima di essere trasferito.'