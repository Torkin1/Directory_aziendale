alter table directory_aziendale.POSTAZIONE
	add constraint EmailUfficio_FK 
    foreign key (EmailUfficio) references UFFICIO (Email)
    on update cascade
    on delete cascade;

alter table directory_aziendale.UFFICIO
	add constraint MansioneUfficio_FK 
    foreign key (NomeMansione, NomeSettore) references MANSIONE (Nome, NomeSettore)
    on delete cascade,
    add constraint Edificio_FK 
    foreign key (NumPiano, IndirizzoEdificio) references PIANO (Numero, IndirizzoEdificio)
    on delete cascade;

alter table directory_aziendale.DA_TRASFERIRE_A
	add constraint CFDipendente_FK 
    foreign key (CFDipendente) references DIPENDENTE(CF)
    on update cascade
    on delete cascade,
    add constraint MansioneDaTrasferireA_FK 
    foreign key (NomeMansione, NomeSettore) references MANSIONE (Nome, NomeSettore)
    on delete cascade;

alter table directory_aziendale.DIPENDENTE
	add constraint NumTelefonicoEsternoPostazioneDipendente_FK 
    foreign key (NumTelefonicoEsternoPostazione) references POSTAZIONE (NumTelefonicoEsterno)
    on update cascade
    on delete restrict,
    comment = 'se occupata, prima di poter cancellare la postazione è necessario trasferire il dipendente che la occupa.'
    