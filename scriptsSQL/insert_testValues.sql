insert into directory_aziendale.PIANO values (1, "via degli uffici, 12");
insert into directory_aziendale.PIANO values (2, "via degli uffici, 12");
insert into directory_aziendale.PIANO values (0, "via dei test, 55");

insert into directory_aziendale.MANSIONE values ("calcolo bilancio", "contabilità", "ufficioCalcoloBilancio@mail.com");
insert into directory_aziendale.MANSIONE values ("calcolo stipendi", "contabilità", "ufficioCalcoloStipendi@mail.com");
insert into directory_aziendale.MANSIONE values ("reclami", "servizio clienti", "aaaa"); -- must fail for trigger

insert into directory_aziendale.UFFICIO_FISICO values (null, null, 0001, 1, "via degli uffici, 12");
insert into directory_aziendale.UFFICIO_FISICO values ('a', 'b', "0002", 1, "via degli uffici, 12"); -- must fail for FK
insert into directory_aziendale.UFFICIO_FISICO values ("calcolo bilancio", "contabilità", "0003", 0, "via dei test, 55");

insert into POSTAZIONE values ("3313747567", "0003-01", "0003", 0, "via dei test, 55");
insert into POSTAZIONE values ("1230987654", "0003-02", "0003", "0", "via dei test, 55");

insert into directory_aziendale.DIPENDENTE values ("TXHTGD97E65H851W", "Paolo", "Bonolis", null, null, null, null, "3313747567", curdate());
insert into directory_aziendale.DIPENDENTE values ("LNYRYM72A08Z327C", "Luca", "Laurenti", null, null, null, null, null, null);

insert into directory_aziendale.TRASFERITO_A values ("TXHTGD97E65H851W", "3313747567", curdate());

insert into DA_TRASFERIRE_A values ("LNYRYM72A08Z327C", "calcolo bilancio", "contabilità");
insert into TRASFERITO_A values ("LNYRYM72A08Z327C", "1230987654", curdate());