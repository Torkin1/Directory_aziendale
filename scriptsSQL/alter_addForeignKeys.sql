-- adding foreign keys

alter table directory_aziendale.POSTAZIONE
	add constraint Ufficio_FK 
    foreign key (NumUfficio, NumPiano, IndirizzoEdificio) references UFFICIO_FISICO (Numero, NumPiano, IndirizzoEdificio)
    on update cascade
    on delete cascade;

alter table directory_aziendale.UFFICIO_FISICO
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
    on delete restrict
    -- se occupata, per rimuovere la postazione è necessario prima trasferire il dipendente che la occupa.