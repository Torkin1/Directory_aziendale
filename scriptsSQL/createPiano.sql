create table if not exists directory_aziendale.PIANO(
	Numero integer,
    IndirizzoEdificio varchar(45),
    primary key (Numero, IndirizzoEdificio)
)
comment = 'Registra i piani e gli edifici occupati dall\'azienda.';
alter table directory_aziendale.PIANO
	add constraint IndirizzoEdificio_UNIQUE unique (IndirizzoEdificio);