drop table MANSIONE;
create table if not exists `directory_aziendale`.`MANSIONE`(
	Nome varchar(45),
    NomeSettore varchar(45),
    EmailUfficio varchar(45),
    primary key (Nome, NomeSettore)
)
comment = 'Registra le mansioni svolte all\'interno dell\'azienda. Esse sono identificate dal loro nome e dal nome del Settore cui fanno parte, in maniera tale che ogni settore possa nominare le sue mansione l\'uno in maniera indipendente dall\'altro';
alter table directory_aziendale.MANSIONE
    add constraint NomeSettore_UNIQUE unique (NomeSettore),
    add constraint EmailUfficio_UNIQUE unique (EmailUfficio)
    