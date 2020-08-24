create table if not exists directory_aziendale.TRASFERITO_A(
	CFDipendente char(16) not null,
    NumTelefonicoEsternoPostazione varchar(45),
    `Data` date,
    NomeMansione varchar(45) not null,
    NomeSettore varchar(45) not null,
    primary key (NumTelefonicoEsternoPostazione, `Data`)
)
comment = 'Registra tutti i trasferimenti a cui i dipendenti dell\'azienda sono stati sottoposti durante il corso del tempo.';