create table if not exists directory_aziendale.TRASFERITO_A(
	CFDipendente char(16),
    NumTelefonicoEsternoPostazione varchar(45),
    `Data` date,
    primary key (NumTelefonicoEsternoPostazione, `Data`)
)
comment = 'Registra tutti i trasferimenti a cui i dipendenti dell\'azienda sono stati sottoposti durante il corso del tempo.';
alter table directory_aziendale.TRASFERITO_A
	modify CFDipendente_NN char(16) not null